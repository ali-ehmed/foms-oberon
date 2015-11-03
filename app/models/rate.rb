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
end
