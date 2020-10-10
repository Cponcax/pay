class AddFieldsStreetCountryCityToAccountMovements < ActiveRecord::Migration[5.1]
  def change
    add_column :account_movements, :street, :string
    add_column :account_movements, :country, :string
    add_column :account_movements, :city, :string
    add_column :account_movements, :zip, :string
    add_column :account_movements, :region, :string

  end
end
