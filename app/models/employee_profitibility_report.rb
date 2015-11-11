# == Schema Information
#
# Table name: employee_profitibility_reports
#
#  id                  :integer          not null, primary key
#  employee_id         :string(255)      default(""), not null
#  employee_name       :string(255)      default(""), not null
#  compensation        :float(24)
#  operational_expense :float(24)
#  total               :float(24)
#  invoice_amount      :float(24)
#  profit              :float(24)
#  month               :integer
#  year                :integer
#

class EmployeeProfitibilityReport < ActiveRecord::Base
	belongs_to :employee, class_name: "Employeepersonaldetail", foreign_key: :employee_id

	def self.get_history_report_of(emp_id, month, year)
		where("employee_id = ? and month = ? and year = ?", emp_id, month, year)
	end
end
