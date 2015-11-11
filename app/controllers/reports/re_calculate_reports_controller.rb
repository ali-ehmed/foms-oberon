module Reports
	class ReCalculateReportsController < ApplicationController
		def calculate_profitability_reports
			@month = params[:month].present? ? params[:month] : Date.today.month
			@year = params[:year].present? ? params[:year] : Date.today.year

			# Destroying all old reports
			ProfitabilityReport.destroy_all

			# Creating Profitability Reports
			@profitability_reports, return_msg = ProfitabilityReport.calculate_profitability_report(@month, @year)

			respond_to do |format|
				if @profitability_reports == :created
					format.json { render :json => { status: :created, :dollar_rate => return_msg }, status: :created }
				else
					format.json { render :json => { status: :error, :error_message => return_msg }, status: :created }
				end
			end
		end
	end
end