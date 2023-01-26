class FacebookApiGateway
  class << self
    def get_auth_code(build_params)
      url = "https://www.facebook.com/dialog/oauth?client_id=#{build_params[:id]}&redirect_uri=#{build_params[:redirect_uri]}"

      client.ssl.verify = false
      response = client.get(url)
      begin
        LinkageService.set_session(build_params[:params_definition], build_params[:session], build_params[:params])
        return response_data = { status: :unprocessable_entity } unless response.status == 302

        response_data = { status: :ok, redirect_uri: url }
      rescue StandardError => e
        flash[:alert] = 'Something went wrong'
      end
    rescue Faraday::ConnectionFailed => e
      puts "----------------------#{e.message}"
    end

    def get_access_token(build_params)
      app_id = build_params[:credentials][0]
      app_secret = build_params[:credentials][1]
      code = build_params[:params][:code]
      client = OAuth2::Client.new(app_id, app_secret,
                                  { token_url: 'https://graph.facebook.com/oauth/access_token', redirect_uri: build_params[:redirect_uri] })
      access_token = client.auth_code.get_token(code, redirect_uri: build_params[:redirect_uri])
    end

    private

    def client
      @client ||= Faraday.new do |faraday|
        faraday.adapter :typhoeus
      end
    end
  end
end
