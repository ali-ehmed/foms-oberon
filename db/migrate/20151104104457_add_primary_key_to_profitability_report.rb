class AddPrimaryKeyToProfitabilityReport < ActiveRecord::Migration
  def change
  	execute "ALTER TABLE profitability_reports ADD PRIMARY KEY (id);"
  end
end
