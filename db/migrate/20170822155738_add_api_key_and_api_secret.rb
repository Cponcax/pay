class AddApiKeyAndApiSecret < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :api_key, :string
    add_column :stores, :api_secret, :string
  end
end
