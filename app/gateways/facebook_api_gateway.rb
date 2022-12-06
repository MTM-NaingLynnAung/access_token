class FacebookApiGateway
  class << self
    def get_auth_code(id, redirect_uri, params_definition, session, params)
      url = "https://www.facebook.com/dialog/oauth?client_id=#{id}&redirect_uri=#{redirect_uri}"

      client.ssl.verify = false
      response = client.get(url)
      begin
        LinkageService.set_session(params_definition, session, params)
        return response_data = { status: :unprocessable_entity } unless response.status == 302
        response_data = { status: :ok, redirect_uri: url } 
      rescue => exception
        flash[:alert] = "Something went wrong"
      end
      rescue Faraday::ConnectionFailed => e
        puts "----------------------#{e.message}"
      
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
