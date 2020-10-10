class CreateAccountMovements < ActiveRecord::Migration[5.1]
  def change
    create_table :account_movements do |t|
      t.string :confirmation_number
      t.string :transaction_id
      t.string :merchant_id
      t.string :terminal_id
      t.string :total_amount
      t.string :payment_status
      t.string :code
      t.string :description
      t.string :transaction_time
      t.references :store, foreign_key: true

      t.timestamps
    end
  end
end
