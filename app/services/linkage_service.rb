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
  end
end
