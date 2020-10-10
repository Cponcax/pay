class CreateAlerts < ActiveRecord::Migration[5.1]
  def change
    create_table :alerts do |t|
    	t.text :content
		t.datetime :valid_until
		t.timestamps
    end
  end
end
