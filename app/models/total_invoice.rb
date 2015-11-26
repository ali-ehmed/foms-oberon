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

  belongs_to :project, class_name: "RmProject", foreign_key: :project_id
  belongs_to :employee, -> (report) { unscope(where: :EmployeeID).where("EmployeeID = ?", "%04d" % report.employee_id.to_i) }, class_name: "Employee::Employeepersonaldetail"

  scope :get_invoices_for, -> (month, year, project_id) { where("month = ? and year = ? and project_id = ?", month, year, project_id) }
  scope :get_all_by_created_date, -> (created_on) { where("createdon = ?", "#{created_on}") }

  class << self
  	def get_selected_project_invoices(month, year, project_id)
  		@current_invoices = CurrentInvoice.get_invoices_for(month, year, project_id).order("ishourly desc")

  		@current_invoices
  	end

  	def build_(params = {})
  		new params
  	end

    def get_invoice_number(total_invoice)
      record = ProjectInvoiceNumber.find_by_month_and_year_and_project_id(total_invoice.month, total_invoice.year, total_invoice.project_id)
      if record.blank?
        invoice_no = 0
      else
        invoice_no = record.invoice_no
      end

      invoice_no
    end
  end
end
