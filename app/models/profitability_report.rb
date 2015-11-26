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
	belongs_to :division, class_name: "Division", :foreign_key => :div_id
	belongs_to :project, class_name: "RmProject", :foreign_key => :project_id
	belongs_to :designation
	
	belongs_to :employee, -> (report) { unscope(where: :EmployeeID).where("EmployeeID = ?", "%04d" % report.employee_id.to_i) }, class_name: "Employee::Employeepersonaldetail"



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

	def self.calculate_profitability_report(month, year)
		@month = month
		@year = year

		@dollar_rate = DollarRates.find_by_month_and_year(@month, @year)
		@employees = Employee::Employeepersonaldetail.is_inactive_or_consultant_employees

		if !@employees.blank?
			for employee in @employees
				@invoices = TotalInvoice.where("month = ? and year = ? and isSent = 1 and ABS(employee_id) = ?", @month, @year, employee.EmployeeID.to_i.abs)
				@invoices.each do |invoice|
					unless invoice.blank?
						logger.debug "Employee: #{employee.EmployeeID} Inv = #{invoice.id} Consultant = #{employee.isConsultant}"

						rm_project = RmProject.find_by_project_id(invoice.project_id)

						emp_profitability_report = Employee::EmployeeProfitibilityReport.find_by_employee_id_and_month_and_year("#{employee.EmployeeID}", @month, @year)

	          operational_expense_variable = Variable.find_by_VariableName("OperationalExpense").Value.to_f
	          division = Division.find_by_div_owner("#{rm_project.director_name}")

	          div_id = division.id unless division.blank?
	          cogs = 0
	          operational_expense = 0

	          unless invoice.percentage_alloc.nil?
	            if employee.isConsultant == true
	            	consultant = employee.consultants.find_by_month_and_year(@month, @year)

	            	if consultant.present?
	              	cogs = consultant.cogs / @dollar_rate.dollar_rate 
	              else
	              	logger.debug "consultant not found"
	              	next
	              end
	              
	              operational_expense = consultant.opex / @dollar_rate.dollar_rate
	            else

	            	if !emp_profitability_report.nil?
	              	cogs = (((invoice.percentage_alloc / 100 / Time.local(@year, @month).to_date.end_of_month.day.to_i) * invoice.no_of_days.to_f) * emp_profitability_report.compensation)
	              else
	              	logger.debug "emp_profitability_report not found"
	              	next
	              end

	              operational_expense = ((invoice.percentage_alloc / 100 / Time.local(@year, @month).to_date.end_of_month.day.to_i) * invoice.no_of_days.to_f * operational_expense_variable / @dollar_rate.dollar_rate)
	            end
	          end

	          unless invoice.percentage_alloc.blank?
	          	invoice_percent_allocation = (invoice.percentage_alloc / 100 / Time.local(year, month).end_of_month.day.to_i) * invoice.no_of_days.to_i 
          	else
          		logger.debug "invoice percentage_alloc not found"
          		next
          	end
	          
	          profit = invoice.try(:amount) - cogs - operational_expense

	          attributes = {
	            :div_id => div_id,
	            :project_id => rm_project.project_id,
	            :employee_id => employee.EmployeeID,
	            :designation_id => employee.Designation,
	            :month => @month,
	            :year => @year,
	            :invoice_amount => invoice.amount,
	            :percentage_allocation => invoice_percent_allocation,
	            :no_of_days => invoice.no_of_days,
	            :cogs => cogs,
	            :operational_exp => operational_expense,
	            :profit => profit
	          }

	          create(attributes)
	        end
	      end
			end
			logger.debug "Count: #{ProfitabilityReport.count}"

			return :created, @dollar_rate.dollar_rate
		else
			@msg = "Employees are not found"
    	return :error, @msg
		end
	end

	def div_name
		if division.blank? or division.div_name.blank?
			"---"
		else
		 division.div_name
		end
	end

end
