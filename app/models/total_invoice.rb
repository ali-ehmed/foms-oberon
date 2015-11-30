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
#  task_notes       :text(4294967295)
#  reminder         :binary(500)
#  start_date       :date
#  end_date         :date
#  is_shadow        :boolean          default(FALSE)
#

class TotalInvoice < ActiveRecord::Base

	scope :get_invoiced_employees, -> (project_id, employee_id, month, year) { where("project_id = ? and employee_id = ?
																																									and month = ? and year = ? and isSent = 1",
																																									project_id, employee_id, month, year)
																																					}

  belongs_to :project, class_name: "RmProject", foreign_key: :project_id
  belongs_to :employee, -> (report) { unscope(where: :EmployeeID).where("EmployeeID = ?", "%04d" % report.employee_id.to_i) }, class_name: "Employee::Employeepersonaldetail"

  scope :get_invoices_for, -> (month, year, project_id) { where("month = ? and year = ? and project_id = ?", month, year, project_id) }
  scope :get_all_by_created_date, -> (created_on) { where("createdon = ? and is_shadow = false", "#{created_on}") }

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

    def matched_employees(month, year, pro_id, emp_id, timestamps)
      select("project_id, employee_id").where("month = ? and year = ? and project_id = ? and employee_id = ? 
                                               and createdon = ? and is_shadow = false", month, year, pro_id, "#{emp_id}", "#{timestamps}")
                                        .group("employee_id").order("employee_id")
                                      
    end

    def new_matched_employees(month, year, pro_id, emp_id, timestamps)
      where("month = ? and year = ? and project_id = ? and employee_id = ? 
             and createdon = ? and is_shadow = false", month, year, pro_id, "#{emp_id}", "#{timestamps}")
    end

    def billing_employees(month, year, pro_id, emp_id, timestamps, percent_billing)
      where("month = ? and year = ? and 
              project_id = ?
              and employee_id = ? and
              createdon = ? and percent_billing = ? 
              and ishourly = 0 and is_shadow = false", month, year, pro_id, emp_id, "#{timestamps}", percent_billing)
    end

    def hourly_employees(month, year, pro_id, emp_id, timestamps)
      where("month = ? and year = ? and 
              project_id = ?
              and employee_id = ? and
              createdon = ?
              and ishourly = 1 and is_shadow = false", month, year, pro_id, emp_id, "#{timestamps}")
    end

    def non_duplicate_records(month, year, pro_id, emp_id, timestamps)
      select("distinct percent_billing, no_of_days, description,
              start_date, end_date, hours, amount, rates, ishourly, task_notes, 
              employee_id, project_id, month, year, IsAdjustment, add_less")
      .where("month = ? and year = ? and 
              project_id = ?
              and employee_id = ? and
              createdon = ? and is_shadow = false", month, year, pro_id, emp_id, "#{timestamps}")
    end

    def total_date_differences(object)
      # Date Difference
      @entity = object.first unless object.blank?
      checked_end_date = @entity.end_date + 1
      check_continue_dates = []
      temp_bool_val = false

      object.drop(1).each do |employee|
        if checked_end_date == employee.start_date
          temp_bool_val = true
        else
          temp_bool_val = false
        end
        check_continue_dates.push(temp_bool_val)
        checked_end_date = employee.end_date + 1
      end

      continue_dates = check_continue_dates.all? {|bool_val| bool_val == true}

      continue_dates
    end

    def get_description(object)
      @entity = object.first unless object.blank?
      emp_designation_id = !@entity.employee.blank? ? @entity.employee.Designation : ""
      emp_designation = Designation.find_by_designation_id(emp_designation_id)
      emp_designation = emp_designation.nil? ? "" : emp_designation.designation

      emp_temp_task = object.map(&:ishourly).any? {|val| val == true} # if any val is true in isHourly array
      emp_temp_task_notes = object.map{|notes| notes.task_notes}.join(" ")
      emp_task_notes = if emp_temp_task == true and !emp_temp_task_notes.blank? then ": (#{@entity.map{|m| m.task_notes}.join(', ')})" else "" end

      # Creating new Description
      emp_full_name = "#{@entity.invoice_employee_full_name}"

      desc = {
        :emp_task_notes => emp_task_notes,
        :designation => emp_designation,
        :full_name => emp_full_name
      }

      continuous_dates = TotalInvoice.total_date_differences(object)

      if continuous_dates == true
        desc[:date] = "#{I18n.l(@entity.start_date, format: :short_date)} to #{I18n.l(object.last.end_date, format: :short_date)}"
      else
        desc[:date] = "#{object.map{|m| "(#{I18n.l(m.start_date, format: :short_date)} to #{I18n.l(m.end_date, format: :short_date)})" }.join(', ')}"
      end

      desc
    end
  end

  def get_emp_designation
    emp_designation_id = !self.employee.blank? ? self.employee.Designation : ""
    emp_designation = Designation.find_by_designation_id(emp_designation_id)
    emp_designation = emp_designation.nil? ? "" : emp_designation.designation_name

    emp_designation
  end

  def invoice_employee_full_name
    if employee.present?
      employee.full_name
    else
      "N/A"
    end
  end

  def total_duration
    "#{I18n.l(self.start_date, format: :short_date)} to #{I18n.l(self.end_date, format: :short_date)}"
  end
end
