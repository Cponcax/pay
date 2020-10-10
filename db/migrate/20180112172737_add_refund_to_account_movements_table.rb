class AddRefundToAccountMovementsTable < ActiveRecord::Migration[5.1]
  def change
    add_column :account_movements, :refund, :boolean, default: false
  end
end
