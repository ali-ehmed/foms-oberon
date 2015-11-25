# == Schema Information
#
# Table name: employeebenefits
#
#  MedicalInsuranceType :string(10)       default(""), not null
#  isPickAndDropAvailed :boolean          not null
#  EmployeeID           :string(6)        default(""), not null, primary key
#  ConveyancePolicy     :integer
#  AccrualPercentage    :float(24)
#

class Employee::Employeebenefit < ActiveRecord::Base
	belongs_to :employee, class_name: "Employee::Employeepersonaldetail", foreign_key: :EmployeeID, :dependent => :delete
	
	def default_values
    self.isPickAndDropAvailed ||= 0
  end


  after_initialize :default_values

	private

	def default_values
    self.isPickAndDropAvailed ||= 0
    self.MedicalInsuranceType = "Takaful" if self.MedicalInsuranceType.blank?
    self.ConveyancePolicy = 0 if self.ConveyancePolicy.blank?
  end
end
