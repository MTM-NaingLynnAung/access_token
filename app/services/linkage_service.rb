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

    def get_auth_code(id)
      LinkageRepository.get_auth_code(id)
    end

    def store(current_user, session, crypt, credentials, params, id)
      linkage = LinkageRepository.store(current_user, session, crypt, credentials, params, id)
    end
  end
end
