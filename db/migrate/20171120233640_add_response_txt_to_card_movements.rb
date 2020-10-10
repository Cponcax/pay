class AddResponseTxtToCardMovements < ActiveRecord::Migration[5.1]
  def change
    add_column :card_movements, :response_txt, :string
  end
end
