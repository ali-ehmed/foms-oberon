# == Schema Information
#
# Table name: employeesalaries
#
#  EmployeeID   :string(6)        default(""), not null
#  SalaryID     :integer          not null, primary key
#  GrossSalary  :float(53)        not null
#  UpdationDate :datetime         not null
#

class Employee::Employeesalary < ActiveRecord::Base
	belongs_to :employee, class_name: "Employee::Employeepersonaldetail", foreign_key: :EmployeeID, :dependent => :delete
	before_create :build_update_date
	after_initialize :default_values

	# Performed after employee salary is filled
	def build_update_date
		current_payroll_date = DateManipulator.payroll_date_for_salary
		self.UpdationDate = current_payroll_date
	end

	private

	def default_values
		self.GrossSalary = "0" if self.GrossSalary.blank?
  end
end
