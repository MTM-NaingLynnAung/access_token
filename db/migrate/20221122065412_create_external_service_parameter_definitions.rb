class CreateExternalServiceParameterDefinitions < ActiveRecord::Migration[6.1]
  def change
    create_table :external_service_parameter_definitions do |t|
      t.references :external_service_definition, foreign_key: true, index: { name: :external_service_definition_id }
      t.string :name, :limit => 255, null: true
      t.string :key, :limit => 255, null: true
      t.integer :input_type, null: true
      t.string :description, :limit => 255, null: true
      t.integer :is_required, null: false
      t.integer :is_encrypted, null: false
      t.integer :is_displayed, null: false
      t.timestamps
    end
  end
end
