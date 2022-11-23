class LinkageSystemsController < ApplicationController
  def index
   @linkage = ExternalServiceDefinition.all
  end

  def new
    @params_definition = ExternalServiceParameterDefinition.where(external_service_definition_id: params[:definition])
    
  end

  def create
    session[:credentials] = nil
    @params_definition = ExternalServiceParameterDefinition.where(external_service_definition_id: params[:definition])
    
    # decrypted_back = crypt.decrypt_and_verify(encrypted_data)
    linkage = LinkageSystem.create!(
      label: params[:label],
      created_by: current_user.id,
      updated_by: current_user.id
    )
    external_service = ExternalService.create!(
      linkage_system_id: linkage.id,
      external_service_definition_id: params[:definition],
      created_by: current_user.id,
      updated_by: current_user.id
    )
    session[:external_service] = external_service.id
    external_service_parameter_definition = ExternalServiceParameterDefinition.where(external_service_definition_id: params[:definition]) 
    external_service_parameter_definition.each do |parameter_definition|
      external_service.external_service_parameters.create!(
        external_service_id: external_service.id,
        external_service_parameter_definition_id: parameter_definition.id,
        parameter_value: parameter_definition.is_encrypted == 0 ? params[:"#{parameter_definition.id}"] : crypt.encrypt_and_sign(params[:"#{parameter_definition.id}"])
      )
    end
    

    url = "https://www.facebook.com/dialog/oauth?client_id=#{credentials('app_id').parameter_value}&redirect_uri=http://localhost:3000/success"
    
    request = Typhoeus::Request.new(url, :followlocation => true, :ssl_verifypeer=>false, :ssl_verifyhost=>0)
    
    request.on_complete do |response|
      
      if response.success?
        # hell yeah
        puts '-------------------success--------------------'
        redirect_to request.base_url
      else
        # Received a non-successful http response.
        puts ("-----------------failure-----------------")
        render :new
      end
    end
    request.run


  end
  
end
