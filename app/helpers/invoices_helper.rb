module InvoicesHelper
	def employee_hours(invoice)
		if invoice.hours.present?
			link_to "javascript:void(0);", style: "text-decoration: none;", data: { toggle: "tooltip", placement: "top" }, title: "Click To Edit" do
				best_in_place invoice, :hours, :as => :input, :path => invoice_path(invoice.id), 
															:inner_class => "form-control"
			end
		else
			"---"
		end
	end

	def employee_billing(invoice)
		if invoice.percent_billing.present?
			link_to "javascript:void(0);", style: "text-decoration: none;", data: { toggle: "tooltip", placement: "top" }, title: "Click To Edit" do
				best_in_place invoice, :percent_billing, :as => :input, :path => invoice_path(invoice.id), 
															:inner_class => "form-control"
			end
		else
			"---"
		end
	end

	def employee_worked_days(invoice)
		link_to "javascript:void(0);", style: "text-decoration: none;", data: { toggle: "tooltip", placement: "top" }, title: "Click To Edit" do
			best_in_place invoice, :no_of_days, :as => :input, :path => invoice_path(invoice.id), 
															:inner_class => "form-control"
		end
	end

	def employee_description(invoice)
		link_to "javascript:void(0);", style: "text-decoration: none;", data: { toggle: "tooltip", placement: "top" }, title: "Click To Edit" do
			ok_button = "<i class=\"fa fa-check\"></i>".html_safe
			best_in_place invoice, :description, :as => :textarea, :path => invoice_path(invoice.id), 
															html_attrs: {:placeholder => "Description"}, 
															:inner_class => "form-control", 
															ok_button: "Save", 
															:ok_button_class => "btn btn-success btn-sm d_btn", 
															:cancel_button => "Cancel", 
															:cancel_button_class => "btn btn-sm btn-danger d_btn"
		end
	end
end
