class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.integer :transactionable_id
      t.string  :transactionable_type
      t.string :transaction_id
      t.timestamps
    end
    add_index :transactions, [:transactionable_type, :transactionable_id],
              name: :idx_transactions_on_transactionable_type_transactionable
  end
end
