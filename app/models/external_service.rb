class ExternalService < ApplicationRecord
  has_many :external_service_parameters
  belongs_to :linkage_system
end
