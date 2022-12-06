class YahooApiGateway
  class << self
    def get_yahoo_auth_code(client_id, redirect_uri, params_definition, session, params)
      url = "https://biz-oauth.yahoo.co.jp/oauth/v1/authorize?response_type=code&client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=yahooads"
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

    def get_yahoo_access_token(credentials, redirect_uri, params)
      app_id = credentials[0]
      app_secret = credentials[1]
      code = params[:code]
      url = "https://biz-oauth.yahoo.co.jp/oauth/v1/token?grant_type=authorization_code&client_id=#{app_id}&client_secret=#{app_secret}&redirect_uri=#{redirect_uri}&code=#{code}"

      client.ssl.verify = false
      response = client.get(url)
      begin
        response_body = JSON.parse(response.body)
        return { status: response.status, access_token: nil } unless response.status == 200
        { status: :ok, access_token: response_body['access_token'] }

      rescue JSON::ParserError => e
        flash[:alert] =  'JSON ParserError for yahoo fetch_access_token'
      end

    rescue Faraday::ConnectionFailed => e
      puts "----------------------#{e.message}"

    end


    private

    def client
      @client ||= Faraday.new do |faraday|
        faraday.adapter :typhoeus
      end
    end
  end
end
