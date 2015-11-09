module Reports
	class BaseController < ApplicationController
		before_action :authenticate_user!

		def listing
			respond_to do |format|
				format.html { render :template => "/reports/listing" }
			end
		end

		def generate_profitability_report_for(options = {}, report_name = "", get_report_id = false, &block)

			if get_report_id == true
				ids = []
				options.fetch(:report_for_ids).each do |report|
					ids << report.id
				end
				return ids
			end

			logger.debug "!------Generating #{report_name}--------!"

			@tabular_data = Array.new
			# Revenue
	    @revenue = Array.new
	    revenue_report_array = []
	    profitability_reports = []

	    @revenue << { graph_name: options.has_key?(:graph_label_name) ? "#{options.fetch(:graph_label_name)[0]}" : "Revenue" }
	    options.fetch(:report).each do |report|

	      if block_given?
      		label_name = yield report
	      end

	      data_points = {
      		y: report.amount.to_i,
      		label: label_name   	
	      }
	      revenue_report_array << data_points
	      @tabular_data << data_points
	    end

	    @revenue << { graph_data: revenue_report_array } 
	    @max_ammount = @revenue.second[:graph_data].map{|m| m.values.first}.max{ |a,b| (a || 0) <=> (b || 0) }

			# Expense
			@expense = Array.new
	    expense_report_array = []

	    @expense << { graph_name: options.has_key?(:graph_label_name) ? "#{options.fetch(:graph_label_name)[1]}" : "Expense" }
	    options.fetch(:report).each do |report|

	      if block_given?
      		label_name = yield report
	      end

	      calculated_expense = report.cogs.to_i + report.opexp.to_i
	      data_points = {
      		y: calculated_expense,
      		label: label_name   	
	      }
	      expense_report_array << data_points
	      @tabular_data << data_points
	    end

	    @expense << { graph_data: expense_report_array }
	    @max_calculated_expense = @expense.second[:graph_data].map{|m| m.values.first}.max{ |a,b| (a || 0) <=> (b || 0) }


	    # Profit & Loss
	    @profit = Array.new
	    @loss = Array.new
	    loss_report_array = []
	    profit_report_array = []

	    @loss << { graph_name: options.has_key?(:graph_label_name) ? "#{options.fetch(:graph_label_name)[2]}" : "Loss" }
	    @profit << { graph_name: options.has_key?(:graph_label_name) ? "#{options.fetch(:graph_label_name)[3]}" : "Profit" }


	    options.fetch(:report).each do |report|

	      if block_given?
	      	label_name = yield report
	      end

	      if report.profit.to_f > 0
	        data_points_for_profit = {
	      		y: report.profit.to_i,
	      		label: label_name   	
		      }
		      data_points_for_loss = {
	      		y: 0,
	      		label: label_name   	
		      }
		      loss_report_array << data_points_for_loss
	    		profit_report_array << data_points_for_profit
	      else
	        data_points_for_profit = {
	      		y: 0,
	      		label: label_name   	
		      }
		      data_points_for_loss = {
	      		y: report.profit.to_i.abs,
	      		label: label_name   	
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
	end
end