# == Schema Information
#
# Table name: employeefamilydetails
#
#  EmployeeID     :string(6)        default(""), not null
#  FamilyDetailID :integer          not null, primary key
#  Name           :string(45)       default(""), not null
#  Relationship   :string(45)       default(""), not null
#  DateOfBirth    :datetime         not null
#

class Employee::Employeefamilydetail < ActiveRecord::Base
	belongs_to :employee, class_name: "Employee::Employeepersonaldetail", foreign_key: :EmployeeID, :dependent => :delete
	scope :for_unregistered_employee, -> (employee_id) { where("EmployeeID = '#{employee_id}'") }

	validates :Name, :Relationship, :DateOfBirth, presence: true
end
