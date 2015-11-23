# == Schema Information
#
# Table name: consultants
#
#  id          :integer          not null, primary key
#  employee_id :integer
#  month       :integer
#  year        :integer
#  cogs        :float(24)
#  opex        :float(24)
#

class Consultant < ActiveRecord::Base
	belongs_to :employee, class_name: "Employee::Employeepersonaldetail", foreign_key: :employee_id
end
