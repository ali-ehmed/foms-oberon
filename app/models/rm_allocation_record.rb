# == Schema Information
#
# Table name: rm_allocation_records
#
#  id               :integer          not null, primary key
#  project_id       :integer          not null
#  employee_id      :string(255)      default("")
#  ishourly         :boolean
#  hours            :float(24)
#  month            :string(255)
#  year             :string(255)
#  percent_billing  :float(24)
#  project_name     :string(255)
#  employee_name    :string(255)
#  email            :string(100)
#  IsShadow         :boolean          default(FALSE)
#  start_date       :date
#  end_date         :date
#  no_of_days       :integer          default(0)
#  percentage_alloc :float(24)
#  LEAVES           :float(53)        default(0.0)
#  task_notes       :string(500)
#

class RmAllocationRecord < ActiveRecord::Base
end
