class CreateFacebookCredentials < ActiveRecord::Migration[6.1]
  def change
    create_table :facebook_credentials do |t|
      t.string :app_id
      t.string :app_secret
      t.text :access_token
      t.timestamps
    end
  end
end
