class AddFieldCreateDateToAccountMovements < ActiveRecord::Migration[5.1]
  def change
    add_column :account_movements, :created_date, :date
  end
end
