class CreateMerchants < ActiveRecord::Migration[5.1]
  def change
    create_table :merchants do |t|
      t.string :corporate_name
      t.string :first_name
      t.string :last_name
      t.string :web_site_url
      t.string :phone
      t.string :country
      t.string :city
      t.string :email

      t.timestamps
    end
      add_index :merchants, :email, unique: true
  end
end
