module InvoicesHelper
	PaymentTerms = ["Net 10 Days", "Net 15 Days", "Net 20 Days", "Net 30 Days", "Net 45 Days", "Net 60 Days", "Immediate"]
	Currency = ["PKR", "US$"]
	
	def invoice_hours(invoice)
		"invoice_hours" if invoice.ishourly
	end

	def editable_for(field_name, invoice)

		if invoice.IsAdjustment == false and invoice.IsShadow == true
			@title = "This Record is not editable"
		else
			@title = "Click To Edit"
		end

		link_to "javascript:void(0);", onclick: "isShadowCompatibility(this, #{invoice.attributes.to_json});", style: "text-decoration: none;", data: { toggle: "tooltip", placement: "top" }, title: @title do

			case field_name
			when "rates".to_sym
				if invoice.IsAdjustment == false and invoice.IsShadow == true
					"#{invoice.rates}"
				else
					best_in_place invoice, :rates, :as => :input, :path => invoice_path(invoice.id), 
																:inner_class => "form-control", placeholder: "---"
				end
			when "unpaid_leaves".to_sym
				if invoice.IsAdjustment == false and invoice.IsShadow == true
					"#{invoice.unpaid_leaves}"
				else
					best_in_place invoice, :unpaid_leaves, :as => :input, :path => invoice_path(invoice.id), 
																:inner_class => "form-control", placeholder: "---"
				end
			when "amount".to_sym
				if invoice.IsAdjustment == false and invoice.IsShadow == true
					"#{invoice.amount}"
				else
					best_in_place invoice, :amount, :as => :input, :path => invoice_path(invoice.id), 
																:inner_class => "form-control", placeholder: "---", html_attrs: { onchange: "calculateTotalData(this, 'amount');" }
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
																		:inner_class => "form-control", placeholder: "---", html_attrs: { onchange: "calculateTotalData(this, 'hours');" }
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
																		:inner_class => "form-control", placeholder: "---"
				end
			when "description".to_sym
				if invoice.IsAdjustment == false and invoice.IsShadow == true
					"#{invoice.description}"
				else
					ok_button = "<i class=\"fa fa-check\"></i>".html_safe
					best_in_place invoice, :description, :as => :textarea, :path => invoice_path(invoice.id), 
																	html_attrs: {:placeholder => "Description"}, 
																	:inner_class => "form-control", 
																	ok_button: "Save", 
																	:ok_button_class => "btn btn-success btn-sm d_btn", 
																	:cancel_button => "Cancel", 
																	:cancel_button_class => "btn btn-sm btn-danger d_btn",
																	placeholder: "---"
				end
			end
		end
	end
end
