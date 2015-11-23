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
	belongs_to :employee, class_name: "Employee::Employeepersonaldetail", foreign_key: :EmployeeID
end
