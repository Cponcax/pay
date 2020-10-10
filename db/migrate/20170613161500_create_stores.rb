class CreateStores < ActiveRecord::Migration[5.1]
  def change
    create_table :stores do |t|
      t.string :name
      t.references :user, foreign_key: true#, default: SecureRandom.hex(12)
      t.string :uuid
      t.string :description
      t.string :phone
      t.string :phone_country_code
      t.string :address_one
      t.string :address_two
      t.string :city
      t.string :state
      t.string :country
      t.string :client_id
      t.string :postalcode
      t.timestamps
    end
    add_index :stores, :name, unique: true
    add_index :stores, :uuid, unique: true
  end
end
