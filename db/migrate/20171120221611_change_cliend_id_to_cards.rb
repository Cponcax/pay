class ChangeCliendIdToCards < ActiveRecord::Migration[5.1]
  def change
    rename_column :cards, :cliend_id, :client_id
  end
end
