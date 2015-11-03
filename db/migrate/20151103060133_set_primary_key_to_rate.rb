class SetPrimaryKeyToRate < ActiveRecord::Migration
  def change
  	execute "ALTER TABLE rates ADD PRIMARY KEY (id);"
  end
end
