require 'facebookbusiness'
require 'csv'
require 'digest'
class LinkageSystemsController < ApplicationController
  before_action :set_params_definition, :find_external_service, :find_audience

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

  def show
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

  def audience_new
  end

  def audience_create
    begin
    credentials = []
    LinkageService.get_credentials(credentials, @external_service, crypt)
      service_report = LinkageService.audience_create(params, credentials, Constants::SUBTYPE, Constants::DESCRIPTION, Constants::CUSTOMER_FILE_SOURCE, @external_service)
      render json: service_report
    rescue => exception
      flash[:alert] = "Something went wrong. Please try again"
      render :audience_new
    end
  end

  def audience_edit
  end

  def audience_update
    begin
      credentials = []
      LinkageService.get_credentials(credentials, @external_service, crypt)
      LinkageService.audience_update(params, credentials, @audience)
      redirect_to linkage_system_path(@audience.external_service_id, definition: params[:definition]), notice: 'Audience was updated successfully'
    rescue => exception
      flash[:alert] = "Something went wrong. Please try again"
      render :audience_edit
    end
  end

  def audience_user
  end

  def audience_user_create
    if @audience.blank?
      flash[:alert] = 'Please create custom audience first'
      render :audience_user
    else
      begin
        email = []
        credentials = []
        custom_audience = LinkageService.audience_user_create(params[:file], email, credentials, @external_service, crypt, @audience)
        payload = { schema: "EMAIL_SHA256", data: email }
        deleted_user = custom_audience.users.destroy(payload: payload.to_json)
        created_user = custom_audience.users.create(payload: payload.to_json)
        render json: { deleted_user: deleted_user, created_user: created_user }
      rescue => exception
        flash[:alert] = 'Something went wrong. Please try again later'
        puts "------------------#{exception.message}"
        render :audience_user
      end
    end
    
  end

  private

    def set_params_definition
      @params_definition = LinkageService.where(params[:definition])
    end

    def find_external_service
      @external_service = LinkageService.find_external_service(params[:id])
    end

    def find_audience
      @audience = ExternalServiceAvailableReport.find_by(external_service_id: params[:id])
    end
  
end
