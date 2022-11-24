class LinkageSystemsController < ApplicationController
  before_action :set_params_definition

  def index
   @linkage = LinkageService.index
  end

  def new
  end

  def create
    
    LinkageService.to_nil(session, @params_definition)
    request = LinkageService.get_auth_code(params[:"#{@params_definition.first.id}"], Constants::REDIRECT_URL)
    request.on_complete do |response|
      
      if response.success?
        LinkageService.set_session(@params_definition, session, params)
        redirect_to request.base_url
      else
        flash[:alert] = 'Something went wrong'
        render :new
      end
    end
    request.run
  end

  def store
    @params_definition = LinkageService.where(session[:definition])
    credentials = []
    LinkageService.set_credentials(credentials, @params_definition, session)
    begin
      LinkageService.store(current_user, session, crypt, credentials, params, @params_definition.last.id, Constants::REDIRECT_URL)
    rescue => exception
      flash[:alert] = "#{exception.code.message}. Please try again"
      redirect_to new_linkage_system_path(definition: session[:definition])
    end
  end

  def edit
    @external_service = ExternalService.find_by(external_service_definition_id: params[:definition])
  end

  def update
    @external_service = ExternalService.find_by(external_service_definition_id: params[:definition])
    @external_service.linkage_system.update(label: params[:label])

    parameter = []
    input_params = []
    @params_definition.each do |params_definition|
      if params_definition.is_displayed != 0
        decrypt_data = params_definition.is_encrypted == 0 ? params_definition.external_service_parameter.parameter_value : crypt.decrypt_and_verify(params_definition.external_service_parameter.parameter_value)
        parameter << decrypt_data
        input_params << params[:"#{params_definition.id}"]
      end
    end
    if parameter == input_params
      redirect_to linkage_systems_path, notice: "Linkage system updated successfully"
    else
      request = LinkageService.get_auth_code(params[:"#{@params_definition.first.id}"], Constants::UPDATE_REDIRECT_URL)
        request.on_complete do |response|
          if response.success?
            LinkageService.set_session(@params_definition, session, params)
            redirect_to request.base_url
          else
            flash[:alert] = 'Something went wrong'
            render :edit
          end
        end
      request.run
    end
    
  end

  def change
    @params_definition = ExternalServiceParameterDefinition.where(external_service_definition_id: session[:definition])
    credentials = []
    @params_definition.each do |params_id|
      credentials << session[:"#{params_id.id}"]
    end
    begin
      app_id = credentials[0]
      app_secret = credentials[1]
      code = params[:code]
      client = OAuth2::Client.new(app_id, app_secret, {:token_url => 'https://graph.facebook.com/oauth/access_token', :redirect_uri => Constants::UPDATE_REDIRECT_URL})
      access_token = client.auth_code.get_token(code, :redirect_uri => Constants::UPDATE_REDIRECT_URL)
      session[:"#{@params_definition.last.id}"] = access_token.token

      external_service = ExternalService.find_by(external_service_definition_id: session[:definition])
      @params_definition.each do |parameter_definition|
        external_service.external_service_parameters.create(
          external_service_id: external_service.id,
          external_service_parameter_definition_id: parameter_definition.id,
          parameter_value: parameter_definition.is_encrypted == 0 ? session[:"#{parameter_definition.id}"] : crypt.encrypt_and_sign(session[:"#{parameter_definition.id}"])
        )
        
      end


    rescue => exception
      flash[:alert] = "#{exception.code.message}. Please try again"
      redirect_to edit_linkage_system_path(definition: session[:definition])
    end
  end

  private

    def set_params_definition
      @params_definition = LinkageService.where(params[:definition])
    end
  
end
