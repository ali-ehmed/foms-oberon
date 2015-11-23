class	EmployeesController < ApplicationController
	prepend_before_action :qualification_params, only: [:qualifications]
	prepend_before_action :family_detail_params, only: [:family_details]

	def qualifications
		@unregistered_employee = params[:unregister_emp_id]
		@qualification = Employee::Educationdetail.new(qualification_params)
		@qualification.EmployeeID = @unregistered_employee
		if @qualification.save
			respond_to do |format| 
				@education_details = Employee::Educationdetail.for_unregisted_employee(@unregistered_employee)
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
				@family_details = Employee::Employeefamilydetail.for_unregisted_employee(@unregistered_employee)
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

	private

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
		family_detail_params = {
			:Name => params[:member_name],
			:Relationship => params[:relationship],
			:DateOfBirth => params[:family_dob]
		}
	end

	def employee_params
		emp_params = {
			:FirstName => params[:first_name],
			:LastName => params[:first_name],
			:Address => params[:address],
			:HomePhoneNo => params[:home_phone],
			:CellPhoneNo => params[:CellPhoneNo],
			:DateOfBirth => params[:date_of_birth],
			:Type => params[:ins_type],
			:HomeEmail => params[:persoanal_email],
			:OfficeEmail => params[:office_email],
			:DateOfJoining => params[:joining_date],
			:NTNNo => params[:ntn_no],
			:NICNO => params[:nic],
			:IsInternee => params[:is_internee],
			:Designation => params[:designation],
			:Gender => params[:gender],

			:family_detail_attributes => [
				:FamilyDetailID => params[:emp_family_id],
				:Name => params[:name],
				:Relationship => params[:relationship],
				:DateOfBirth => params[:family_member_dob]
			],

			:qualification_attributes => [
				
			]
		}
	end
end