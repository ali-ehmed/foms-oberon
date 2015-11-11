# == Schema Information
#
# Table name: dollar_rates
#
#  id          :integer          not null, primary key
#  month       :integer
#  year        :integer
#  dollar_rate :float(24)
#

class DollarRates < ActiveRecord::Base
end
