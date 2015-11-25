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
	scope :get_month_and_year_of_incompleted, -> { select("month, year").where("iscomplete != 1").order("idpayroll desc") }
end
