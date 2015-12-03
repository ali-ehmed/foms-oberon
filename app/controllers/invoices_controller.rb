class InvoicesController < ApplicationController
  EXCEPTIONS = [OpenURI::HTTPError, Exception, StandardError, ArgumentError, RuntimeError, ActiveRecord::StatementInvalid]
  prepend_before_action :get_old_invoices, only: [:synchronisation_of_invoices]

  respond_to :json, :except => [:index]
  respond_to :js, only: [:unregistered_employee]

  def index
    @projects = RmProject.active
    @employees = Employee::Employeepersonaldetail.is_inactive_or_consultant_employees
  end

  def show
    generated_invoice_params = {
      created_date: params[:invoice_created_date],
      no: params[:invoice_no],
      sent_date: params[:invoice_sent_date],
      payment_terms: params[:payment_terms],
      currency: params[:pkr_and_dollar]
    }

    @invoice_created_date = generated_invoice_params[:created_date].split("_").join(" ")

    @timestamp = @invoice_created_date
    @total_invoices = TotalInvoice.get_all_by_created_date(@invoice_created_date)

    @project = @total_invoices.first.project

    @customer_name = @project.customer_name.nil? ? "Test Customer" : @project.customer_name
    @customer_address = @project.customer_name.nil? ? "XYZ Road, ABC Town" : @project.customer_address
    @customer_email = @project.customer_personal_email.nil? ? "abc@example.com" : @project.customer_personal_email

    @invoice_no = generated_invoice_params[:no].nil? ? "N/A" : generated_invoice_params[:no].join
    @invoice_date = generated_invoice_params[:sent_date].nil? ? Date.today : generated_invoice_params[:sent_date].join.to_date
    @payment_terms = generated_invoice_params[:payment_terms]
    @currency = generated_invoice_params[:currency]

    @total_hours = 0
    @total_amount = 0

    # Getting Total Amount
    @total_invoices.each do |generated_invoice|
      @total_hours += generated_invoice.hours if generated_invoice.ishourly == true
      @total_amount += generated_invoice.amount
    end

    # TASK: Fetch those records in which percentage billing is same for same employee and those which are hourly

    @puts_records_in_array = Array.new()
    @duplicated_records = []
    @non_duplicated_records = []

    @merged_invoices = Array.new()

    @total_invoices.each do |invoice|
      @puts_records_in_array << { :month => invoice.month, :year => invoice.year, :employee_id => invoice.employee_id, :project_id => invoice.project_id }
    end

    temp_hash = {}

    # For taking uniq values
    @puts_records_in_array.each do |a|
      if temp_hash[a]
        temp_hash[a] += 1
      else
        temp_hash[a] = 1
      end
    end

    temp_hash.keys.each do |uniq_id|
      if temp_hash[uniq_id] > 1
        @duplicated_records.push(uniq_id) #getting uniq values
      else
        @non_duplicated_records.push(uniq_id) #getting non uniq values
      end
    end

    if !@duplicated_records.blank?
      @duplicated_records.each do |duplicate_record|
        @matched_employees = TotalInvoice.matched_employees(
                              duplicate_record[:month], 
                              duplicate_record[:year], 
                              duplicate_record[:project_id], 
                              duplicate_record[:employee_id], @timestamp
                              )

        for matched_employee in @matched_employees do 
          logger.debug "======Project ID - #{matched_employee.project_id} 'PROJECT NAME' - #{matched_employee.project.try(:name)} 'EMPLOYEE NAME' - #{matched_employee.employee.try(:full_name)}======"

          @new_matched_employees = TotalInvoice.new_matched_employees(
                                    duplicate_record[:month], 
                                    duplicate_record[:year],
                                    matched_employee.project_id,
                                    matched_employee.employee_id,
                                    @timestamp
                                  )

          emp_percent_billing = @new_matched_employees.map(&:percent_billing)

          emp_hourly = @new_matched_employees.map(&:ishourly)

          @repeated_percents = emp_percent_billing.select{ |e| emp_percent_billing.count(e) > 1 }
          # unless @repeated_percents.present?
          #   @repeated_percents = emp_percent_billing.select{ |e| emp_percent_billing.count(e) > 0 }
          # end
          @repeated_hourly = emp_hourly.select{ |e| emp_hourly.count(e) > 1 }

          @billing_employees = TotalInvoice.billing_employees(
                                duplicate_record[:month],
                                duplicate_record[:year],
                                matched_employee.project_id,
                                matched_employee.employee_id,
                                @timestamp,
                                @repeated_percents.first)


          @hourly_employees = TotalInvoice.hourly_employees(
                                duplicate_record[:month],
                                duplicate_record[:year],
                                matched_employee.project_id,
                                matched_employee.employee_id,
                                @timestamp)

          # # Total Days For Same Billing Emp
          total_no_of_days = @billing_employees.map(&:no_of_days).inject{|sum, x| sum + x }

          # Total Hours and Amount For Hourly Emp more than ONE
          @hourly_employees = @hourly_employees.select{ |e| @hourly_employees.count(e.employee_id) > 1 }
          total_hours = @hourly_employees.map(&:hours).inject{|sum, x| sum + x }
          total_amount = @hourly_employees.map(&:amount).inject{|sum, x| sum + x }

          # Single Hourly Emps
          @new_matched_employees.each do |hourly|
            if hourly.ishourly == true
              if !@repeated_hourly.include?(hourly.ishourly)
                puts ": Hours #{hourly.hours} #{hourly.employee_id}"
                fetched_attributes = {
                  :project_id => hourly.project_id,
                  :employee_id => hourly.employee_id,
                  :month => hourly.month,
                  :year => hourly.year,
                  :rates => hourly.rates,
                  :amount => hourly.amount,
                  :createdon => @timestamp,
                  :IsAdjustment => hourly.IsAdjustment,
                  :add_less => hourly.add_less,
                  :ishourly => hourly.ishourly,
                  :hours => hourly.hours,
                  :no_of_days => hourly.no_of_days,
                  :percent_billing => hourly.percent_billing,
                  :description => {
                    :task_notes => hourly.task_notes,
                    :designation => hourly.get_emp_designation,
                    :full_name => hourly.invoice_employee_full_name,
                    :duration => hourly.total_duration
                  }
                }
              end
            end
            @merged_invoices << fetched_attributes
          end

          # Different Percent Billing Employees
          @new_matched_employees.each do |billing_emp|
            if billing_emp.ishourly == false
              if !@repeated_percents.include?(billing_emp.percent_billing)
                puts ": Same #{billing_emp.percent_billing} #{billing_emp.employee_id}"
                fetched_attributes = {
                  :project_id => billing_emp.project_id,
                  :employee_id => billing_emp.employee_id,
                  :month => billing_emp.month,
                  :year => billing_emp.year,
                  :rates => billing_emp.rates,
                  :amount => billing_emp.amount,
                  :createdon => @timestamp,
                  :IsAdjustment => billing_emp.IsAdjustment,
                  :add_less => billing_emp.add_less,
                  :ishourly => billing_emp.ishourly,
                  :hours => billing_emp.hours,
                  :no_of_days => billing_emp.no_of_days,
                  :percent_billing => billing_emp.percent_billing,
                  :description => {
                    :task_notes => billing_emp.task_notes,
                    :designation => billing_emp.get_emp_designation,
                    :full_name => billing_emp.invoice_employee_full_name,
                    :duration => billing_emp.total_duration
                  }
                }
              end
            end
            @merged_invoices << fetched_attributes
          end


          # Same Billing Employees who are more than ONE
          unless @billing_employees.blank?
            billing_emp_desc = TotalInvoice.get_description(@billing_employees)
            fetched_attributes = {
            :project_id => @billing_employees.first.project_id,
            :employee_id => @billing_employees.first.employee_id,
            :month => @billing_employees.first.month,
            :year => @billing_employees.first.year,
            :rates => @billing_employees.first.rates,
            :amount => @billing_employees.first.amount,
            :createdon => @timestamp,
            :IsAdjustment => @billing_employees.first.IsAdjustment,
            :add_less => @billing_employees.first.add_less,
            :ishourly => @billing_employees.first.ishourly,
            :hours => @billing_employees.first.hours,
            :no_of_days => total_no_of_days,
            :percent_billing => @billing_employees.first.percent_billing,
            :description => {
              :task_notes => billing_emp_desc[:emp_task_notes],
              :designation => billing_emp_desc[:designation],
              :full_name => billing_emp_desc[:full_name],
              :duration => billing_emp_desc[:date]
            }
          }
          end

          # Same Hourly Employees who are more than ONE
          unless @hourly_employees.blank?
            hourly_emp_desc = TotalInvoice.get_description(@hourly_employees)
            fetched_attributes = {
            :project_id => @hourly_employees.first.project_id,
            :employee_id => @hourly_employees.first.employee_id,
            :month => @hourly_employees.first.month,
            :year => @hourly_employees.first.year,
            :rates => @hourly_employees.first.rates,
            :amount => total_amount,
            :createdon => @timestamp,
            :IsAdjustment => @hourly_employees.first.IsAdjustment,
            :add_less => @hourly_employees.first.add_less,
            :ishourly => @hourly_employees.first.ishourly,
            :hours => total_hours,
            # :no_of_days => @hourly_employees.first.no_of_days,
            :percent_billing => @hourly_employees.first.percent_billing,
            :description => {
              :task_notes => hourly_emp_desc[:emp_task_notes],
              :designation => hourly_emp_desc[:designation],
              :full_name => hourly_emp_desc[:full_name],
              :duration => hourly_emp_desc[:date]
            }
          }
          end


          @merged_invoices << fetched_attributes

        end
      end
    end

    # Other records which are not Same
    @other_employees = []
    logger.debug "---------------------#{@non_duplicated_records}"
    if !@non_duplicated_records.blank?
      @non_duplicated_records.each do |non_duplicated_emp|
        @employee = TotalInvoice.non_duplicate_records(
                                  non_duplicated_emp[:month],
                                  non_duplicated_emp[:year],
                                  non_duplicated_emp[:project_id],
                                  non_duplicated_emp[:employee_id],
                                  @timestamp
                                ).first
        @other_employees.push(@employee)
      end

      @other_employees.each do |employee|
        fetched_attributes = {
          :project_id => employee.project_id,
          :employee_id => employee.employee_id,
          :month => employee.month,
          :year => employee.year,
          :rates => employee.rates,
          :amount => employee.amount,
          :createdon => @timestamp,
          :IsAdjustment => employee.IsAdjustment,
          :add_less => employee.add_less,
          :ishourly => employee.ishourly,
          :hours => employee.hours,
          :no_of_days => employee.no_of_days,
          :percent_billing => employee.percent_billing,
          :description => {
            :task_notes => employee.task_notes,
            :designation => employee.get_emp_designation,
            :full_name => employee.invoice_employee_full_name,
            :duration => employee.total_duration
          }
        }
        @merged_invoices << fetched_attributes
      end
    end

    @custom_added_invoices = TotalInvoice.get_custom_invoices(@total_invoices.first.month, @total_invoices.first.year, @project.project_id, @timestamp)
    if @custom_added_invoices.count > 1
      @custom_added_invoices.each do |invoice|
        fetched_attributes = {
          :project_id => invoice.project_id,
          :employee_id => invoice.employee_id,
          :month => invoice.month,
          :year => invoice.year,
          :amount => invoice.amount,
          :createdon => @timestamp,
          :description => {
            :task_notes => invoice.description
          }
        }
        @merged_invoices << fetched_attributes
      end
    end
    @processed_invoices = @merged_invoices.compact.reverse!


    # Merge Invoice End

    respond_to do |format|
      format.html
      format.pdf do
        pdf  = render_to_string pdf: "invoice",
               template: 'invoices/show.pdf.erb',
               layout: '/layouts/foms_receipt.html.erb',
               print_media_type: true,
               title: 'Invoice Number',
               :disposition => "attachment"
        send_data(pdf, :filename => "#{@invoice_created_date}",  :type=>"application/pdf")
      end
    end
  end

  def get_invoice_number
  	@month = params[:month] || Date.today.month
		@year = params[:year] || Date.today.month
		@project_id = ''
		@project_id ||= params[:project_id]

  	record = ProjectInvoiceNumber.find_by_project_id_and_month_and_year(@project_id, @month, @year)

  	if record.nil?
      @invoice_number = Time.days_in_month(@month.to_i, @year.to_i)
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
        @error_msgs = Array.new
        # XML Start
        @xml_allocation.each do |allocation|
          employee_record = Employee::Employeepersonaldetail.find_by_OfficeEmail(allocation.css("Email").text)
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

          employee = Employee::Employeepersonaldetail.find_by_EmployeeID(alloc_attribute[:emp_id]) #Getting Employee

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

          if description == "rate_nil".to_sym
            @error_msgs.push("#{employee.full_name}") and next
          end
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

      if @error_msgs.present?
        render :json => { status: :synced_skiped, message: "#{@error_msgs.map { |msg| content_tag(:li, msg) }.join} 
                                                            Please set the rates for the following employee(s) and <strong>resync</strong> 
                                                            #{content_tag(:a, 'Rates & Designation', href: rates_path)}" }
      else
        render :json => { status: :synced_all, message: @msg }
      end

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
    @month = params[:month]
    @year = params[:year]
    @project_id = params[:invoice_project]
    @employee_id = params[:invoice_employee]

    render :json => { status: :error, message: "Please Select Project and Month" } and return unless @project_id.present? and @month.present?

    @project_name = RmProject.get_project_name(@project_id)
    @project_name ||= "---"

    @current_invoices = CurrentInvoice.get_invoices_for(@month, @year, @project_id, @employee_id).order("ishourly desc")

    @is_unregistered_employee = false
    @unregistered_employees = CurrentInvoice.unregistered_employees(@month, @year, @project_id)

    @is_unregistered_employee = true if @unregistered_employees.present?

    # Getting total
    @total_hours = 0
    @total_amount = 0

    @current_invoices.each do |invoice|
      @total_hours += invoice.hours if invoice.ishourly
      @total_amount += invoice.amount
    end

    @total_hours = @total_hours == 0 ? "---" : @total_hours
    # End

    # Listing generated dates
    @invoices_generated_dates = TotalInvoice.get_generated_dates(@month, @year, @project_id)

    # Getting currency
    invoice_number = ProjectInvoiceNumber.find_by_project_id_and_month_and_year(@project_id, @month, @year)
    unless invoice_number.blank?
      @currency = invoice_number.IsCurrencyDollar
      @payment_term = invoice_number.net_payment_term
    end
    # End
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
      :IsAdjustment => params[:is_adjustment],
      employee_id: "N/A"
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

  def recalculate
    @invoices = params[:invoice_params].values
    @invoices.each do |invoice|
      current_invoice = CurrentInvoice.find(invoice['id'].to_i)
      current_invoice.description = invoice["description"] if invoice["description"].present?
      current_invoice.amount = invoice["amount"].to_f if invoice["amount"].present?
      current_invoice.rates = invoice["rates"].to_f if invoice["rates"].present?
      current_invoice.save
    end
    render :json => { status: :ok }
  end

  def unregistered_employee
    get_params = {
      index: params[:employee_index],
      month: params[:month],
      year: params[:year],
      project_id: params[:project_id],
      employee_id: params[:employee_id]
    }
    @index = get_params[:index]
    @employee_id = get_params[:employee_id]
    @employee_education_details = Employee::Educationdetail.for_unregistered_employee(@employee_id)
    @employee_family_details = Employee::Employeefamilydetail.for_unregistered_employee(@employee_id)
  end

  def resync_status
    begin
      @month = params[:month]
      @year = params[:year]
      @project_id = params[:invoice_project]

      # render :json => { status: :error, message: "Please Select Project and Month" } and return if @project_id.blank? or @month.blank?

      @rm_url_initialize = RmService.new
      @url = @rm_url_initialize.get_invoices_status(@project_id, @month.to_i, @year.to_i)
      doc = Nokogiri::XML(open(@url))
      @status = doc.css("Status IsChanged")
      @error = doc.css("Errors Error")
      
      logger.debug "---------------- >>Status: #{@status}"
      logger.debug "---------------- >>Error: #{@error}"

      if @status.present?
        if @status.text == "false"
          render :json => { status: false }
        else
          render :json => { status: true, message: "Please resynchronise this project's data." }
        end
      else
        render :json => { status: :null_records, message: "#{@error.text} in RM" }
      end
    rescue *OpenURI::HTTPError => error
      logger.debug "------------#{error}------------------"
      render :json => { status: :error, message: "There was a problem in RM Service. Please contact your developer" }
    end
  end

  def invoice_status
    @month = (Time.now.month - 1).to_s
    @year = Time.now.year.to_s
    @invoices = CurrentInvoice.get_invoice_status(@month, @year).paginate(:page => params[:page], :per_page => 10)
    respond_to do |format|
      format.html
    end
  end

  def generate_invoices
    @month = params[:month]
    @year = params[:year]
    @project_id = params[:invoice_project]
    current_invoices = TotalInvoice.get_selected_project_invoices(@month, @year, @project_id)

    @timestamps = I18n.l DateTime.now, format: :invoices_datetime

    if TotalInvoice.get_invoices_for(@month, @year, @project_id).present?
      ActiveRecord::Base.connection.execute("UPDATE total_invoices 
        SET IsSent = 0 
        WHERE project_id = #{@project_id} AND month = #{@month} AND year = #{@year}"
      )
    end

    @invoices = Array.new
    is_valid = false

    for current_invoice in current_invoices do
      is_adjustment = current_invoice.IsAdjustment == nil ? 0 : 1
      hours = current_invoice.ishourly == true ? current_invoice.hours : ""

      add_less = 1
      add_less = current_invoice.add_less unless current_invoice.blank?

      attributes = {
        :project_id => @project_id,
        :employee_id => current_invoice.employee_id,
        :ishourly => current_invoice.ishourly,
        :month => @month,
        :year => @year,
        :hours => hours,
        :percentage_alloc => current_invoice.percentage_alloc,
        :rates => current_invoice.rates || 0,
        :unpaid_leaves => current_invoice.unpaid_leaves,
        :amount => current_invoice.amount || 0,
        :description => current_invoice.description || 0,
        :percent_billing => current_invoice.percent_billing,
        :createdon => @timestamps,
        :IsAdjustment => is_adjustment,
        :add_less => add_less,
        :no_of_days => current_invoice.no_of_days,
        :start_date => current_invoice.start_date,
        :end_date => current_invoice.end_date,
        :is_shadow => current_invoice.IsShadow
      }

      @invoices.push attributes
    end

    TotalInvoice.transaction do
      begin
        TotalInvoice.create @invoices
      rescue *[ActiveRecord::StatementInvalid, ActiveRecord::Rollback] => e
        logger.debug "----ERROR: #{e.message}-----"
        raise ActiveRecord::Rollback, "Problem occur while generating invoices"
        is_valid = true
      end
    end 

    project_name = RmProject.get_project_name(@project_id)
    respond_to do |format|
      if is_valid == false
        format.json { render :json => { status: :ok, invoice_created_date: @timestamps.split(" ").join("_"), message: "Invoices has been generated for #{project_name}" } }
      else
        format.json { render :json => { status: :error, message: "Problem occur while generating invoices" } }
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
