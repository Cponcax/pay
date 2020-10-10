class AddTransactionIdToCardMovements < ActiveRecord::Migration[5.1]
  def change
    add_column :card_movements, :transaction_id, :string
  end
end
