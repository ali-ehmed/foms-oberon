module InvoicesHelper
	#class
	def invoice_hours(invoice)
		"invoice_hours" if invoice.ishourly
	end

	def editable_for(field_name, invoice)
		case field_name
		when "rates".to_sym
			link_to "javascript:void(0);", style: "text-decoration: none;", data: { toggle: "tooltip", placement: "top" }, title: "Click To Edit" do
				best_in_place invoice, :rates, :as => :input, :path => invoice_path(invoice.id), 
															:inner_class => "form-control", placeholder: "---"
			end
		when "unpaid_leaves".to_sym
			link_to "javascript:void(0);", style: "text-decoration: none;", data: { toggle: "tooltip", placement: "top" }, title: "Click To Edit" do
				best_in_place invoice, :unpaid_leaves, :as => :input, :path => invoice_path(invoice.id), 
															:inner_class => "form-control", placeholder: "---"
			end
		when "amount".to_sym
			link_to "javascript:void(0);", style: "text-decoration: none;", data: { toggle: "tooltip", placement: "top" }, title: "Click To Edit" do
				best_in_place invoice, :amount, :as => :input, :path => invoice_path(invoice.id), 
															:inner_class => "form-control", placeholder: "---", html_attrs: { onchange: "calculateTotalData(this, 'amount');" }
			end
		when "reminder".to_sym
			link_to "javascript:void(0);", style: "text-decoration: none;", data: { toggle: "tooltip", placement: "top" }, title: "Click To Edit" do
				best_in_place invoice, :reminder, :as => :input, :path => invoice_path(invoice.id), 
															:inner_class => "form-control", placeholder: "---"
			end
		when "hours".to_sym
			if invoice.ishourly
				link_to "javascript:void(0);", style: "text-decoration: none;", data: { toggle: "tooltip", placement: "top" }, title: "Click To Edit" do
					best_in_place invoice, :hours, :as => :input, :path => invoice_path(invoice.id), 
																:inner_class => "form-control", placeholder: "---", html_attrs: { onchange: "calculateTotalData(this, 'hours');" }
				end
			else
				"---"
			end
		when "billing".to_sym
			if invoice.percent_billing.present?
				link_to "javascript:void(0);", style: "text-decoration: none;", data: { toggle: "tooltip", placement: "top" }, title: "Click To Edit" do
					best_in_place invoice, :percent_billing, :as => :input, :path => invoice_path(invoice.id), 
																:inner_class => "form-control"
				end
			else
				"---"
			end
		when "worked_days".to_sym
			if invoice.no_of_days.present?
				link_to "javascript:void(0);", style: "text-decoration: none;", data: { toggle: "tooltip", placement: "top" }, title: "Click To Edit" do
					best_in_place invoice, :no_of_days, :as => :input, :path => invoice_path(invoice.id), 
																	:inner_class => "form-control"
				end
			else

			end
		when "description".to_sym
			link_to "javascript:void(0);", style: "text-decoration: none;", data: { toggle: "tooltip", placement: "top" }, title: "Click To Edit" do
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
