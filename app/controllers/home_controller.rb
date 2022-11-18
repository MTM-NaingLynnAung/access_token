require 'json'
class HomeController < ApplicationController
  def index
    app_id = current_credentials.app_id
    app_secret = current_credentials.app_secret
    code = params[:code]
    url = "https://graph.facebook.com/v15.0/oauth/access_token?client_id=#{app_id}&redirect_uri=http://localhost:3000/success&client_secret=#{app_secret}&code=#{code}"
    redirect_to url
  end

end
