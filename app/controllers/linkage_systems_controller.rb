class LinkageSystemsController < ApplicationController
  def index
   @linkage = ExternalServiceDefinition.all
  end

  def new
    @params_definition = ExternalServiceParameterDefinition.where(external_service_definition_id: params[:definition])
    
  end

  def create
    
    linkage = LinkageSystem.create(
      label: params[:label],
      created_by: current_user.id,
      updated_by: current_user.id
    )
    external_service = ExternalService.create(
      linkage_system_id: linkage.id,
      external_service_definition_id: params[:definition],
      created_by: current_user.id,
      updated_by: current_user.id
    )
    external_service.external_service_parameters.create(
      external_service_id: external_service.id,
      external_service_definition_id: ExternalServiceParameterDefinition.where(external_service_definition_id: params[:definition])
    )
  end
  
end
