module Reports
	class ProfitabilityReportsController < BaseController
		def division_report
			@month = params[:month_year].present? ? params[:month_year].delete(' ').split("-").first : Date.today.month
			@year = params[:month_year].present? ? params[:month_year].delete(' ').split("-").last : Date.today.year

			@division_report = ProfitabilityReport.division_report(@month, @year)

			divisions = Divisions.all

			# Graphical Report
			# Revenue
	    @revenue = Array.new
	    revenue_report_array = []

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
	    end
	    @revenue << { graph_data: revenue_report_array } 
	    @max_ammount = @revenue.second[:graph_data].map{|m| m.values.first}.max{ |a,b| (a || 0) <=> (b || 0) }
  		
  		# Expense
	    @expense = Array.new
	    expense_report_array = []

	    @expense << { graph_name: "Expense" }
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
	    end

	    @profit << { graph_data: profit_report_array }
      @loss << { graph_data: loss_report_array }

      @max_profit_for_profit = @profit.second[:graph_data].map{|m| m.values.first}.max{ |a,b| (a || 0) <=> (b || 0) }
      @max_profit_for_loss = @loss.second[:graph_data].map{|m| m.values.first}.max{ |a,b| (a || 0) <=> (b || 0) }

      # Tabular Report
      @tabular_data = Array.new
      @revenue.second[:graph_data].each do |revenue_data|
      	@tabular_data << revenue_data
      end
      @expense.second[:graph_data].each do |expense_data|
      	@tabular_data << expense_data
      end
      @profit.second[:graph_data].each do |profit_data|
      	@tabular_data << profit_data
      end
      @loss.second[:graph_data].each do |loss_data|
      	@tabular_data << loss_data
      end
      @tabular_data = @tabular_data.group_by { |d| d[:label] }
		end
	end
end