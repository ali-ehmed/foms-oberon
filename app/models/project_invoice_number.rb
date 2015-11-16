# == Schema Information
#
# Table name: project_invoice_numbers
#
#  id               :integer          not null, primary key
#  project_id       :integer
#  month            :integer
#  year             :integer
#  invoice_no       :string(50)
#  no_of_days       :integer          default(30)
#  net_payment_term :string(255)      default("Net 30 Days")
#  IsCurrencyDollar :boolean          default(TRUE)
#  dollar_rate      :float(24)        default(1.0)
#  invoice_date     :string(50)
#

class ProjectInvoiceNumber < ActiveRecord::Base
	scope :get_max_id, -> (project_id) { where("id = (
																							select max(id) 
																							from project_invoice_numbers 
																							where project_id='#{project_id}')") 
																			}


	def self.build_invoice_number(options = {})
		@month = options[:month]
		@year = options[:year]
		project_id = options[:project_id]
		total_days = options[:total_no_days]
    prev_dollar_rate = options[:prev_dollar_rate]

		@invoice_no_max_id = ProjectInvoiceNumber.get_max_id(project_id).first

		invoice_record = find_by_project_id_and_month_and_year(project_id, @month, @year)
    invoice_record.destroy if invoice_record
    if @invoice_no_max_id.blank?
      net_payment_term = "Net 30 Days"
    else
      net_payment_term = @invoice_no_max_id.net_payment_term
    end

    unless @invoice_no_max_id.blank?
      is_currency_dollar = @invoice_no_max_id.IsCurrencyDollar
    else
      is_currency_dollar = 1
    end

    if @invoice_no_max_id.blank?
      dollar_rate = 1
    else
      dollar_rate = @invoice_no_max_id.dollar_rate
    end

    invoice_number_attributes = {
      :project_id => project_id,
      :month => @month,
      :year => @year,
      :invoice_no => "",
      :net_payment_term => net_payment_term,
      :IsCurrencyDollar => is_currency_dollar,
      :dollar_rate =>  prev_dollar_rate,
      :no_of_days => total_days,
    }

    # if invoice_record.blank?
      ProjectInvoiceNumber.create(invoice_number_attributes)
    # else
    #   invoice_record.update_attributes(invoice_number_attributes)
    # end
	end
end	
