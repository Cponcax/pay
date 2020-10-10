class AddFieldsToMerchants < ActiveRecord::Migration[5.1]
  def change
    add_column :merchants, :merchant_id, :string
    add_column :merchants, :terminal_id, :string
    add_column :merchants, :private_key, :string
    add_column :merchants, :api_password, :string
    add_column :merchants, :currency, :string
  end
end
