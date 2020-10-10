class AddFieldCustomerIpToAccuntMovements < ActiveRecord::Migration[5.1]
  def change
    add_column :account_movements, :customer_ip, :string
  end
end
