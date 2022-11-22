class CreateExternalServiceParameters < ActiveRecord::Migration[6.1]
  def change
    create_table :external_service_paramters do |t|
      t.references :external_service, foreign_key: true, index: { name: :external_service_id }
      t.references :external_service_parameter_definition, foreign_key: true, index: { name: :external_service_parameter_definition_id }
      t.text :parameter_value, null: true
      t.timestamps
      t.datetime :deleted_at, null: true
    end
  end
end
