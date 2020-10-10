class AddSuspendedToCards < ActiveRecord::Migration[5.1]
  def change
    add_column :cards, :suspended, :boolean, default: false
  end
end
