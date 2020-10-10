class CreateDocs < ActiveRecord::Migration[5.1]
  def change
    create_table :docs do |t|
      t.string :uuid
      t.string :document
      t.references :store, foreign_key: true
      t.string :uuid
      t.string :name
      t.string :type_file

      t.timestamps
    end
  end
end
