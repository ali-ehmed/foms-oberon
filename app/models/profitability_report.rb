# == Schema Information
#
# Table name: profitability_reports
#
#  id                    :integer          not null, primary key
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
	scope :divisions_report, -> (month, year) { select("id, div_id, sum(cogs) as cogs, sum(profit) as profit, sum(operational_exp) as opexp, sum(invoice_amount) as amount")
																						.where("month = ? and year = ?", month, year)
																						.group("div_id") 
																					 }

	scope :projects_report, -> (month, year) { select("id, project_id, sum(cogs) as cogs, sum(profit) as profit, sum(invoice_amount) as amount, sum(operational_exp) as opexp")
																						.where("month = ? and year = ?", month, year) 
																						.group("project_id")
																					}

	scope :custom_project_report, -> (project_id, year) { select("id, project_id, month, sum(cogs) as cogs, sum(profit) as profit, sum(operational_exp) as opexp, sum(invoice_amount) as amount") 
																									 .where("project_id = ? and year = ?", project_id, year)
																									 .group("month ASC")
																									 }

  scope :custom_division_report, -> (month, year, divison_id) { select("id, project_id, sum(cogs) as cogs, sum(profit) as profit, sum(operational_exp) as opexp, sum(invoice_amount) as amount") 
  																															.where("month = ? and year = ? and div_id = ?", month, year, divison_id)
  																															.group("project_id")
  																														}

	scope :designations_report, -> (month, year) { select("id, designation_id, sum(cogs) as cogs, sum(profit) as profit, sum(invoice_amount) as amount, sum(operational_exp) as opexp")
																								.where("month = ? and year = ?", month, year)
																								.group("designation_id") 
																								}

end
