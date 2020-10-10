class AddOrderIdToStores < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :order_id, :string
  end
end
