# == Schema Information
#
# Table name: current_invoices
#
#  id               :integer          not null, primary key
#  project_id       :integer          not null
#  employee_id      :string(255)      default("")
#  ishourly         :boolean
#  hours            :float(24)
#  rates            :float(53)
#  amount           :float(53)
#  month            :string(255)
#  year             :string(255)
#  description      :string(1000)
#  percent_billing  :float(24)
#  project_name     :string(255)
#  employee_name    :string(255)
#  email            :string(100)
#  IsShadow         :boolean          default(FALSE)
#  start_date       :date
#  end_date         :date
#  no_of_days       :integer          default(0)
#  percentage_alloc :float(24)
#  IsAdjustment     :boolean          default(FALSE)
#  add_less         :boolean          default(TRUE)
#  leaves           :float(53)        default(0.0)
#  unpaid_leaves    :float(53)        default(0.0)
#  accrued_leaves   :float(53)        default(0.0)
#  balance_leaves   :float(53)        default(0.0)
#  task_notes       :string(500)
#  reminder         :binary(500)
#

class CurrentInvoice < ActiveRecord::Base

	belongs_to :employee, class_name: "Employee::Employeepersonaldetail", foreign_key: :employee_id

	scope :get_max_invoice, -> (project_id, emp_id, ishourly) { where("id = (select max(id) 
					                                                from current_invoices 
					                                                where project_id = '#{project_id}' 
					                                                and employee_id = '#{emp_id}' 
					                                                and ishourly = #{ishourly})") 
																												}

	scope :get_isShadow_and_hourly, -> (project_id, employee_id) { where("id = (select max(id) 
																				FROM current_invoices 
																				where project_id = #{project_id} 
																				and employee_id = #{employee_id} 
																				and ishourly = 0 AND IsShadow = 0)") }

	scope :get_invoices_for, -> (month, year, project_id = nil, employee_id = nil) do 
		if project_id.blank? and employee_id.blank?
			where("month = ? and year = ?", month, year)
		elsif employee_id.blank? and project_id.present?
			where("project_id = ? and month = ? and year = ?", project_id, month, year)
		elsif project_id.blank? and employee_id.present?
			where("employee_id = ? and month = ? and year = ?", employee_id, month, year)
		else
			logger.debug "-----"
			where("employee_id = ? and project_id = ? and month = ? and year = ?", employee_id, project_id, month, year)
		end
	end

	scope :unregistered_employees, -> (month, year, project_id) { select("distinct employee_id, employee_name").where("month = ? and year = ? and project_id = ? and employee_id < 0", month, year, project_id) }

	validates :hours, presence: true, on: :update, if: :check_hourly

	def check_hourly
		ishourly == true
	end

	class << self

		def leaves_caluclation(balanced_record, accrued_leaves, leaves)
			return balanced_record.balance_leaves + accrued_leaves - leaves
		end

		def build_emp_accured_leaves(no_of_days, temp_days, percent_billing, hourly, is_shadow)
			accrued_leaves = no_of_days * 1.5 / temp_days.to_f * percent_billing.to_f / 100
			if hourly == "true" or is_shadow == "true"
				accrued_leaves = 0
			end
	    
	    accrued_leaves
		end

		def build_emp_leaves(percent_billing)
			leaves = (0 * percent_billing.to_f) / 100
			leaves
		end

		def build_emp_balanced_leaves(balanced_record, accrued_leaves, leaves, hourly, is_shadow)
			if balanced_record.blank?
				balance_leaves =  accrued_leaves 
			else 
				calculate_leaves = leaves_caluclation(balanced_record, accrued_leaves, leaves)
				balance_leaves = calculate_leaves 
			end

			if hourly == "true" or is_shadow == "true"
				balance_leaves = 0
			end 

			if balance_leaves < 0
				balance_leaves = 0
			end

	    balance_leaves
		end

		def build_emp_unpaid_leaves(balance_leaves)
			if balance_leaves < 0 
				unpaid_leaves = balance_leaves * -1
			else 
				unpaid_leaves = 0
			end

			unpaid_leaves
		end

		def calculate_total_amount(temp_amount, temp_rate, unpaid_leaves, options = {})
			amount = temp_amount - (temp_rate * options[:percent_billing].to_f / 100 / options[:total_days].to_f * unpaid_leaves.to_f)
	    amount = amount * 100.round / 100.0

	    amount
		end

		def create_project_invoice_number(project_id, month, year, total_no_days, prev_rate)
			params = {
				project_id: project_id,
				month: month,
				year: year,
				total_no_days: total_no_days,
				prev_dollar_rate: prev_rate.to_f
			}
			ProjectInvoiceNumber.build_invoice_number(params)
		end

		def get_business_days_between(date_1, date_2)
	    date_1 = Date.parse(date_1)
	    date_2 = Date.parse(date_2)
	    business_days = 0
	    date = date_2

	    while date >= date_1
	      business_days = business_days + 1
	      date = date - 1.day
	    end

	    business_days
	  end

	  def get_amount_hourly(is_hourly, rates, hours, percent_billing, no_of_days, total_no_days)

	  	if is_hourly == "true"
	      temp_rate = rates.hour_based_rates.to_f
	      temp_amount =  (temp_rate * hours.to_f * 100).to_f.round / 100.0
	    else
	      temp_rate = rates.team_based_rates.to_f
	      temp_amount =  (temp_rate * percent_billing.to_f / 100 * no_of_days.to_f / total_no_days.to_f * 100 ).to_f.round / 100.0
	    end

	    return temp_amount, temp_rate
	  end

	  def get_amount_non_hourly(is_hourly, invoice, hours, percent_billing, no_of_days, total_no_days)
	  	if is_hourly == "false"
        days_calculation = no_of_days.to_f / total_no_days.to_f
        temp_amount = ((invoice.rates *  days_calculation) * (percent_billing.to_f / 100) * 100).to_f.round / 100.0
      else
        temp_amount = (invoice.rates * hours.to_f * 100).to_f.round / 100.0
      end

      return temp_amount
	  end

	  def build_description(invoice, employee, options = {})
	  	if invoice.blank?
        if employee.blank?
          rate = Rate.get_max_rate(32).first
          temp_task = options[:ishourly] == "true" ? " : #{options[:task_notes]}" : ""
          description = "#{options[:emp_name]} #{options[:temp_task]}"
        else
          rate = Rate.get_max_rate(employee.Designation).first
          temp_desc = employee.designation.designation_name unless employee.designation.blank?

          temp_task = options[:ishourly] == "true" ? " : #{options[:task_notes]}" : ""

          description = "#{temp_desc} (#{employee.full_name}) #{temp_task}" 
        end
        amount, temp_rate = CurrentInvoice.get_amount_hourly(options[:ishourly], rate, options[:hours], options[:percent_billing], options[:no_of_days], options[:total_days])

      else
        temp_rate = invoice.rates

        amount = CurrentInvoice.get_amount_non_hourly(options[:ishourly], invoice, options[:hours], options[:percent_billing], options[:no_of_days], options[:total_days])

        description = employee.designation.designation_name unless employee.blank? or employee.designation.blank?

        temp_task = options[:ishourly] == "true" ? " : #{options[:task_notes]}" : ""

        employee_name = employee.blank? ? options[:employee_name] : employee.full_name
        description =  "#{description} (#{employee_name}) #{temp_task}"
      end

      if options[:no_of_days].to_i < Time.days_in_month(options[:month].to_i, options[:year].to_i).to_i  and options[:ishourly] == "false"
    	 	description = "#{description} ( "
    	 	description += "#{options[:start_date].to_datetime.strftime("%b").upcase} "
    	 	description += "#{options[:start_date].to_datetime.strftime("%d").upcase} "
    	 	description += "to "
    	 	description += "#{options[:end_date].to_datetime.strftime("%b").upcase} "
    	 	description += "#{options[:end_date].to_datetime.strftime("%d").upcase} )"
        # description = "#{description} (
	       #  							#{options[:start_date].to_datetime.strftime("%b").upcase}
	       #  							#{options[:start_date].to_datetime.strftime("%d").upcase} 
	       #  							to 
	       #  							#{options[:end_date].to_datetime.strftime("%b").upcase} 
	       #  							#{options[:end_date].to_datetime.strftime("%d").upcase}
        # 							)"
      end

      return description, amount, temp_rate
	  end
	end
end
