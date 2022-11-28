class CreateExternalServiceAvailableReports < ActiveRecord::Migration[6.1]
  def change
    create_table :external_service_available_reports do |t|
      t.integer :external_service_id, null: false
      t.integer :service_type, null: false
      t.string :name, :limit => 255, null: false
      t.string :identifier, :limit => 255, null: false
      t.datetime :fetched_at, null: true
      t.timestamps
      t.datetime :deleted_at, null: true
      t.integer :custom_audience_id, null: true
    end
  end
end
