require 'json'
require 'oauth2'
class HomeController < ApplicationController
  def index
    app_id = credentials('app_id').parameter_value
    app_secret = crypt.decrypt_and_verify(credentials('app_secret').parameter_value)
    code = params[:code]
    client = OAuth2::Client.new(app_id, app_secret, {:token_url => 'https://graph.facebook.com/oauth/access_token', :redirect_uri => 'http://localhost:3000/success'})
    access_token = client.auth_code.get_token(code, :redirect_uri => 'http://localhost:3000/success')

    credentials('token').update!(parameter_value: access_token.token)
    
    render json: access_token
  end

end
