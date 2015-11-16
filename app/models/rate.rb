# == Schema Information
#
# Table name: rates
#
#  id               :integer          not null, primary key
#  designation_id   :integer
#  iscurrent        :boolean          default(TRUE)
#  revision_date    :datetime
#  team_based_rates :string(255)
#  hour_based_rates :string(255)
#

class Rate < ActiveRecord::Base

	belongs_to :designation

	validates_presence_of :designation_id, :team_based_rates, :hour_based_rates, on: :create

	def self.get_max_rate(designation_id)
		where("id=(SELECT MAX(id) FROM rates WHERE designation_id = '#{designation_id}')")
	end
end
