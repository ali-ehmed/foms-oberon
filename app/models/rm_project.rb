# == Schema Information
#
# Table name: rm_projects
#
#  project_id              :integer          not null, primary key
#  name                    :string(255)      default(""), not null
#  status                  :string(100)
#  customer_name           :string(100)
#  customer_address        :string(100)
#  customer_personal_email :string(100)
#  customer_invoice_email  :string(100)
#  director_name           :string(100)
#

class RmProject < ActiveRecord::Base
end
