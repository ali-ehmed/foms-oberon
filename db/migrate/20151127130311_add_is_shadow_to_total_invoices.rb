class AddIsShadowToTotalInvoices < ActiveRecord::Migration
  def self.up
  	add_column :total_invoices, :is_shadow, :boolean, default: false
  end

  def self.down
  	remove_column :total_invoices, :is_shadow
  end
end
