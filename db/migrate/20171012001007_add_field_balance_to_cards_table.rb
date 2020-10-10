class AddFieldBalanceToCardsTable < ActiveRecord::Migration[5.1]
  def change
    add_column :cards, :balance, :string
  end
end
