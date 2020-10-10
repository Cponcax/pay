class AddResponseCodeToCardMovements < ActiveRecord::Migration[5.1]
  def change
    add_column :card_movements, :response_code, :string
  end
end
