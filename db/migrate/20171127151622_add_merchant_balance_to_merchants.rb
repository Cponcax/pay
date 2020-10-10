class AddMerchantBalanceToMerchants < ActiveRecord::Migration[5.1]
  def change
    add_column :merchants, :merchant_balance, :string
  end
end
