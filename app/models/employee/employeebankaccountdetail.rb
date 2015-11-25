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
	belongs_to :employee, class_name: "Employee::Employeepersonaldetail", foreign_key: :EmployeeID, :dependent => :delete

	after_initialize :default_values

	private

	def default_values
    self.BankAccountNo = "0" if self.BankAccountNo.blank?
    self.BankName = "0" if self.BankName.blank?
    self.BankBranch = "0" if self.BankBranch.blank?
  end
end
