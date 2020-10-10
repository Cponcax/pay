class AddUserRefToMerchants < ActiveRecord::Migration[5.1]
  def change
    add_reference :merchants, :store, foreign_key: true
  end
end
