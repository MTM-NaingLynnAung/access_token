class CreateLinkageSystems < ActiveRecord::Migration[6.1]
  def change
    create_table :linkage_systems do |t|
      t.string :label, :limit => 255, null: false
      t.integer :linkage_application_type, null: true, default: 5
      t.integer :status, default: 0, null: false
      t.text :error_message, null: true
      t.integer :created_by, null: true
      t.integer :updated_by, null: true
      t.timestamps
      t.datetime :modified_at, null: true
      t.datetime :deleted_at, null: true
    end
  end
end
