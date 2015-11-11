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

class Employeepersonaldetail < ActiveRecord::Base
	# has_many :profitability_reports, class_name: "EmployeeProfitibilityReport"

	has_many :consultants, class_name: "Consultant", foreign_key: :employee_id

	has_one :employee_profitability_report, class_name: "EmployeeProfitibilityReport", foreign_key: :employee_id

	def self.is_inactive_or_consultant_employees
		where("isInactive = 0 or isConsultant = 1")
	end

	def full_name
		"#{self.FirstName} #{self.LastName}"
	end
end
