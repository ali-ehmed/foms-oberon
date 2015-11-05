module Reports
	class ProfitabilityReportsController < BaseController
		def divisions_report
			@month = params[:month_year].present? ? params[:month_year].delete(' ').split("-").first : Date.today.month
			@year = params[:month_year].present? ? params[:month_year].delete(' ').split("-").last : Date.today.year

			@division_report = ProfitabilityReport.divisions_report(@month, @year)

			divisions = Divisions.all

			# Graphical Report
			# Revenue
	    @revenue = Array.new
	    revenue_report_array = []

	    @tabular_data = Array.new

	    @revenue << { graph_name: "Revenue" }
	    @division_report.each do |div|
	      division_name = ""
	      unless div.div_id.nil?
	        division_name = divisions[div.div_id - 1].div_name
	      else
	        division_name = "Division name missing"
	      end
	      data_points = {
      		y: div.amount.to_i,
      		label: division_name   	
	      }
	      revenue_report_array << data_points
	      @tabular_data << data_points
	    end
	    @revenue << { graph_data: revenue_report_array } 
	    @max_ammount = @revenue.second[:graph_data].map{|m| m.values.first}.max{ |a,b| (a || 0) <=> (b || 0) }
  		
  		# Expense
	    @expense = Array.new
	    expense_report_array = []

	    @expense << { graph_name: "Expenses" }
	    @division_report.each do |div|
	      division_name = ""
	      unless div.div_id.nil?
	        division_name = divisions[div.div_id - 1].div_name
	      else
	        division_name = "Division name missing"
	      end
	      calculated_expense = div.cogs.to_i + div.opexp.to_i

	      data_points = {
      		y: calculated_expense,
      		label: division_name   	
	      }
	      expense_report_array << data_points

	      @tabular_data << data_points
	    end
	    @expense << { graph_data: expense_report_array }
	    @max_calculated_expense = @expense.second[:graph_data].map{|m| m.values.first}.max{ |a,b| (a || 0) <=> (b || 0) }

	    @profit = Array.new
	    @loss = Array.new
	    loss_report_array = []
	    profit_report_array = []

	    # Profit and Loss
	    @loss << { graph_name: "Loss" }
	    @profit << { graph_name: "Profit" }
	    @division_report.each do |div|
	      division_name = ""
	      unless div.div_id.nil?
	        division_name = divisions[div.div_id - 1].div_name
	      else
	        division_name = "Division name missing"
	      end

	      if div.profit.to_f > 0
	      	data_points_for_profit = {
	      		y: div.profit.to_i,
	      		label: division_name   	
		      }
		      data_points_for_loss = {
	      		y: 0,
	      		label: division_name   	
		      }
		      loss_report_array << data_points_for_loss
	    		profit_report_array << data_points_for_profit

	      else
	      	data_points_for_profit = {
	      		y: 0,
	      		label: division_name   	
		      }
		      data_points_for_loss = {
	      		y: div.profit.to_i.abs,
	      		label: division_name   	
		      }
		      profit_report_array << data_points_for_profit
		      loss_report_array << data_points_for_loss
	      end

	      @tabular_data << data_points_for_profit
	      @tabular_data << data_points_for_loss
	    end

	    @profit << { graph_data: profit_report_array }
      @loss << { graph_data: loss_report_array }

      @max_profit_for_profit = @profit.second[:graph_data].map{|m| m.values.first}.max{ |a,b| (a || 0) <=> (b || 0) }
      @max_profit_for_loss = @loss.second[:graph_data].map{|m| m.values.first}.max{ |a,b| (a || 0) <=> (b || 0) }

      # Tabular Report Grouped By
      @tabular_data = @tabular_data.group_by { |d| d[:label] }
		end



		def projects_report
			@month = params[:month_year].present? ? params[:month_year].delete(' ').split("-").first : Date.today.month
			@year = params[:month_year].present? ? params[:month_year].delete(' ').split("-").last : Date.today.year

			@projects_report = ProfitabilityReport.projects_report(@month, @year)
			get_profitability_reports_for(:projects_report, @projects_report, "project_name_label", ["Cogs", "Expenses", "Loss", "Profit"])
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
			@divisions = Divisions.all
			@month = params[:month_year].present? ? params[:month_year].delete(' ').split("-").first : Date.today.month
			@year = params[:month_year].present? ? params[:month_year].delete(' ').split("-").last : Date.today.year

			@division_id = params[:division_id].present? ? params[:division_id].present? : @divisions.first.id
			@specific_division_report = ProfitabilityReport.custom_division_report(@month, @year, @division_id)

			get_profitability_reports_for(:specified_division_report, @specific_division_report, "project_name_label")
		end

		def designations_report
			@month = params[:month_year].present? ? params[:month_year].delete(' ').split("-").first : Date.today.month
			@year = params[:month_year].present? ? params[:month_year].delete(' ').split("-").last : Date.today.year
			@designations_report = ProfitabilityReport.designations_report(@month, @year)

			get_profitability_reports_for(:designations_report, @designations_report, "designation_name_label")
		end
	end
end