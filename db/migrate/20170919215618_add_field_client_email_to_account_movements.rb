class AddFieldClientEmailToAccountMovements < ActiveRecord::Migration[5.1]
  def change
    add_column :account_movements, :client_email, :string
  end
end
