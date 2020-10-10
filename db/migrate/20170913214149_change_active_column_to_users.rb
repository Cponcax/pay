class ChangeActiveColumnToUsers < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :active, :boolean, default: false
  end
end
