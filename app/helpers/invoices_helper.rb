module InvoicesHelper
	PaymentTerms = ["Net 10 Days", "Net 15 Days", "Net 20 Days", "Net 30 Days", "Net 45 Days", "Net 60 Days", "Immediate"]
	Currency = ["PKR", "US$"]
	
	def invoice_hours(invoice)
		"invoice_hours" if invoice.ishourly
	end

	def hourly_or_non_hourly(generated_invoice)
		return "---" if generated_invoice[:hours].blank? and generated_invoice[:percent_billing].blank?

		if generated_invoice[:ishourly] == true
			pluralize(generated_invoice[:hours], 'hr')
		else
			"#{generated_invoice[:percent_billing]} %"
		end
	end

	def generated_invoice_rates(generated_invoice)
		return "---" if generated_invoice[:hours].blank? and generated_invoice[:percent_billing].blank?

		if generated_invoice[:ishourly] == true
			rate_type = "hour"
		else
			rate_type = "month"
		end
		
		"#{generated_invoice[:rates]} / #{rate_type}"
	end

	def invoice_description(generated_invoice)
		html = ""
		html += "<strong>#{generated_invoice[:description][:full_name]} - #{generated_invoice[:description][:designation]}</strong>"
		html += " - #{generated_invoice[:description][:task_notes]}" if generated_invoice[:description][:task_notes].present?
		html += "<br />"
		html += "#{generated_invoice[:description][:duration].blank? ? "---" : generated_invoice[:description][:duration]}"

		html.html_safe
	end

	def currency_label(currency)
		if currency == false
			"PKR"
		else
			"US$"
		end
	end


	def invoice_result(invoice, status)
		case status
		when "fetch".to_sym
			if invoice.is_fetched? == "fetched".to_sym 
				invoice.project_name
			else 
				"---"
			end
		when "processed".to_sym
			if invoice.is_processed? == "processed".to_sym 
				invoice.project_name
			else 
				"---"
			end
		when "unprocessed".to_sym
			if invoice.is_unprocessed? == "unprocessed".to_sym 
				invoice.project_name
			else 
				"---"
			end
		end
	end

	def fetched_invoice(invoice)
		if invoice.is_fetched? == "fetched".to_sym 
			invoice.project_name
		else 
			"---"
		end
	end

	def fetched_invoice(invoice)
		if invoice.is_fetched? == "fetched".to_sym 
			invoice.project_name
		else 
			"---"
		end
	end

	def editable_for(field_name, invoice, count = "")

		if invoice.IsAdjustment == false and invoice.IsShadow == true
			@title = "This Record is not editable"
		else
			@title = "Click To Edit"
			if field_name == "hours".to_sym
				if invoice.ishourly == true
					@title = "Click To Edit"
				else
					@title = "This is a non hourly employee"
				end
			end
		end

		link_to "javascript:void(0);", onkeydown: "activateOnEnterKey(event);", onclick: "isShadowCompatibility(this, #{invoice.attributes.to_json});", style: "text-decoration: none;", data: { toggle: "tooltip", placement: "top" }, title: @title do

			case field_name
			when "rates".to_sym
				if invoice.IsAdjustment == false and invoice.IsShadow == true
					"#{invoice.rates}"
				else
					best_in_place invoice, :rates, :as => :input, :path => invoice_path(invoice.id), 
																:inner_class => "form-control", placeholder: "---", html_attrs: { onchange: "updateAmount(this, 'rates', #{count});" }
				end
			when "unpaid_leaves".to_sym
				if invoice.IsAdjustment == false and invoice.IsShadow == true
					"#{invoice.unpaid_leaves}"
				else
					best_in_place invoice, :unpaid_leaves, :as => :input, :path => invoice_path(invoice.id), 
																:inner_class => "form-control", placeholder: "---", html_attrs: { onchange: "updateAmount(this, 'unpaid_leaves', #{count});" }
				end
			when "amount".to_sym
				if invoice.IsAdjustment == false and invoice.IsShadow == true
					"#{invoice.amount}"
				else
					best_in_place invoice, :amount, :as => :input, :path => invoice_path(invoice.id), 
																:inner_class => "form-control", placeholder: "---", html_attrs: { onchange: "calculateTotalData(this, 'amount'); updateRates(this, #{count});" }
        end
			when "reminder".to_sym
				if invoice.IsAdjustment == false and invoice.IsShadow == true
					invoice.reminder.present? ? "#{invoice.reminder}" : "---"
				else
					best_in_place invoice, :reminder, :as => :input, :path => invoice_path(invoice.id), 
																:inner_class => "form-control", placeholder: "---"
				end
			when "hours".to_sym
				if invoice.IsAdjustment == false and invoice.IsShadow == true
					invoice.hours.present? ? "#{invoice.hours}" : "---"
				else
					if invoice.ishourly
						best_in_place invoice, :hours, :as => :input, :path => invoice_path(invoice.id), 
																		:inner_class => "form-control", placeholder: "---", html_attrs: { onchange: "calculateTotalData(this, 'hours'); updateAmount(this, 'hours', #{count});" }
					else
						"---"
					end
				end
			when "billing".to_sym
				if invoice.IsAdjustment == false and invoice.IsShadow == true
					"#{invoice.percent_billing}"
				else
					best_in_place invoice, :percent_billing, :as => :input, :path => invoice_path(invoice.id), 
																		:inner_class => "form-control", placeholder: "---"
				end
			when "worked_days".to_sym
				if invoice.IsAdjustment == false and invoice.IsShadow == true
					"#{invoice.no_of_days}"
				else
					best_in_place invoice, :no_of_days, :as => :input, :path => invoice_path(invoice.id), 
																		:inner_class => "form-control", placeholder: "---", html_attrs: { onchange: "updateAmount(this, 'no_of_days', #{count});" }
				end
			when "description".to_sym
				if invoice.IsAdjustment == false and invoice.IsShadow == true
					"#{invoice.description}"
				else
					ok_button = "<i class=\"fa fa-check\"></i>".html_safe
					best_in_place invoice, :description, :as => :textarea, :path => invoice_path(invoice.id), 
																	html_attrs: {:placeholder => "Description"}, 
																	:inner_class => "form-control",
																	placeholder: "---"

																	# ok_button: "Save", 
																	# :ok_button_class => "btn btn-success btn-sm d_btn", 
																	# :cancel_button => "Cancel", 
																	# :cancel_button_class => "btn btn-sm btn-danger d_btn",
				end
			end
		end
	end
end
