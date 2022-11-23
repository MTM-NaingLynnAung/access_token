class LinkageSystemsController < ApplicationController
  def index
   @linkage = ExternalServiceDefinition.all
  end

  def new
    @params_definition = ExternalServiceParameterDefinition.where(external_service_definition_id: params[:definition])
    
  end

  def create
    session[:label] = nil
    session[:"1"] = nil
    session[:"2"] = nil
    session[:definition] = nil
    @params_definition = ExternalServiceParameterDefinition.where(external_service_definition_id: params[:definition])

    url = "https://www.facebook.com/dialog/oauth?client_id=#{params[:"1"]}&redirect_uri=#{Constants::REDIRECT_URL}"
    
    request = Typhoeus::Request.new(url, :followlocation => true, :ssl_verifypeer=>false, :ssl_verifyhost=>0)
    request.run
    response = request.response
    puts " ===================#{response.code} "
    request.on_complete do |response|
      
      if response.success?
        # hell yeah
        session[:label] = params[:label]
        session[:"1"] = params[:"1"]
        session[:"2"] = params[:"2"]
        session[:definition] = params[:definition]
        puts '-------------------success--------------------'
        redirect_to request.base_url
      else
        # Received a non-successful http response.
        puts ("-----------------failure-----------------")
        render :new
      end
    end
    request.run
    # decrypted_back = crypt.decrypt_and_verify(encrypted_data)
    # linkage = LinkageSystem.create!(
    #   label: params[:label],
    #   created_by: current_user.id,
    #   updated_by: current_user.id
    # )
    # external_service = ExternalService.create!(
    #   linkage_system_id: linkage.id,
    #   external_service_definition_id: params[:definition],
    #   created_by: current_user.id,
    #   updated_by: current_user.id
    # )
    # session[:external_service] = external_service.id
    # external_service_parameter_definition = ExternalServiceParameterDefinition.where(external_service_definition_id: params[:definition]) 
    # external_service_parameter_definition.each do |parameter_definition|
    #   external_service.external_service_parameters.create!(
    #     external_service_id: external_service.id,
    #     external_service_parameter_definition_id: parameter_definition.id,
    #     parameter_value: parameter_definition.is_encrypted == 0 ? params[:"#{parameter_definition.id}"] : crypt.encrypt_and_sign(params[:"#{parameter_definition.id}"])
    #   )
    # end
    

    


  end

  def store
    
    app_id = session[:"1"]
    app_secret = session[:"2"]
    code = params[:code]
    client = OAuth2::Client.new(app_id, app_secret, {:token_url => 'https://graph.facebook.com/oauth/access_token', :redirect_uri => Constants::REDIRECT_URL})
    access_token = client.auth_code.get_token(code, :redirect_uri => Constants::REDIRECT_URL)
    session[:"3"] = access_token.token
    linkage = LinkageSystem.create!(
      label: session[:label],
      created_by: current_user.id,
      updated_by: current_user.id
    )
    external_service = ExternalService.create!(
      linkage_system_id: linkage.id,
      external_service_definition_id: session[:definition],
      created_by: current_user.id,
      updated_by: current_user.id
    )
    session[:external_service] = external_service.id
    external_service_parameter_definition = ExternalServiceParameterDefinition.where(external_service_definition_id: session[:definition]) 
    external_service_parameter_definition.each do |parameter_definition|
      external_service.external_service_parameters.create!(
        external_service_id: external_service.id,
        external_service_parameter_definition_id: parameter_definition.id,
        parameter_value: parameter_definition.is_encrypted == 0 ? session[:"#{parameter_definition.id}"] : crypt.encrypt_and_sign(session[:"#{parameter_definition.id}"])
      )
    end


  end
  
end
