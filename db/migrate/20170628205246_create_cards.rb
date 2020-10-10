class CreateCards < ActiveRecord::Migration[5.1]
  def change
    create_table :cards do |t|
      t.string :uuid
      t.string :order_id
      t.string :card_id
      t.string :merchant_debit
      t.string :cardid_customer
      t.string :emboss_name
      t.string :card_number
      t.string :order_status
      t.string :expiration_date
      t.string :type_card
      t.string :product
      t.string :issued_time
      t.string :issued_date
      t.string :issued_by
      t.string :ammount_limit
      t.references :store, foreign_key: true
    end
  end
end
