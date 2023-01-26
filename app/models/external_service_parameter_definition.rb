class ExternalServiceParameterDefinition < ApplicationRecord
  belongs_to :external_service_definition
  has_one :external_service_parameter
end
