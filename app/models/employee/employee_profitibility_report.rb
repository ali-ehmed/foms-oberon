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

class Employee::EmployeeProfitibilityReport < ActiveRecord::Base
	belongs_to :employee, class_name: "Employee::Employeepersonaldetail", foreign_key: :employee_id

	def self.get_history_report_of(emp_id, month, year)
		where("employee_id = ? and month = ? and year = ?", emp_id, month, year)
	end

  def self.calculate_emp_profitability_report(month, year, dollar_rate)
    @month = month
    @year = year
    @dollar_rate = dollar_rate

    #Delete record if already exists
    where("month = ? AND year = ?", month, year).destroy_all

    #create records for all active employees
    @employees = Employee::Employeepersonaldetail.inactive

    dollar_rate_value = dollar_rate
    dollar_rate_record = ProfDollarRates.find_by_month_and_year(@month, @year)
    dollar_rate_attr = {
    	:month => @month, 
    	:year => @year, 
    	:dollar_rate => @dollar_rate
  	}
    if dollar_rate_record.blank?
      ProfDollarRates.create(dollar_rate_attr)
    else
      dollar_rate_record.update_attributes(dollar_rate_attr)
    end
    
    operational_expense = Variable.find_by_VariableName("OperationalExpense")
    operational_expense_value = operational_expense.blank? ? 0 : (operational_expense.Value.to_i / dollar_rate_value.to_f)
    operational_expense_value = (operational_expense_value.to_f * 100 ).round / 100.0


    @employees.each do |emp|
      payroll = Payroll.find_by_iscomplete("0")

      if payroll.blank?
      	payroll = Payroll.where("idpayroll = (select max(idpayroll) from payrolls )").first
      end
      payroll_detail = Payrolldetail.where("employeeid = ? and idpayroll = ?", emp.EmployeeID, payroll.idpayroll.to_s).first

      unless payroll_detail.blank?
      	term_1 = (payroll_detail.salary + payroll_detail.accruedbonus + payroll_detail.conveyance + payroll_detail.medical + payroll_detail.adjustment + payroll_detail.LeavesEncashmentAmount - payroll_detail.leavewop).to_f
      	compensation = term_1 / dollar_rate_value.to_f
			else
				compensation = 0
			end
      compensation = (compensation.to_f * 100).round / 100.0
      amount = 0
      @invoive_amount = TotalInvoice.select("amount, project_id, percentage_alloc, ishourly, hours, percent_billing, no_of_days")
      															.where("employee_id = ? AND year = ? AND month = ? AND IsSent = 1", emp.EmployeeID, @year, @month)
      if @invoive_amount.present?
        @allocation_percentage = 0
        @billing_percentage = 0
        @total_hours = 0

        @invoive_amount.each do |temp|
        	logger.debug "#{temp.inspect}"
        	temp.no_of_days = 0 if temp.no_of_days.nil?
          @allocation_percentage += temp.percentage_alloc == nil ? 0 : (temp.percentage_alloc / Time.local(@year, @month).to_date.end_of_month.day.to_i) * temp.no_of_days #temp.percentage_alloc

          if temp.ishourly
            @billing_percentage += temp.hours / 170 * 100
            @total_hours += temp.hours
          else
            if temp.percent_billing.present? and temp.no_of_days.present?
              @billing_percentage += temp.percent_billing / Time.local(@year, @month).to_date.end_of_month.day.to_i * temp.no_of_days #temp.percent_billing/31*temp.no_of_days
            end
          end
          currency = ProjectInvoiceNumber.find_by_project_id_and_month_and_year(temp.project_id, @month, @year)
          
          if currency.IsCurrencyDollar == false
            currency = @dollar_rate
          else
            currency = 1
          end

          amount = (amount + temp.amount.to_f) / currency.to_f
        end
      end

      employee_name = "#{emp.FirstName} #{emp.LastName}"

      profit = amount- (compensation + operational_expense_value)
      attributes = {
        :employee_id => emp.EmployeeID,
        :employee_name => employee_name,
        :compensation => compensation,
        :operational_expense => operational_expense_value,
        :total => compensation + operational_expense_value,
        :invoice_amount => amount,
        :profit => profit,
        :month => @month,
        :year => @year
      }

      building = create(attributes)
      logger.debug "Calculating Employee Profitibility Report: -> #{building.inspect}"
    end

    logger.debug "Count: #{Employee::EmployeeProfitibilityReport.count}"
  end
end
