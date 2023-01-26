class ExternalServiceDefinition < ApplicationRecord
  has_many :external_service_parameter_definitions, :dependent => :destroy
end
