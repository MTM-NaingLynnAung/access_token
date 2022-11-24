class FacebookApiGateway
  class << self
    def get_auth_code(id, redirect_uri)
      url = "https://www.facebook.com/dialog/oauth?client_id=#{id}&redirect_uri=#{redirect_uri}"
      request = Typhoeus::Request.new(url, :followlocation => true, :ssl_verifypeer=>false, :ssl_verifyhost=>0)
    end

    def get_access_token(credentials, params, redirect_uri)
      app_id = credentials[0]
      app_secret = credentials[1]
      code = params[:code]
      client = OAuth2::Client.new(app_id, app_secret, {:token_url => 'https://graph.facebook.com/oauth/access_token', :redirect_uri => redirect_uri})
      access_token = client.auth_code.get_token(code, :redirect_uri => redirect_uri)
      
    end
  end
end
