class AddCardBalanceToCards < ActiveRecord::Migration[5.1]
  def change
    add_column :cards, :card_balance, :string
  end
end
