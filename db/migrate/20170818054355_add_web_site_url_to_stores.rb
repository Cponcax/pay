class AddWebSiteUrlToStores < ActiveRecord::Migration[5.1]
  def change
  	add_column :stores, :web_site_url, :string
  end
end
