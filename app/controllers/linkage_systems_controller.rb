class LinkageSystemsController < ApplicationController
  before_action :set_params_definition

  def index
   @linkage = LinkageService.index
  end

  def new
  end

  def create
    
    LinkageService.to_nil(session, @params_definition)

    request = LinkageService.get_auth_code(params[:"#{@params_definition.first.id}"])
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
      LinkageService.store(current_user, session, crypt, credentials, params, @params_definition.last.id)
    rescue => exception
      flash[:alert] = "#{exception.code.message}. Please try again"
      redirect_to new_linkage_system_path(definition: session[:definition])
    end

  end

  private

    def set_params_definition
      @params_definition = LinkageService.where(params[:definition])
    end
  
end
