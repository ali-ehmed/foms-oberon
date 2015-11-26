module Reports
	class ProfitabilityReportsController < BaseController
		def index
			if params[:month_year].present?
				@month = params[:month_year].delete(' ').split("-").first
				@year = params[:month_year].delete(' ').split("-").last
			end

			@profitability_reports = ProfitabilityReport.where("month = ? and year = ?", @month, @year)	

			@profitability_reports ||= []
			@dollar_rate = DollarRates.find_by_month_and_year(@month, @year)
			
			respond_to do |format|
				format.js
			end
		end

		def divisions_report
			@month = params[:month_year].present? ? params[:month_year].delete(' ').split("-").first : Date.today.month
			@year = params[:month_year].present? ? params[:month_year].delete(' ').split("-").last : Date.today.year

			@division_report = ProfitabilityReport.divisions_report(@month, @year)

			divisions = Division.all

			# Genrating Divisions Report
			generate_profitability_report_for({:report => @division_report}, :divisions_report) do |report|
				report.div_id.nil? ? "---" : divisions[report.div_id - 1].div_name
			end
		end

		def projects_report
			@month = params[:month_year].present? ? params[:month_year].delete(' ').split("-").first : Date.today.month
			@year = params[:month_year].present? ? params[:month_year].delete(' ').split("-").last : Date.today.year

			# Genrating Projects Report
			@projects_report = ProfitabilityReport.projects_report(@month, @year)
			
			generate_profitability_report_for({:report => @projects_report, :graph_label_name => ["Cogs", "Expenses", "Loss", "Profit"]}, :designations_report) do |report|
				report.project_id.nil? ? "---" : RmProject.get_project_name(report.project_id)
			end
		end
		

		def specified_project_report
			@rm_projects = RmProject.all
			@year = params[:year].present? ? params[:year].delete(' ').split("-").last : Date.today.year
			@project_id = params[:report_project_id].present? ? params[:report_project_id] : @rm_projects.first.project_id

	    @project_name = RmProject.get_project_name @project_id

	    @specific_project_report = ProfitabilityReport.custom_project_report(@project_id, @year)
	    @report_data = Array.new

	    @revenue = Array.new
	    @expense = Array.new
	    @profit = Array.new

	    @tabular_data = Array.new

	    @specific_project_report.each do |project|
	    	calculated_expense = project.cogs.to_f + project.opexp.to_f
	    	data_points_for_r = { amount:  project.amount.to_f, label: "#{I18n.t("date.abbr_month_names")[project.month.to_i]} #{@year}"}
	    	data_points_for_e = { cal_expense:  calculated_expense, label: "#{I18n.t("date.abbr_month_names")[project.month.to_i]} #{@year}"}
	    	data_points_for_p = { profit:  project.profit.to_f, label: "#{I18n.t("date.abbr_month_names")[project.month.to_i]} #{@year}"}
	    	@revenue << data_points_for_r
	    	@expense << data_points_for_e
	    	@profit << data_points_for_p

	    	# Tabular Report
	    	@tabular_data << data_points_for_r << data_points_for_e << data_points_for_p
	    end

	    @tabular_data = @tabular_data.group_by { |d| d[:label] }
		end

		def specified_division_report
			@divisions = Division.all
			@month = params[:month_year].present? ? params[:month_year].delete(' ').split("-").first : Date.today.month
			@year = params[:month_year].present? ? params[:month_year].delete(' ').split("-").last : Date.today.year

			@division_id = params[:report_division_id].present? ? params[:report_division_id] : @divisions.first.id
			@specific_division_report = ProfitabilityReport.custom_division_report(@month, @year, @division_id)

			# Genrating Specific Division Report
			generate_profitability_report_for({:report => @specific_division_report}, :designations_report) do |report|
				report.project_id.nil? ? "---" : RmProject.get_project_name(report.project_id)
			end
		end

		def designations_report
			@month = params[:month_year].present? ? params[:month_year].delete(' ').split("-").first : Date.today.month
			@year = params[:month_year].present? ? params[:month_year].delete(' ').split("-").last : Date.today.year
			@designations_report = ProfitabilityReport.designations_report(@month, @year)

			# Genrating Designations Report
			generate_profitability_report_for({:report => @designations_report}, :designations_report) { |report| report.designation_id.nil? ? "---" : Designation.find(report.designation_id).designation }
		end

		def employee_history_report
			@rm_url = RmService.new
			@rm_projects = RmProject.all
	    @project_id = params[:report_project_id].present? ? params[:report_project_id] : 3
	    @start_date = params[:start_date].present? ? params[:start_date].delete(" ") : Date.today.beginning_of_month.strftime("%b %d, %Y")
	    @end_date = params[:end_date].present? ? params[:end_date].delete(" ") : Date.today.end_of_month.strftime("%b %d, %Y")

	    

	  	@doc = Nokogiri::XML(open(@rm_url.get_employee_history_of_allocations(@project_id, @start_date.delete(" "), @end_date.delete(" "))))
	  	@xml_data = @doc.css("Allocations Allocation")

	  	allocations = Array.new
			total_allocation = []

			total_cost = 0
    	total_revenue = 0
    	total_profit_or_loss = 0	    
	  	@xml_data.each do |history_data|
	  			
	  		project_id = history_data.css('ProjectID').text
	  		emp_id = history_data.css("FOMSID").text
        prorated_percent = history_data.css("ProRated").text

      	month = @start_date.to_date.strftime("%m") 
        year = @start_date.to_date.strftime("%Y")

        emp_report = Employee::EmployeeProfitibilityReport.get_history_report_of(emp_id.to_i, month, year).first
        if emp_report.present?
        	cost = (emp_report.total / 100) * prorated_percent.to_f
          total_cost += cost
        end

        total_invoices = TotalInvoice.get_invoiced_employees(project_id, emp_id.to_i, month, year).first

        if total_invoices.present?
          revenue = (total_invoices.amount / 100) * prorated_percent.to_f
          total_revenue += revenue
        end

        if revenue and cost
        	profit_or_loss = revenue - cost
        	total_profit_or_loss += profit_or_loss
        end
        attributes = {
	          :project_id => project_id,
	          :project_name => history_data.css("ProjectName").text,
	          :employee_id => emp_id,
	          :employee_name => history_data.css("Name").text,
	          :billing_type => history_data.css("BillingType").text,
	          :allocation_age => history_data.css("PercentAlloc").text,
	          :start_date => history_data.css("StartDate").text,
	          :end_date => history_data.css("EndDate").text,
	          :prorated => prorated_percent,
	          :cost => cost.nil? ? "---" : cost,
	          :revenue => revenue.nil? ? "---" : revenue,
	          :profit_or_loss => profit_or_loss.nil? ? "---" : profit_or_loss
	        }

        allocations << attributes
      end

	    @rm_project_name = RmProject.get_project_name(params[:report_project_id]) unless params[:report_project_id].blank?

      total_profitability = {
        :project_id => @project_id,
        :project_name => @rm_project_name,
        :total_cost => total_cost,
        :total_revenue => total_revenue,
        :total_profit_or_loss => total_profit_or_loss
      }
      total_allocation << total_profitability

      @summarized_report = total_allocation
      @detailed_report = allocations
		end
	end
end