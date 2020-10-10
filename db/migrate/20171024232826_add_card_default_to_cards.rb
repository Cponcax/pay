class AddCardDefaultToCards < ActiveRecord::Migration[5.1]
  def change
    add_column :cards, :card_default, :boolean, default: :false
  end
end
