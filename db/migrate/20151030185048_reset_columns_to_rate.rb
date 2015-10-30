class ResetColumnsToRate < ActiveRecord::Migration
  def change
  	remove_column :rates, :team_based_rates
  	remove_column :rates, :hour_based_rates

  	add_column :rates, :team_based_rates, :string
  	add_column :rates, :hour_based_rates, :string
  end
end
