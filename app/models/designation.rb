# == Schema Information
#
# Table name: designations
#
#  designation_id :integer          not null, primary key
#  designation    :string(255)
#

class Designation < ActiveRecord::Base
	has_many :rates
	has_many :profitability_reports

	def designation_name
		designation
	end
end
