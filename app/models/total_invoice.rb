# == Schema Information
#
# Table name: total_invoices
#
#  id               :integer          not null, primary key
#  project_id       :integer          not null
#  employee_id      :string(255)      default(""), not null
#  ishourly         :boolean
#  hours            :float(24)
#  rates            :float(24)
#  amount           :float(24)
#  month            :string(255)
#  year             :string(255)
#  createdon        :datetime
#  description      :string(1000)
#  percent_billing  :float(24)
#  percentage_alloc :float(24)
#  IsAdjustment     :boolean          default(FALSE)
#  add_less         :boolean          default(TRUE)
#  IsSent           :boolean          default(TRUE)
#  unpaid_leaves    :float(53)        default(0.0)
#  no_of_days       :integer          default(0)
#  task_notes       :string(500)
#  reminder         :binary(500)
#  start_date       :date
#  end_date         :date
#

class TotalInvoice < ActiveRecord::Base

	scope :get_invoiced_employees, -> (project_id, employee_id, month, year) { where("project_id = ? and employee_id = ?
																																									and month = ? and year = ? and isSent = 1",
																																									project_id, employee_id, month, year)
																																					}
end
