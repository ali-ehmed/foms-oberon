# == Schema Information
#
# Table name: divisions
#
#  id        :integer          default(0), not null, primary key
#  div_name  :string(255)
#  div_owner :string(255)
#

class Division < ActiveRecord::Base
	has_many :profitability_reports
end
