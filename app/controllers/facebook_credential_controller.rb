class FacebookCredentialController < ApplicationController
  def new
  end
  
  def create
    session[:credential] = nil
    credential = FacebookCredential.from_omniauth(params)
    session[:credential] = credential.id
    url = "https://www.facebook.com/dialog/oauth?client_id=#{params[:app_id]}&redirect_uri=http://localhost:3000/success"
    
    request = Typhoeus::Request.new(url, :followlocation => true, :ssl_verifypeer=>false, :ssl_verifyhost=>0)
    
    request.on_complete do |response|
      
      if response.success?
        # hell yeah
        puts '-------------------success--------------------'
        redirect_to request.base_url
      elsif response.code == 0
        # Could not get an http response, something's wrong.
        puts ("=========================#{response.return_message}")
      else
        # Received a non-successful http response.
        puts ("-----------------failure-----------------")
        render :new
      end
    end
    request.run
  end
end
