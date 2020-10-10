class AddEmailToStores < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :email, :string
  end
end
