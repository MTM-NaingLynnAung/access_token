require 'facebookbusiness'
require 'csv'
require 'digest'
require 'json'

require 'google/apis/drive_v2'
require 'google/api_client/client_secrets'
class LinkageSystemsController < ApplicationController
  before_action :set_params_definition, :find_external_service, :find_service_report

  def index
    @linkage = LinkageService.view
  end

  def new; end

  def create
    if params[:label].blank? || params[:"1"].blank? || params[:"2"].blank?
      flash[:alert] = "Something went wrong. Please try again"
      render :new
    else
    LinkageService.set_nil(session, @params_definition)
    response_data = LinkageService.get_auth_code(params[:"#{@params_definition.first.id}"], Constants::REDIRECT_URL,
                                                 @params_definition, session, params)

      if response_data[:status] == :ok
        redirect_to response_data[:redirect_uri]
      else
        flash[:alert] = 'Something went wrong'
        render :new
      end
    end
  end

  def store
    @params_definition = LinkageService.find_params_definition(session[:definition])
    credentials = []
    LinkageService.set_credentials(credentials, @params_definition, session)
    begin
      LinkageService.get_facebook_access_token(credentials, params, Constants::REDIRECT_URL, session, @params_definition.last.id)
      LinkageService.store(current_user, session, crypt)
      LinkageService.set_nil(session, @params_definition)
    rescue StandardError => e
      flash[:alert] = "#{e.code.message}. Please try again"
      redirect_to new_linkage_system_path(definition: session[:definition])
    end
  end

  def list
    @external_service = LinkageService.list(params[:definition])
    @service_name = LinkageService.service_name(params[:definition])
  end

  def show; end

  def edit; end

  def update
    LinkageService.set_nil(session, @params_definition)
    exist_params = []
    input_params = []
    LinkageService.update(@external_service, crypt, exist_params, input_params, params)
    if exist_params == input_params
      LinkageService.update_label(@external_service, params[:label])
      redirect_to linkage_systems_list_path(definition: params[:definition]),
                  notice: 'Linkage system updated successfully'
    else
      response_data = LinkageService.get_auth_code(params[:"#{@params_definition.first.id}"],
                                                   Constants::UPDATE_REDIRECT_URL, @params_definition, session, params)
      if response_data.handled_response[:status] == :ok
        redirect_to response_data.handled_response[:redirect_uri]
      else
        flash[:alert] = 'Something went wrong'
        render :edit
      end
    end
  end

  def change
    @params_definition = LinkageService.find_params_definition(session[:definition])
    credentials = []
    LinkageService.set_credentials(credentials, @params_definition, session)
    begin
      LinkageService.get_facebook_access_token(credentials, params, Constants::UPDATE_REDIRECT_URL, session, @params_definition.last.id)
      LinkageService.change(session, crypt)
      LinkageService.set_nil(session, @params_definition)
    rescue StandardError => e
      flash[:alert] = "#{e.code.message}. Please try again"
      redirect_to edit_linkage_system_path(id: session[:linkage_id], definition: session[:definition])
    end
  end

  def destroy
    LinkageService.delete(params[:id])
    redirect_to linkage_systems_list_path(definition: session[:definition]), notice: 'Linkage was successfully deleted'
  end

  def audience_new; end

  def audience_create
    credentials = []
    LinkageService.get_credentials(credentials, @external_service, crypt)
    service_report = LinkageService.audience_create(params, credentials, Constants::SUBTYPE, Constants::DESCRIPTION,
                                                    Constants::CUSTOMER_FILE_SOURCE, @external_service)
    render json: service_report
  rescue StandardError => e
    flash[:alert] = 'Something went wrong. Please try again'
    render :audience_new
  end

  def audience_edit; end

  def audience_update
    if params[:name].blank? || params[:ad_id].blank?
      flash[:alert] = 'Something went wrong. Please try again'
      render :audience_edit
    else
      begin
        credentials = []
        LinkageService.get_credentials(credentials, @external_service, crypt)
        LinkageService.audience_update(params, credentials)
        redirect_to linkage_system_path(@service_report.external_service_id, definition: params[:definition]),
                    notice: 'Audience was updated successfully'
      rescue StandardError => e
        flash[:alert] = 'Something went wrong. Please try again'
        render :audience_edit
      end
    end
  end

  def audience_user; end

  def audience_user_create
    if @service_report.blank?
      flash[:alert] = 'Please create custom audience first'
      render :audience_user
    else
      begin
        response = LinkageService.audience_user_create(params[:file], @external_service, crypt, @service_report)
        render json: response
      rescue StandardError => e
        flash[:alert] = 'Something went wrong. Please try again later'
        render :audience_user
      end
    end
  end

  def create_google
    if params[:label].blank? || params[:"4"].blank? || params[:"5"].blank?
      flash[:alert] = "Something went wrong. Please try again"
      render :new
    else
      LinkageService.set_nil(session, @params_definition)
      LinkageService.set_session(@params_definition, session, params)
      url = LinkageService.get_google_auth_code(Constants::GOOGLE_REDIRECT_URL, params[:"#{@params_definition.first.id}"])
      redirect_to url
    end
  end
  
  def store_google
    @params_definition = LinkageService.find_params_definition(session[:definition])
    begin
      credentials = []
      LinkageService.set_credentials(credentials, @params_definition, session)
      LinkageService.get_google_access_token(credentials, params, Constants::GOOGLE_REDIRECT_URL, session, @params_definition.last.id)
      LinkageService.store(current_user, session, crypt)
    rescue => exception
      flash[:alert] = "#{exception.message}. Please try again"
      redirect_to new_linkage_system_path(definition: session[:definition])
    end    
  end

  def update_google
    if params[:label].blank? || params[:"4"].blank? || params[:"5"].blank?
      flash[:alert] = "Something went wrong. Please try again"
      render :edit
    else
      LinkageService.set_nil(session, @params_definition)
      LinkageService.set_session(@params_definition, session, params)
      exist_params = []
      input_params = []
      LinkageService.update(@external_service, crypt, exist_params, input_params, params)
      if exist_params == input_params
        LinkageService.update_label(@external_service, params[:label])
        redirect_to linkage_system_path(id: params[:id], definition: params[:definition]),
                    notice: 'Linkage system updated successfully'
      else
        url = LinkageService.get_google_auth_code(Constants::GOOGLE_UPDATE_REDIRECT_URL, params[:"#{@params_definition.first.id}"])
        redirect_to url
      end
    end
  end

  def google_update_change
    @params_definition = LinkageService.find_params_definition(session[:definition])
    begin
      credentials = []
      LinkageService.set_credentials(credentials, @params_definition, session)
      LinkageService.get_google_access_token(credentials, params, Constants::GOOGLE_UPDATE_REDIRECT_URL, session, @params_definition.last.id)
      LinkageService.change(session, crypt)
    rescue StandardError => e
      flash[:alert] = "#{e.message}. Please try again"
      redirect_to edit_linkage_system_path(id: session[:linkage_id], definition: session[:definition])
      end
  end

  def create_yahoo
    if params[:label].blank? || params[:"7"].blank? || params[:"8"].blank?
      flash[:alert] = "Something went wrong. Please try again"
      redirect_to new_linkage_system_path(definition: params[:definition])
    else
      LinkageService.set_nil(session, @params_definition)
      response_data = LinkageService.get_yahoo_auth_code(params[:"#{@params_definition.first.id}"], Constants::YAHOO_REDIRECT_URL, @params_definition, session, params)
      if response_data[:status] == :ok
        redirect_to response_data[:redirect_uri]
      else
        flash[:alert] = 'Something went wrong'
        redirect_to new_linkage_system_path(definition: session[:definition])
      end
    end
  end

  def store_yahoo
    @params_definition = LinkageService.find_params_definition(session[:definition])
    credentials = []
    LinkageService.set_credentials(credentials, @params_definition, session)
    response = LinkageService.get_yahoo_access_token(credentials, Constants::YAHOO_REDIRECT_URL, params, session)
    if response != nil
      LinkageService.store(current_user, session, crypt)
      LinkageService.set_nil(session, @params_definition)
    else
      flash[:alert] = 'Something went wrong. Please try again'
      redirect_to new_linkage_system_path(definition: session[:definition])
    end
  end

  def update_yahoo
    if params[:label].blank? || params[:"7"].blank? || params[:"8"].blank?
      flash[:alert] = "Something went wrong. Please try again"
      render :edit
    else
      LinkageService.set_nil(session, @params_definition)
      LinkageService.set_session(@params_definition, session, params)
      exist_params = []
      input_params = []
      LinkageService.update(@external_service, crypt, exist_params, input_params, params)
      if exist_params == input_params
        LinkageService.update_label(@external_service, params[:label])
        redirect_to linkage_system_path(id: params[:id], definition: params[:definition]),
                    notice: 'Linkage system updated successfully'
      else
        response_data = LinkageService.get_yahoo_auth_code(params[:"#{@params_definition.first.id}"], Constants::YAHOO_UPDATE_REDIRECT_URL, @params_definition, session, params)
        if response_data[:status] == :ok
          redirect_to response_data[:redirect_uri]
        else
          flash[:alert] = 'Something went wrong . Please try again'
          redirect_to edit_linkage_system_path(id: session[:linkage_id], definition: session[:definition])
        end
      end
    end
  end

  def yahoo_update_change
    @params_definition = LinkageService.find_params_definition(session[:definition])
    begin
      credentials = []
      LinkageService.set_credentials(credentials, @params_definition, session)
      response = LinkageService.get_yahoo_access_token(credentials, Constants::YAHOO_UPDATE_REDIRECT_URL, params, session)
      if response != nil
        LinkageService.change(session, crypt)
        LinkageService.set_nil(session, @params_definition)
      else
        flash[:alert] = 'Something went wrong. Please try again'
        redirect_to edit_linkage_system_path(id: session[:linkage_id], definition: session[:definition])
      end
      
    rescue StandardError => e
      flash[:alert] = "#{e.message}. Please try again"
      redirect_to edit_linkage_system_path(id: session[:linkage_id], definition: session[:definition])
      end
  end


  private

  def client
    @client ||= Faraday.new do |faraday|
      faraday.adapter :typhoeus
    end
  end

  def set_params_definition
    @params_definition = LinkageService.find_params_definition(params[:definition])
  end

  def find_external_service
    @external_service = LinkageService.find_external_service(params[:id])
  end

  def find_service_report
    @service_report = LinkageService.find_service_report(params[:id])
  end

end
