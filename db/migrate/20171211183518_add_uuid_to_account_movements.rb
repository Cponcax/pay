class AddUuidToAccountMovements < ActiveRecord::Migration[5.1]
  def change
    add_column :account_movements, :uuid, :string
  end
end
