class RenameNameToMerchants < ActiveRecord::Migration[5.1]
  def change
    rename_column :merchants, :corporate_name, :name
  end
end
