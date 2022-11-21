require 'json'
require 'oauth2'
class HomeController < ApplicationController
  def index
    app_id = current_credentials.app_id
    app_secret = current_credentials.app_secret
    code = params[:code]
    # url = "https://graph.facebook.com/v15.0/oauth/access_token?client_id=#{app_id}&redirect_uri=http://localhost:3000/success&client_secret=#{app_secret}&code=#{code}"
    client = OAuth2::Client.new(app_id, app_secret, {:token_url => 'https://graph.facebook.com/oauth/access_token', :redirect_uri => 'http://localhost:3000/success'})
    access_token = client.auth_code.get_token(code, :redirect_uri => 'http://localhost:3000/success')
    current_credentials.access_token = access_token.token
    current_credentials.save!
    render json: access_token
    # puts "---------#{access_token.token}"
  end

end
