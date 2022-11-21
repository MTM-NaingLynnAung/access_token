class FacebookCredential < ApplicationRecord
  def self.from_omniauth(params)
    create! do |credential|
      credential.app_id = params['app_id']
      credential.app_secret = params['app_secret']
    end
  end
  validates :app_id, presence: true 
  validates :app_secret, presence: true
end
