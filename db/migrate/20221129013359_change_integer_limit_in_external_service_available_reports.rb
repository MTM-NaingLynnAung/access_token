class ChangeIntegerLimitInExternalServiceAvailableReports < ActiveRecord::Migration[6.1]
  def change
    change_column :external_service_available_reports, :custom_audience_id, :integer, limit: 8
  end
end
