class LinkageRepository
  class << self
    def index
      ExternalServiceDefinition.all
    end
    
    def new(params)
      ExternalServiceParameterDefinition.where(external_service_definition_id: params)
    end
  end
end
