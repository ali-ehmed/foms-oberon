module Reports
	class ReCalculateReportsController < ApplicationController
		def calculate_profitability_reports
			@month = params[:month].present? ? params[:month] : Date.today.month
			@year = params[:year].present? ? params[:year] : Date.today.year

			begin 
				@record = DollarRates.find_by_month_and_year(@month, @year)
		    dollar_rate = dollar_rate.blank? ? 1 : @record.dollar_rate

		    logger.debug "Dollar Rate: -> #{dollar_rate}"
				# Creating Profitability Reports
				@profitability_reports = ProfitabilityReport.calculate_profitability_report(@month, @year, dollar_rate)

		    # Creating Employee Profitability Reports
		    @emp_profit_report = Employee::EmployeeProfitibilityReport.calculate_emp_profitability_report(@month, @year, dollar_rate)

			rescue *[StandardError, ScriptError, TypeError] => error
				logger.debug "Error: -> #{error}"
				respond_to do |format|
					format.json { render :json => { status: :error, :message => "#{error.message}" }, status: :created }
				end
				return
			else
				respond_to do |format|
					format.json { render :json => { status: :created, :dollar_rate => dollar_rate }, status: :created }
				end
			ensure
  			logger.debug "Recalculated"
			end
		end
	end
end