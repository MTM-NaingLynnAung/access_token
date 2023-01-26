class ExternalService < ApplicationRecord
  has_many :external_service_parameters, :dependent => :destroy
  belongs_to :linkage_system
end
