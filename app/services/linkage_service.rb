class LinkageService
  class << self
    def view
      LinkageRepository.view
    end

    def find_params_definition(definition)
      LinkageRepository.find_params_definition(definition)
    end

    def set_nil(session, params_definition)
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

    def get_auth_code(id, redirect_uri, params_definition, session, params)
      FacebookApiGateway.get_auth_code(id, redirect_uri, params_definition, session, params)
    end

    def get_access_token(credentials, params, redirect_uri)
      FacebookApiGateway.get_access_token(credentials, params, redirect_uri)
    end

    def store(current_user, session, crypt, credentials, params, id, redirect_uri)
      LinkageRepository.store(current_user, session, crypt, credentials, params, id, redirect_uri)
    end

    def list(params)
      LinkageRepository.list(params)
    end

    def service_name(id)
      LinkageRepository.service_name(id)
    end

    def find_external_service(id)
      LinkageRepository.find_external_service(id)
    end

    def update(external_service, crypt, exist_params, input_params, params)
      LinkageRepository.update(external_service, crypt, exist_params, input_params, params)
    end

    def update_label(external_service, label)
      LinkageRepository.update_label(external_service, label)
    end

    def change(credentials, params, redirect_uri, id, session, crypt)
      LinkageRepository.change(credentials, params, redirect_uri, id, session, crypt)
    end

    def delete(id)
      external_service = LinkageRepository.find_external_service(id)
      LinkageRepository.delete(external_service.linkage_system)
    end

    def get_credentials(credentials, external_service, crypt)
      LinkageRepository.get_credentials(credentials, external_service, crypt)
    end

    def audience_create(params, credentials, subtype, description, customer_file_source, external_service)
      LinkageRepository.audience_create(params, credentials, subtype, description, customer_file_source,
                                        external_service)
    end

    def audience_update(params, credentials)
      LinkageRepository.audience_update(params, credentials)
    end

    def audience_user_create(file, external_service, crypt, service_report)
      LinkageRepository.audience_user_create(file, external_service, crypt, service_report)
    end

    def find_service_report(id)
      LinkageRepository.find_service_report(id)
    end
  end
end
