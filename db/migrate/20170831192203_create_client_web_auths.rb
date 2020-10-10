class CreateClientWebAuths < ActiveRecord::Migration[5.1]
  def change
    create_table :client_web_auths do |t|
      t.string :name
      t.string :exp
      t.string :iat
      t.string :iss
      t.string :token
      t.string :hmac_secret

      t.timestamps
    end
  end
end
