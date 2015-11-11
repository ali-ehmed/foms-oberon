# == Schema Information
#
# Table name: variables
#
#  VariableName :string(50)
#  Value        :string(255)      default("0")
#  id           :integer          not null, primary key
#

class Variable < ActiveRecord::Base
end
