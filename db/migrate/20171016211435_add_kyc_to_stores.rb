class AddKycToStores < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :kyc, :boolean, default: false
  end
end
