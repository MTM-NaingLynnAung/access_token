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
    session[:linkage_id] = nil
    end

    def set_session(params_definition, session, params)
      params_definition.each do |params_id|
        session[:"#{params_id.id}"] = params[:"#{params_id.id}"]
      end
      session[:label] = params[:label]
      session[:definition] = params[:definition]
      session[:linkage_id] = params[:id]
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

    def list(params)
      ExternalService.where(external_service_definition_id: params)
    end

    def service_name(id)
      ExternalServiceDefinition.find_by(id: id)
    end

    def find_external_service(id)
      ExternalService.find_by(linkage_system_id: id)
    end

    def update(external_service, label, crypt, exist_params, input_params, params)
      external_service.linkage_system.update(label: label)
      external_service.external_service_parameters.each do |params_value|
        if params_value.external_service_parameter_definition.is_displayed != 0
          decrypt_data = params_value.external_service_parameter_definition.is_encrypted == 0 ? params_value.external_service_parameter_definition.external_service_parameter.parameter_value : crypt.decrypt_and_verify(params_value.external_service_parameter_definition.external_service_parameter.parameter_value)
          exist_params << decrypt_data
          input_params << params[:"#{params_value.external_service_parameter_definition.id}"]
        end
      end
    end

    def change(credentials, params, redirect_uri, id, session, crypt)
      access_token = FacebookApiGateway.get_access_token(credentials, params, redirect_uri)
      session[:"#{id}"] = access_token.token

      external_service = LinkageRepository.find_external_service(session[:linkage_id])
      external_service.external_service_parameters.each do |params_value|
        params_value.update(
          parameter_value: params_value.external_service_parameter_definition.is_encrypted == 0 ? session[:"#{params_value.external_service_parameter_definition.id}"] : crypt.encrypt_and_sign(session[:"#{params_value.external_service_parameter_definition.id}"])
        )
      end
    end

    def delete(linkage)
      linkage.destroy
    end

  end
end
