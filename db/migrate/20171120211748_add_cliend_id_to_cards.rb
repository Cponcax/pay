class AddCliendIdToCards < ActiveRecord::Migration[5.1]
  def change
    add_column :cards, :cliend_id, :string
  end
end
