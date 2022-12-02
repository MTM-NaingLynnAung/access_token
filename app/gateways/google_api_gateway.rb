class GoogleApiGateway
  class << self
    def get_google_auth_code(redirect_uri, id)
      url = "https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/spreadsheets&response_type=code&access_type=offline&redirect_uri=#{redirect_uri}&client_id=#{id}"
    end
    
    def get_google_access_token(credentials, params, redirect_uri)
      app_id = credentials[0]
      app_secret = credentials[1]
      code = params[:code]
      client = Signet::OAuth2::Client.new(
        :token_credential_uri =>
          'https://oauth2.googleapis.com/token',
        :client_id => app_id,
        :client_secret => app_secret,
        :grant_type => 'authorization_code',
        :redirect_uri => redirect_uri,
        :code => code
      )
    end
  end
end
