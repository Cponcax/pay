class RemoveIndexUserToMerchants < ActiveRecord::Migration[5.1]
  def change
    remove_index "merchants", name: "index_merchants_on_user_id"
  end
end
