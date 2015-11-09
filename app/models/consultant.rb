# == Schema Information
#
# Table name: consultants
#
#  id          :integer          not null, primary key
#  employee_id :integer
#  month       :integer
#  year        :integer
#  cogs        :float(24)
#  opex        :float(24)
#

class Consultant < ActiveRecord::Base
end
