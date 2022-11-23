class LinkageSystem < ApplicationRecord
  has_one :external_service, :dependent => :destroy
end
