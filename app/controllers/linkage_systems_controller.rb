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

    credentials = []
    LinkageService.get_credentials(credentials, @external_service, crypt)
    ad_account = FacebookAds::CustomAudience.get("act_#{params[:ad_id]}", { access_token: credentials[2], app_secret: credentials[1] })

    puts "------------------------------Ad Account Name: #{ad_account.id}"
    customaudiences = ad_account.customaudiences.create({
        name: params[:name],
        subtype: Constants::SUBTYPE,
        description: Constants::DESCRIPTION,
        customer_file_source: Constants::CUSTOMER_FILE_SOURCE,
    })
    service_report = ExternalServiceAvailableReport.create({
      external_service_id: @external_service.id,
      service_type: @external_service.external_service_definition_id,
      name: params[:name],
      identifier: params[:name],
      fetched_at: Time.now,
      custom_audience_id: customaudiences.id
    })
    render json: service_report
    
  end

  def audience_edit
    
  end

  def audience_update

    credentials = []
    LinkageService.get_credentials(credentials, @external_service, crypt)
    custom_audience = FacebookAds::CustomAudience.get(params[:ad_id], { access_token: credentials[2], app_secret: credentials[1] })
    custom_audience.name = params[:name]
    custom_audience.save
    @audience.update(
      name: params[:name],
      identifier: params[:name],
      custom_audience_id: params[:ad_id]
    )
    redirect_to linkage_system_path(@audience.external_service_id, definition: params[:definition]), notice: 'Audience was updated successfully'

  end

  def audience_user
  end

  def audience_user_create

    if @audience.blank?
      flash[:alert] = 'Please create custom audience first'
      render :audience_user
    else
      begin
        file = File.open(params[:file])
        csv = CSV.read(file)
        csv.shift
        email = []
        csv.each do |row|
          email << Digest::SHA256.hexdigest(row[0])
        end
        
        credentials = []
        LinkageService.get_credentials(credentials, @external_service, crypt)

        session_id = rand 1000000..9999999
        session = {
          session_id: session_id,
          batch_seq: 1,
          last_batch_flag: false
        }
        payload = {
          schema: "EMAIL_SHA256",
          data: email
        }
        custom_audience = FacebookAds::CustomAudience.get(@audience.custom_audience_id, { access_token: credentials[2], app_secret: credentials[1] })
        deleted_user = custom_audience.users.destroy(payload: payload.to_json)
        created_user = custom_audience.users.create(payload: payload.to_json)
        render json: { deleted_user: deleted_user, created_user: created_user }
      rescue => exception
        flash[:alert] = 'Something went wrong. Please try again later'
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
