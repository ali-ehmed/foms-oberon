class InvoicesController < ApplicationController
  EXCEPTIONS = [OpenURI::HTTPError, Exception, StandardError, ArgumentError, RuntimeError, ActiveRecord::StatementInvalid]
  prepend_before_action :get_old_invoices, only: [:synchronisation_of_invoices]

  respond_to :json, :except => [:index]

  def index
    @projects = RmProject.active
    @employees = Employeepersonaldetail.is_inactive_or_consultant_employees
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

  def synchronisation_of_invoices
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
            emp_hours = if params[:invoice_project].present? then allocation.css("HoursWorked").text else allocation.css("Hours").text end
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

        logger.debug "------------Building Invoices for #{project_name} #{@allocation_attributes.count}------------"

        @allocation_attributes.each do |alloc_attribute|
          
          percent_billing = alloc_attribute[:percent_billing]
          is_hourly = alloc_attribute[:ishourly]
          is_shadow = alloc_attribute[:IsShadow]
          start_date = alloc_attribute[:start_date]
          end_date = alloc_attribute[:end_date]


          no_of_days = CurrentInvoice.get_business_days_between start_date, end_date #Getting Buisiness Days

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


          #Old Rm Allocation Record to update or create
          old_rm_allocation_record = RmAllocationRecord.find_by_project_id_and_employee_id_and_month_and_year(@project_id, rm_allocation_attrubutes[:employee_id], @month, @year)

          if old_rm_allocation_record.present?
            logger.debug "Updating RmAllocationRecord"
            old_rm_allocation_record.update_attributes(rm_allocation_attrubutes)
          else
            logger.debug "Creating RmAllocationRecord"
            RmAllocationRecord.create(rm_allocation_attrubutes)
          end

          @invoice_no_max_id = ProjectInvoiceNumber.get_max_invoice_no(@project_id).first

          @prev_dollar_rate = 1
          unless @invoice_no_max_id.blank?
            @prev_dollar_rate = @invoice_no_max_id.dollar_rate.to_f
          end

          current_invoice = CurrentInvoice.get_max_invoice(@project_id, alloc_attribute[:emp_id], alloc_attribute[:ishourly]).first

          employee = Employeepersonaldetail.find_by_EmployeeID(alloc_attribute[:emp_id]) #Getting Employee

          #Description Params
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

          #Current Invoice Params
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
          logger.debug "Creating Invoices"  
          CurrentInvoice.create(current_invoice_params)
        end

        logger.debug "-----Project Invoice Number------"
        CurrentInvoice.create_project_invoice_number(@project_id, @month, @year, @total_days, @prev_dollar_rate)
      end

      @msg = "Invoices successfully synchronised"

      if params[:invoice_project].present?
        proj_name = RmProject.get_project_name(params[:invoice_project])
        @msg = "Invoice successfully synchronised for project <strong>#{proj_name}</strong>"
      end

      render :json => { status: :synced_all, message: @msg }

    rescue *EXCEPTIONS => error
      logger.debug "------------#{error}------------------"

      if error.message == '404 Not Found'
        render :json => { status: :http_error_404, message: "There was something wrong in fetching records from RM Tool. Please Contact your developer" }
      else
        render :json => { status: :error, message: "Something went wrong Unfortunately. Please Contact your developer" }
      end
    end
  end

  def fetch_invoices
    @month = params[:month] || Date.today.month
    @year = params[:year] || Date.today.month
    @project_id = nil || params[:invoice_project]
    @employee_id = nil || params[:invoice_employee]

    render :json => { status: :error, message: "Please Select Project" } and return unless @project_id.present?

    @project_name = RmProject.get_project_name(@project_id)
    @project_name ||= "---"

    @current_invoices = CurrentInvoice.get_invoices_for(@month, @year, @project_id, @employee_id).order("ishourly desc")

    @total_hours = 0
    @total_amount = 0

    @current_invoices.each do |invoice|
      @total_hours += invoice.hours if invoice.ishourly
      @total_amount += invoice.amount
    end

    @total_hours = @total_hours == 0 ? "---" : @total_hours

    respond_to do |format|
      format.js
    end
  end

  def custom_invoice
    add_less = params[:add_less] == "add" ? 1 : 0
    invoice_params = {
      month: params[:month],
      year: params[:year],
      project_id: params[:invoice_project],
      description: params[:description],
      add_less: add_less,
      amount: params[:amount],
      :IsAdjustment => params[:is_adjustment]
    }

    @invoice = CurrentInvoice.new(invoice_params)
    @invoice.save

    render :json => { :status => :ok, data: @invoice }
  end

  def update
    @current_invoice = CurrentInvoice.find(params[:id])

    respond_to do |format|
      if @current_invoice.update_attributes(current_invoice_params)
        format.json { respond_with_bip(@current_invoice) }
      else
        format.json { respond_with_bip(@current_invoice) }
      end
    end
  end

  private

  def get_old_invoices
    @month = params[:month]
    @year = params[:year]
    @invoice_project = nil
    
    unless @month.present? and @year.present?
      render :json => { status: :error, message: "Please Select Month and Year" }
      return
    end

    @rm_url_initialize = RmService.new
    @url = @rm_url_initialize.get_all_project_alloc(@month.to_i, @year.to_i)

    doc = Nokogiri::XML(open(@url))
    @xml_data = doc.css("Projects Project")

    if params[:invoice_project]
      unless params[:invoice_project].present?
        render :json => { status: :error, message: "Please Select Project" }
        return
      else
        @invoice_project = params[:invoice_project]
        @url = @rm_url_initialize.get_project_alloc(@invoice_project.to_i, @month.to_i, @year.to_i)

        doc = Nokogiri::XML(open(@url))
        @xml_data = doc.css("Project")
      end
    end

    @total_days = params[:no_of_days]

    logger.debug "Removing old Invoices for the month of #{@month} and year #{@year}"
    CurrentInvoice.get_invoices_for(@month, @year, @invoice_project).destroy_all
  end

  def current_invoice_params
    params.require(:current_invoice).permit(:hours, :description, :percent_billing, 
                                            :no_of_days, :rates, :unpaid_leaves, 
                                            :amount, :reminder)
  end
end
