# == Schema Information
#
# Table name: educationdetails
#
#  EmployeeID        :string(6)        default(""), not null
#  EducationDetailID :integer          not null, primary key
#  Qualification     :string(45)       default(""), not null
#  Institute         :string(45)       default(""), not null
#  YearFrom          :integer          not null
#  YearTo            :integer          not null
#  Type              :string(45)       default("Degree"), not null
#

class Employee::Educationdetail < ActiveRecord::Base
	belongs_to :employee, class_name: "Employee::Employeepersonaldetail", foreign_key: :EmployeeID
	scope :for_unregisted_employee, -> (employee_id) { where("EmployeeID = '#{employee_id}'") }

	validates :Qualification, :Institute , :YearFrom, :YearTo, :Type, presence: true
	validate :qualification_length

	def qualification_length
		if self.Qualification
			errors.add :base, "Qualification length should not be more than 45" if self.Qualification.length >= 45
		end
	end
end
