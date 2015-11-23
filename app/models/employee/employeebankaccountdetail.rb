# == Schema Information
#
# Table name: employeebankaccountdetails
#
#  EmployeeID    :string(6)        default(""), not null, primary key
#  BankAccountNo :string(45)       default(""), not null
#  BankName      :string(45)       default(""), not null
#  BankBranch    :string(45)       default(""), not null
#

class Employee::Employeebankaccountdetail < ActiveRecord::Base
	belongs_to :employee, class_name: "Employee::Employeepersonaldetail", foreign_key: :EmployeeID

	before_create :default_values
	
	private

	def default_values
    self.BankAccountNo ||= "0"
    self.BankName ||= "0"
    self.BankBranch ||= "0"
  end
end
