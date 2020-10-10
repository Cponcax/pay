class AddBalanceToMerchants < ActiveRecord::Migration[5.1]
  def change
    add_column :merchants, :balance, :string
  end
end
