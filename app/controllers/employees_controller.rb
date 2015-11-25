class	EmployeesController < ApplicationController
	prepend_before_action :qualification_params, only: [:qualifications]
	prepend_before_action :family_detail_params, only: [:family_details]

	def qualifications
		@unregistered_employee = params[:unregister_emp_id]
		@qualification = Employee::Educationdetail.new(qualification_params)
		@qualification.EmployeeID = @unregistered_employee
		if @qualification.save
			respond_to do |format| 
				@education_details = Employee::Educationdetail.for_unregistered_employee(@unregistered_employee)
				format.js
			end
		else
			render :json => { status: :error, message: @qualification.errors.full_messages.map { |msg| content_tag(:li, msg) }.join }
		end
	end

	def destroy_qualification
		@unregisted_employee_education = Employee::Educationdetail.find_by_EmployeeID(params[:unregister_emp_id])
		@unregisted_employee_education.destroy
		render :json => { status: :error, message: "Education Removed" }
	end

	def family_details
		@unregistered_employee = params[:unregister_emp_id]
		@family_detail = Employee::Employeefamilydetail.new(family_detail_params)
		@family_detail.EmployeeID = @unregistered_employee
		if @family_detail.save
			respond_to do |format| 
				@family_details = Employee::Employeefamilydetail.for_unregistered_employee(@unregistered_employee)
				format.js
			end
		else
			render :json => { status: :error, message: @family_detail.errors.full_messages.map { |msg| content_tag(:li, msg) }.join }
		end
	end

	def destroy_family_detail
		@unregisted_employee_family_detail = Employee::Employeefamilydetail.find_by_EmployeeID(params[:unregister_emp_id])
		@unregisted_employee_family_detail.destroy
		render :json => { status: :error, message: "Family Detail Removed" }
	end

	def create
		@unregistered_employee_id = params[:unregister_emp_id]
		Employee::Employeepersonaldetail.transaction do 
			begin
				# Creating Employee
				@employee = Employee::Employeepersonaldetail.build_employee(employee_params)
				unless @employee.save
					render :json => { status: :error, message: @employee.errors.full_messages.map { |msg| content_tag(:li, msg) }.join } and return
				end

				# Creating Bank Account
				@bank_account_details = @employee.build_bank_account_detail employee_bank_account_params
				# Creating Family
				@employee_family = @employee.build_employee_family employee_family_params
				# Creating Benefits
				@employee_benefit = @employee.build_employee_benefit employee_benefit_params
				# Creating Salary
				@employee_salary = @employee.build_employee_salary employee_salary_params
				
				# Raise If ant of assocation failed
				Employee::Employeepersonaldetail.perform_rollback!(@employee, @bank_account_details, @employee_family, @employee_benefit, @employee_salary)

				#Otherwise
				@bank_account_details.save
				@employee_family.save
				@employee_benefit.save
				@employee_salary.save

				logger.debug "#{@employee.inspect} --- #{@bank_account_details.inspect} --- #{@employee_family.inspect} --- #{@employee_benefit.inspect} --- #{@employee_salary.inspect}"
				render :json => { status: :ok, message: "Employee Created" }

			rescue *[ActiveRecord::StatementInvalid, ActiveRecord::Rollback] => e
				logger.debug "---ERROR: #{e.message}---"
				render :json => { status: :error, message: "Please try to fill the required fields or Contact tech support!" }
				raise ActiveRecord::Rollback, "Call tech support!"
			end
		end
	end

	private

	# Form Params

	def qualification_params
		qualification_params = {
			:Qualification => params[:qualification],
			:Institute => params[:institute],
			:YearFrom => params[:from_date],
			:YearTo => params[:to_date],
			:Type => params[:type]
		}
	end

	def family_detail_params
		family_dob = params[:family_dob].present? ? Date.strptime(params[:family_dob], '%m/%d/%Y') : nil
		family_detail_params = {
			:Name => params[:member_name],
			:Relationship => params[:relationship],
			:DateOfBirth => family_dob
		}
	end

	def employee_bank_account_params
		bank_account_params = {
			:BankAccountNo => params[:bank_account_no],
			:BankName => params[:bank_name],
			:BankBranch => params[:bank_branch],
		}

		bank_account_params
	end

	def employee_salary_params
		emp_salary_params = {
			:GrossSalary => params[:gross_salary]
		}

		emp_salary_params
	end

	def employee_benefit_params
		emp_benefit_params = {
			:MedicalInsuranceType => params[:medical_insurance],
			:ConveyancePolicy => params[:conveyance],
			:AccrualPercentage => params[:accrual_bonus],
		}

		emp_benefit_params
	end

	def employee_family_params
		emp_family_params = {
			:MaritalStatus => params[:marital_status],
			:NoOfChildren => params[:children]
		}

		emp_family_params
	end

	def employee_params
		emp_dob = params[:date_of_birth].present? ? Date.strptime(params[:date_of_birth], '%m/%d/%Y') : nil
		emp_joining_date = params[:joining_date].present? ? Date.strptime(params[:joining_date], '%m/%d/%Y') : nil
		emp_params = {
			:FirstName => params[:first_name],
			:LastName => params[:last_name],
			:Address => params[:address],
			:HomePhoneNo => params[:home_phone],
			:CellPhoneNo => params[:cell_phone],
			:DateOfBirth =>	emp_dob,
			:Type => params[:ins_type],
			:HomeEmail => params[:personal_email],
			:OfficeEmail => params[:office_email],
			:DateOfJoining => emp_joining_date,
			:NTNNo => params[:ntn_no],
			:NICNo => params[:nic],
			:IsInternee => params[:is_internee],
			:Designation => params[:designation],
			:Gender => params[:gender],
			:unregister_emp_id => @unregistered_employee_id
		}

		emp_params
	end
end