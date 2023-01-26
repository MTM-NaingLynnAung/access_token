class ExternalServiceParameter < ApplicationRecord
  belongs_to :external_service
  belongs_to :external_service_parameter_definition
end
