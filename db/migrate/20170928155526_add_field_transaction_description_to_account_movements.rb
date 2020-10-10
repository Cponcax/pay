class AddFieldTransactionDescriptionToAccountMovements < ActiveRecord::Migration[5.1]
  def change
    add_column :account_movements, :description_of_transaction, :string
  end
end
