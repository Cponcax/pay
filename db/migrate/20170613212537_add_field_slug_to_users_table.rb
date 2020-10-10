class AddFieldSlugToUsersTable < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :uuid, :string, unique: true, index: true
  end
end
