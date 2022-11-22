class CreateExternalServiceDefinitions < ActiveRecord::Migration[6.1]
  def change
    create_table :external_service_definitions do |t|
      t.string :name, :limit => 255, null: true
      t.string :code, :limit => 255, null: true
      t.integer :user_oauth, null: false
      t.integer :active, null: false
      t.string :description, :limit => 255, null: false
      t.timestamps
    end
  end
end
