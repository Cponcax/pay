class AddSuspendedToStores < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :suspended, :boolean, default: false
  end
end
