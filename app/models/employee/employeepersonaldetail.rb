# == Schema Information
#
# Table name: employeepersonaldetails
#
#  EmployeeID        :string(6)        default(""), not null, primary key
#  FirstName         :string(45)       default(""), not null
#  LastName          :string(45)       default(""), not null
#  Address           :string(45)       default(""), not null
#  HomePhoneNo       :string(11)       default(""), not null
#  CellPhoneNo       :string(15)       default(""), not null
#  DateOfBirth       :datetime         not null
#  Type              :string(45)       default(""), not null
#  HomeEmail         :string(45)       default(""), not null
#  OfficeEmail       :string(45)       default(""), not null
#  DateOfJoining     :datetime         not null
#  NTNNo             :string(15)       default(""), not null
#  NICNo             :string(15)       default(""), not null
#  isInactive        :boolean
#  Gender            :string(1)
#  IsInternee        :boolean          not null
#  Department        :string(255)
#  Designation       :string(255)
#  AccrualStartDate  :datetime
#  TerminationDate   :datetime
#  is_enrolled_in_pf :boolean          default(FALSE)
#  pf_percentage     :float(53)
#  isConsultant      :boolean          default(FALSE)
#

class Employee::Employeepersonaldetail < ActiveRecord::Base
	# has_many :profitability_reports, class_name: "EmployeeProfitibilityReport"

	has_many :consultants, class_name: "Consultant", foreign_key: :employee_id, dependent: :destroy

	has_one :employee_profitability_report, class_name: "Employee::EmployeeProfitibilityReport", foreign_key: :employee_id, dependent: :destroy

	belongs_to :designation, -> { unscope(where: :Designation)}, class_name: "Designation", foreign_key: :Designation, dependent: :destroy

	has_many :qualifications, class_name: "Employee::Educationdetail", foreign_key: :EmployeeID, dependent: :destroy
	has_many :family_details, class_name: "Employee::Employeefamilydetail", foreign_key: :EmployeeID, dependent: :destroy

	has_one :employee_salary, class_name: "Employee::Employeesalary", foreign_key: :EmployeeID, dependent: :destroy
	has_one :employee_benefit, class_name: "Employee::Employeebenefit", foreign_key: :EmployeeID, dependent: :destroy
	has_one :employee_family, class_name: "Employee::Employeefamily", foreign_key: :EmployeeID, dependent: :destroy
	has_one :bank_account_detail, class_name: "Employee::Employeebankaccountdetail", foreign_key: :EmployeeID, dependent: :destroy

	validate :valid_joining_date, on: :create

	after_initialize :default_values

	scope :inactive, -> { where("isInactive = 0") }

	before_create :generate_new_employee_id
	after_create :update_invoice, :updating_qualifications_family_details

	attr_accessor :unregister_emp_id

	validates :FirstName, :LastName, :Address, :HomePhoneNo, :CellPhoneNo,
						:DateOfBirth, :DateOfJoining, :NTNNo, :NICNo, :OfficeEmail, 
						:HomeEmail, :IsInternee, presence: true

	accepts_nested_attributes_for :qualifications, reject_if: :all_blank, allow_destroy: true
	accepts_nested_attributes_for :family_details, reject_if: :all_blank, allow_destroy: true

	def self.is_inactive_or_consultant_employees
		where("isInactive = 0 or isConsultant = 1")
	end

	def full_name
		"#{self.FirstName} #{self.LastName}"
	end

	def self.build_employee(params = {})
		new params
	end
	
	def set_nested_fields
		if nested_associations == true
			qualifications.build
			family_details.build
		end
	end

	def generate_new_employee_id
		employee_id = self.class.last.EmployeeID.nil? ? "1" : (self.class.last.EmployeeID.to_i + 1).to_s
		self.EmployeeID = "%04d" % employee_id
	end

	def valid_joining_date
		joining_date =  self.DateOfJoining
		if joining_date.present?
	    @sec = Time.parse(joining_date.to_date.to_s).to_i
	    @now = Time.parse(DateManipulator.payroll_end_date).to_i

	    @time = @now - @sec
	    unless @time.blank?
	      errors.add :base, "Date of Joining should less than equal to Payroll End Date" if @time < 0
	    end
    end
	end

	def updating_qualifications_family_details
		logger.debug "-----#{self.unregister_emp_id}"
		@unregistered_employee_qualifications = Employee::Educationdetail.for_unregistered_employee(self.unregister_emp_id)
		@unregistered_employee_family_details = Employee::Employeefamilydetail.for_unregistered_employee(self.unregister_emp_id)

		@unregistered_employee_qualifications.update_all(:EmployeeID => self.EmployeeID)
		@unregistered_employee_family_details.update_all(:EmployeeID => self.EmployeeID)
	end

	def update_invoice
		unregistered_employee_id = self.unregister_emp_id
		registered_employee_id = self.EmployeeID
		CurrentInvoice.get_updated_by_registered_employee_id(unregistered_employee_id, registered_employee_id)
	end

	def self.perform_rollback!(*args)
		args.each do |entities|
			if !entities.save
				raise ActiveRecord::Rollback, "Call tech support!"
			end
		end
	end

	private

	def default_values
    self.NTNNo ||= "0"
    self.NICNo ||= "0"
    self.isInactive ||= "0"
    self.Type ||= "Full Time"
  end
end
