class InvoicesController < ApplicationController
  EXCEPTIONS = [OpenURI::HTTPError, NameError]
  # OpenURI::HTTPError => http_error, NameError => error
  prepend_before_action :sync_all_invoices, only: [:removing_old_ivnoices]

  def index
  end

  def get_invoice_number
  	@month = params[:month_year].present? ? params[:month_year].delete(' ').split("-").first : Date.today.month
		@year = params[:month_year].present? ? params[:month_year].delete(' ').split("-").last : Date.today.year
		@project_id = ''
		@project_id ||= params[:project_id]

  	record = ProjectInvoiceNumber.find_by_project_id_and_month_and_year(@project_id, @month, @year)

  	if record.nil?
      @invoice_number = Time.days_in_month(@month, @year)
    else
      @invoice_number = "#{record.invoice_no.to_s}, #{record.no_of_days.to_s}"
    end

    render :json => { status: :created, invoice_number: @invoice_number }, status: :created
  end

  def sync_all_invoices
    @month = params[:month].present? ? params[:month].delete(' ') : Date.today.month
    @year = params[:year].present? ? params[:year].delete(' ') : Date.today.year
    @total_days = params[:no_of_days]

    @rm_url = RmService.new
    doc = Nokogiri::XML(open(@rm_url.get_all_project_alloc(@month.to_i, @year.to_i)))

    @xml_data = doc.css("Projects Project")
    begin 
      @xml_data.each do |project|

        @project_id = project.css('ProjectId').text
        project_name = project.css('ProjectName').text

        @xml_allocation = project.css("Allocation")

        @allocation_attributes = Array.new

        # XML Start
        @xml_allocation.each do |allocation|
          employee_record = Employeepersonaldetail.find_by_OfficeEmail_and_isInactive(allocation.css("Email").text, 0)
          alloc_emp_id = allocation.css("FormsId").text.to_i

          if employee_record.blank?
            employee_id = alloc_emp_id * -1
          else
            employee_id = employee_record.EmployeeID
          end

          if allocation.css("IsHourly").text == "true"
            emp_hours = allocation.css("Hours").text
            task_notes = allocation.css("TaskNotes").text
            percent_billing = 100
          else
            emp_hours = ""
            task_notes = ""
            percent_billing = allocation.css("PercentBilling").text
          end

          percent_allocation = allocation.css("PercentAllocation").text

          attriubutes = {
            :emp_id => employee_id,
            :emp_name => allocation.css("Name").text,
            :percentage_alloc =>  percent_allocation,
            :task_notes => task_notes,
            :hours => emp_hours,
            :percent_billing => percent_billing,
            :start_date => allocation.css("StartDate").text,
            :end_date => allocation.css("EndDate").text,
            :ishourly => allocation.css("IsHourly").text,
            :IsShadow => allocation.css("IsShadow").text,
            :email => allocation.css("Email").text
          }

          @allocation_attributes << attriubutes
        end
        # XML FINISHED
        logger.debug "------------_ #{project_name} #{@allocation_attributes.count}"
        @allocation_attributes.each do |alloc_attribute|
          
          percent_billing = alloc_attribute[:percent_billing]
          is_hourly = alloc_attribute[:ishourly]
          is_shadow = alloc_attribute[:IsShadow]
          start_date = alloc_attribute[:start_date]
          end_date = alloc_attribute[:end_date]

          no_of_days = CurrentInvoice.get_business_days_between start_date, end_date

          rm_allocation_attrubutes = {
            :year => @year, 
            :month => @month,
            :project_id => @project_id,
            :project_name => project_name,
            :task_notes => alloc_attribute[:task_notes],
            :employee_id => alloc_attribute[:emp_id],
            :employee_name => alloc_attribute[:emp_name],
            :hours => alloc_attribute[:hours],
            :percentage_alloc => alloc_attribute[:percentage_alloc],
            :percent_billing => percent_billing,
            :start_date => start_date,
            :end_date => end_date,
            :ishourly => is_hourly,
            :IsShadow => is_shadow,
            :no_of_days => no_of_days,
            :email => alloc_attribute[:email]
          }

          old_rm_allocation_record = RmAllocationRecord.find_by_project_id_and_employee_id_and_month_and_year(@project_id, rm_allocation_attrubutes[:employee_id], @month, @year)

          if old_rm_allocation_record.present?
            logger.debug "Updating RmAllocationRecord"
            old_rm_allocation_record.update_attributes(rm_allocation_attrubutes)
          else
            logger.debug "Creating RmAllocationRecord"
            RmAllocationRecord.create(rm_allocation_attrubutes)
          end

          @invoice_no_max_id = ProjectInvoiceNumber.get_max_id(@project_id).first

          @prev_dollar_rate = 1
          unless @invoice_no_max_id.blank?
            @prev_dollar_rate = @invoice_no_max_id.dollar_rate.to_f
          end

          current_invoice = CurrentInvoice.get_max_id(@project_id, alloc_attribute[:emp_id], alloc_attribute[:ishourly]).first

          employee = Employeepersonaldetail.find_by_EmployeeID(alloc_attribute[:emp_id])

          description_params = {
            ishourly: alloc_attribute[:ishourly],
            hours: alloc_attribute[:hours],
            task_notes: alloc_attribute[:task_notes],
            emp_name: alloc_attribute[:emp_name],
            temp_task: alloc_attribute[:temp_task],
            percent_billing: percent_billing,
            no_of_days: no_of_days,
            total_days: @total_days,
            month: @month,
            year: @year,
            start_date: start_date,
            end_date: end_date
          }

          logger.debug "Creating Description"
          description, amount, rate = CurrentInvoice.build_description(current_invoice, employee, description_params) 

          # next if description == "rate_nil".to_sym

          temp_days = if @total_days.blank? then Time.days_in_month(@month.to_i, @year.to_i).to_i else @total_days.to_f end

          @balanced_invoice = CurrentInvoice.get_isShadow_and_hourly(@project_id, alloc_attribute[:emp_id]).first

          # Accured Leaves
          accrued_leaves = CurrentInvoice.build_emp_accured_leaves(no_of_days, temp_days, percent_billing, is_hourly, is_shadow)

          # Leaves
          leaves = CurrentInvoice.build_emp_leaves(percent_billing)

          #Balanced Leaves
          balance_leaves = CurrentInvoice.build_emp_balanced_leaves(@balanced_invoice, accrued_leaves, leaves, is_hourly, is_shadow)

          #Unpaid Leaves
          unpaid_leaves = CurrentInvoice.build_emp_unpaid_leaves(balance_leaves)

          current_invoice_params = {
            :year => @year,
            :month => @month,
            :project_id => @project_id,
            :project_name => project_name,
            :task_notes => alloc_attribute[:task_notes],
            :employee_id => alloc_attribute[:emp_id],
            :employee_name => alloc_attribute[:emp_name],
            :hours => alloc_attribute[:hours],
            :percentage_alloc => alloc_attribute[:percentage_alloc],
            :percent_billing => percent_billing,
            :ishourly => is_hourly,
            :IsShadow => is_shadow,
            :start_date => start_date,
            :end_date => end_date,
            :rates => rate,
            :amount => amount,
            :no_of_days => no_of_days,
            :description => description,
            :email =>  alloc_attribute[:email],
            :accrued_leaves => accrued_leaves,
            :balance_leaves => balance_leaves,
            :unpaid_leaves => unpaid_leaves,
            :leaves => leaves
          }

          # @initialize_invoice.project_id = @project_id
          # @initialize_invoice.project_name = project_name
          # @initialize_invoice.task_notes = alloc_attribute[:task_notes]
          # @initialize_invoice.employee_id = alloc_attribute[:emp_id]
          # @initialize_invoice.employee_name = alloc_attribute[:emp_name]
          # @initialize_invoice.hours = alloc_attribute[:hours]
          # @initialize_invoice.percentage_alloc = alloc_attribute[:percentage_alloc]
          # @initialize_invoice.percent_billing = percent_billing
          # @initialize_invoice.ishourly = is_hourly
          # @initialize_invoice.IsShadow = is_shadow
          # @initialize_invoice.start_date = start_date
          # @initialize_invoice.end_date = end_date
          # @initialize_invoice.rates = rate
          # @initialize_invoice.amount = amount
          # @initialize_invoice.no_of_days = no_of_days
          # @initialize_invoice.description = description
          # @initialize_invoice.email = alloc_attribute[:email]
          # @initialize_invoice.accrued_leaves = accrued_leaves
          # @initialize_invoice.balance_leaves = balance_leaves
          # @initialize_invoice.unpaid_leaves = unpaid_leaves
          # @initialize_invoice.leaves = leaves

          # @get_current_invoice = CurrentInvoice.where(current_invoice_params).first

          # if @get_current_invoice.present?
          #   logger.debug "Updating Invoices"
          #   @get_current_invoice.update_attributes(current_invoice_params)
          # else
            logger.debug "Creating Invoices"
            CurrentInvoice.create(current_invoice_params)
          # end
        end

        logger.debug "Creating Project Invoice Number"
        CurrentInvoice.create_project_invoice_number(@project_id, @month, @year, @total_days, @prev_dollar_rate)
      end

      @msg = "Invoices successfully syncd"
      render :json => { status: :synced_all, message: @msg }
    rescue => error
      if error.message == '404 Not Found'
        render :json => { status: :http_error_404, message: error.message }
      else
        # raise error
        render :json => { status: :error, message: error.message }
      end
    end
  end

  private

  def removing_old_ivnoices
    @month = params[:month].present? ? params[:month].delete(' ') : Date.today.month
    @year = params[:year].present? ? params[:year].delete(' ') : Date.today.year
    CurrentInvoice.get_old_invoices_for(@month, @year).destroy_all
  end
end
