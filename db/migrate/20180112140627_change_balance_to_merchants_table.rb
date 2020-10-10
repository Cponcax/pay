class ChangeBalanceToMerchantsTable < ActiveRecord::Migration[5.1]
  def change
    change_column :merchants, :balance, 'integer USING CAST(balance AS integer)', :default => 0
  end
end
