class LinkageService
  class << self
    def index
      LinkageRepository.index
    end

    def where(definition)
      LinkageRepository.where(definition)
    end

    def to_nil(session, params_definition)
      LinkageRepository.to_nil(session, params_definition)
    end

    def set_session(params_definition, session, params)
      LinkageRepository.set_session(params_definition, session, params)
    end

    def set_credentials(credentials, params_definition, session)
      LinkageRepository.set_credentials(credentials, params_definition, session)
    end

    def get_auth_code(id, redirect_uri)
      LinkageRepository.get_auth_code(id, redirect_uri)
    end

    def get_access_token(credentials, params, redirect_uri)
      LinkageRepository.get_access_token(credentials, params, redirect_uri)
    end

    def store(current_user, session, crypt, credentials, params, id, redirect_uri)
      linkage = LinkageRepository.store(current_user, session, crypt, credentials, params, id, redirect_uri)
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


    def update(external_service, label, crypt, exist_params, input_params, params)
      LinkageRepository.update(external_service, label, crypt, exist_params, input_params, params)
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
      LinkageRepository.audience_create(params, credentials, subtype, description, customer_file_source, external_service)
    end

    def audience_update(params, credentials, audience)
      LinkageRepository.audience_update(params, credentials, audience)
    end
    
    def audience_user_create(file, email, credentials, external_service, crypt, audience)
      LinkageRepository.audience_user_create(file, email, credentials, external_service, crypt, audience)
    end

  end
end
