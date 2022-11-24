class LinkageRepository
  class << self
    def index
      ExternalServiceDefinition.all
    end
    
    def where(definition)
      ExternalServiceParameterDefinition.where(external_service_definition_id: definition)
    end

    def to_nil(session, params_definition)
      session[:label] = nil
      params_definition.each do |params_id|
        session[:"#{params_id.id}"] = nil
      end
    session[:definition] = nil
    end

    def set_session(params_definition, session, params)
      params_definition.each do |params_id|
        session[:"#{params_id.id}"] = params[:"#{params_id.id}"]
      end
      session[:label] = params[:label]
      session[:definition] = params[:definition]
    end

    def set_credentials(credentials, params_definition, session)
      params_definition.each do |params_id|
        credentials << session[:"#{params_id.id}"]
      end
    end

    def get_auth_code(id, redirect_uri)
      FacebookApiGateway.get_auth_code(id, redirect_uri)
    end

    def get_access_token(credentials, params, redirect_uri)
      access_token = FacebookApiGateway.get_access_token(credentials, params, redirect_uri)
    end

    def store(current_user, session, crypt, credentials, params, id, redirect_uri)
      access_token = FacebookApiGateway.get_access_token(credentials, params, redirect_uri)
      session[:"#{id}"] = access_token.token
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
      external_service_parameter_definition = LinkageRepository.where(session[:definition])
      external_service_parameter_definition.each do |parameter_definition|
        external_service.external_service_parameters.create!(
          external_service_id: external_service.id,
          external_service_parameter_definition_id: parameter_definition.id,
          parameter_value: parameter_definition.is_encrypted == 0 ? session[:"#{parameter_definition.id}"] : crypt.encrypt_and_sign(session[:"#{parameter_definition.id}"])
        )
      end
    end
  end
end
