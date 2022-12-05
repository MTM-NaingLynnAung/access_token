class FacebookApiGateway
  class << self
    def get_auth_code(id, redirect_uri, params_definition, session, params)
      url = "https://www.facebook.com/dialog/oauth?client_id=#{id}&redirect_uri=#{redirect_uri}"

      client.ssl.verify = false
      response = client.get(url)
      begin
        LinkageService.set_session(params_definition, session, params)
        response_data = { status: :ok, redirect_uri: url }
      rescue => exception
        response_data = { status: :unprocessable_entity, redirect_uri: nil }
      rescue Faraday::ConnectionFailed => e
        puts "----------------------#{e.message}"
      end
    end

    def get_access_token(credentials, params, redirect_uri)
      app_id = credentials[0]
      app_secret = credentials[1]
      code = params[:code]
      client = OAuth2::Client.new(app_id, app_secret,
                                  { token_url: 'https://graph.facebook.com/oauth/access_token', redirect_uri: redirect_uri })
      access_token = client.auth_code.get_token(code, redirect_uri: redirect_uri)
    end

    private

    def client
      @client ||= Faraday.new do |faraday|
        faraday.adapter :typhoeus
      end
    end
  end
end
