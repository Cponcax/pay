class AddFieldApiSecretEncodedToStore < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :api_secret_encoded, :string, unique: true
  end
end
