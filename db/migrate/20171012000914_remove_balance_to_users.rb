class RemoveBalanceToUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :balance, :string
  end
end
