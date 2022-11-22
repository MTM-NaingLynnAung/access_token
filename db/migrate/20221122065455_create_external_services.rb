class CreateExternalServices < ActiveRecord::Migration[6.1]
  def change
    create_table :external_services do |t|
      t.references :linkage_system, index: true, foreign_key: true
      t.references :external_service_definition, foreign_key: true, index: { name: :external_service_definition_id }
      t.integer :created_by, null: false
      t.integer :updated_by, null: false
      t.timestamps
      t.datetime :deleted_at, null: true
    end
  end
end
