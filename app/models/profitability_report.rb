# == Schema Information
#
# Table name: profitability_reports
#
#  id                    :integer          not null
#  div_id                :integer
#  project_id            :integer
#  employee_id           :integer
#  designation_id        :integer
#  month                 :string(255)
#  year                  :string(255)
#  invoice_amount        :float(24)
#  percentage_allocation :float(24)
#  no_of_days            :integer
#  cogs                  :float(24)
#  operational_exp       :float(24)
#  profit                :float(24)
#

class ProfitabilityReport < ActiveRecord::Base
	scope :division_report, -> (month, year) { select("div_id, sum(cogs) as cogs, sum(profit) as profit, sum(operational_exp) as opexp, sum(invoice_amount) as amount")
																						.where("month = ? and year = ?", month, year)
																						.group("div_id") }
end
