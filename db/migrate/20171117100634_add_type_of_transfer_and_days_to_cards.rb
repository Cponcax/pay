class AddTypeOfTransferAndDaysToCards < ActiveRecord::Migration[5.1]
  def change
    add_column :cards, :type_of_transfer, :boolean
    add_column :cards, :days, :string
  end
end
