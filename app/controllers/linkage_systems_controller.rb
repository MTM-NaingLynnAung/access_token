class LinkageSystemsController < ApplicationController
  def index
   @linkage = ExternalServiceDefinition.all
  end

  def new
    @params_definition = ExternalServiceParameterDefinition.where(external_service_definition_id: params[:definition])
    
  end

  def create
    @params_definition = ExternalServiceParameterDefinition.where(external_service_definition_id: params[:definition])
    
    session[:label] = nil
    @params_definition.each do |params_id|
      session[:"#{params_id.id}"] = nil
    end
    session[:definition] = nil

    url = "https://www.facebook.com/dialog/oauth?client_id=#{params[:"#{@params_definition.first.id}"]}&redirect_uri=#{Constants::REDIRECT_URL}"
    
    request = Typhoeus::Request.new(url, :followlocation => true, :ssl_verifypeer=>false, :ssl_verifyhost=>0)
    request.run
    request.on_complete do |response|
      
      if response.success?
        @params_definition.each do |params_id|
          session[:"#{params_id.id}"] = params[:"#{params_id.id}"]
        end
        session[:label] = params[:label]
        session[:definition] = params[:definition]
        puts '-------------------success--------------------'
        redirect_to request.base_url
      else
        puts ("-----------------failure-----------------")
        render :new
      end
    end
    request.run

  end

  def store
    @params_definition = ExternalServiceParameterDefinition.where(external_service_definition_id: session[:definition])
    credentials = []
    @params_definition.each do |params_id|
      credentials << session[:"#{params_id.id}"]
    end
    begin
      app_id = credentials[0]
      app_secret = credentials[1]
      code = params[:code]
      client = OAuth2::Client.new(app_id, app_secret, {:token_url => 'https://graph.facebook.com/oauth/access_token', :redirect_uri => Constants::REDIRECT_URL})
      access_token = client.auth_code.get_token(code, :redirect_uri => Constants::REDIRECT_URL)
      session[:"#{@params_definition.last.id}"] = access_token.token
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
      external_service_parameter_definition = ExternalServiceParameterDefinition.where(external_service_definition_id: session[:definition]) 
      external_service_parameter_definition.each do |parameter_definition|
        external_service.external_service_parameters.create!(
          external_service_id: external_service.id,
          external_service_parameter_definition_id: parameter_definition.id,
          parameter_value: parameter_definition.is_encrypted == 0 ? session[:"#{parameter_definition.id}"] : crypt.encrypt_and_sign(session[:"#{parameter_definition.id}"])
        )
      end
    rescue => exception
      flash[:alert] = "#{exception.code.message}. Please try again"
      redirect_to new_linkage_system_path(definition: session[:definition])
    end

  end
  
end
