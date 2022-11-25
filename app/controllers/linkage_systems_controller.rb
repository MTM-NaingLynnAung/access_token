class LinkageSystemsController < ApplicationController
  before_action :set_params_definition, :find_external_service

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

  def list
    @external_service = LinkageService.list(params[:definition])
    @service_name = LinkageService.service_name(params[:definition])
  end

  def edit
  end

  def update
    LinkageService.to_nil(session, @params_definition)
    exist_params = []
    input_params = []
    LinkageService.update(@external_service, params[:label], crypt, exist_params, input_params, params)
    if exist_params == input_params
      redirect_to linkage_systems_list_path(definition: params[:definition]), notice: "Linkage system updated successfully"
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
    @params_definition = LinkageService.where(session[:definition])
    credentials = []
    LinkageService.set_credentials(credentials, @params_definition, session)
    begin
      LinkageService.change(credentials, params, Constants::UPDATE_REDIRECT_URL, @params_definition.last.id, session, crypt)
    rescue => exception
      flash[:alert] = "#{exception.code.message}. Please try again"
      redirect_to edit_linkage_system_path(id: session[:linkage_id], definition: session[:definition])
    end
  end

  def destroy
    LinkageService.delete(params[:id])
    redirect_to linkage_systems_list_path(definition: session[:definition]), notice: 'Linkage was successfully deleted'
  end

  private

    def set_params_definition
      @params_definition = LinkageService.where(params[:definition])
    end

    def find_external_service
      @external_service = LinkageService.find_external_service(params[:id])
    end
  
end
