class CreateCardMovements < ActiveRecord::Migration[5.1]
  def change
    create_table :card_movements do |t|
      t.string :client_id
      t.string :order_id
      t.string :card_id
      t.string :total_amount
      t.references :card, foreign_key: true
    end
  end
end
