class SetPrimaryKeyOfDivisions < ActiveRecord::Migration
  def change
  	execute "ALTER TABLE divisions ADD PRIMARY KEY (id);"
  end
end
