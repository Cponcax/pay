class AddFieldsUserDevise < ActiveRecord::Migration[5.1]
  def change
      add_column :users, :birthday, :string
      add_column :users, :nationality, :string
      add_column :users, :last_name, :string
      add_column :users, :first_name, :string
      add_column :users, :title, :string
      add_column :users, :identification_type, :string
      add_column :users, :identification_value, :string

  end
end
