class ChangeColumnIdentificationValueToUniqueTableUsers < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :identification_value, :string, unique: true
  end
end
