module Reports
	class BaseController < ApplicationController
		before_action :authenticate_user!

		def listing
			respond_to do |format|
				format.html { render :template => "/reports/listing" }
			end
		end

		def get_profitability_reports_for(report_name = "", profitability_reports = [], graph_label_name = "", graph_data = [])
			logger.debug "-----------Generating #{report_name.to_s.capitalize}--------------"

			@tabular_data = Array.new
			# Revenue
	    @revenue = Array.new
	    revenue_report_array = []
	    

	    @revenue << { graph_name: graph_data.present? ? graph_data.first : "Revenue" }
	    profitability_reports.each do |report|
	    	
	      if graph_label_name == :project_name_label.to_s
	      	label_name = RmProject.get_project_name report.project_id unless report.project_id.nil?
	      elsif graph_label_name == :designation_name_label.to_s
	      	label_name = report.designation_id.nil? ? "---" : Designation.find(report.designation_id).designation
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

	    @expense << { graph_name: graph_data.present? ? graph_data[1] : "Expense" }
	    profitability_reports.each do |report|
	      if graph_label_name == :project_name_label.to_s
	      	label_name = RmProject.get_project_name report.project_id unless report.project_id.nil?
	      elsif graph_label_name == :designation_name_label.to_s
	      	label_name = report.designation_id.nil? ? "---" : Designation.find(report.designation_id).designation
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

	    @loss << { graph_name: graph_data.present? ? graph_data[2] : "Loss" }
	    @profit << { graph_name: graph_data.present? ? graph_data[3] : "Profit" }


	    profitability_reports.each do |report|
	      if graph_label_name == :project_name_label.to_s
	      	label_name = RmProject.get_project_name report.project_id unless report.project_id.nil?
	      elsif graph_label_name == :designation_name_label.to_s
	      	label_name = report.designation_id.nil? ? "---" : Designation.find(report.designation_id).designation
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