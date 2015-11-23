# == Schema Information
#
# Table name: payrolls
#
#  idpayroll          :integer          not null, primary key
#  month              :integer
#  year               :integer
#  startdate          :date
#  enddate            :date
#  iscomplete         :boolean
#  FloodSurchargeDays :integer          default(0)
#

class Payroll < ActiveRecord::Base

	scope :get_month_of_incompleted, -> { where("iscomplete != 1").order("idpayroll desc") }
	scope :get_year_of_incompleted, -> { where("iscomplete != 1").order("idpayroll desc") }

end
