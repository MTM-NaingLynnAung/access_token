class ApplicationController < ActionController::Base
  before_action :authorized?
  helper_method :current_user, :crypt, :current_external_service, :credentials
  
  # def current_label
  #   session[:label]
  # end

  # def current_app_id
  #   session[:app_id]
  # end

  # def current_app_secret
  #   session[:app_secret]
  # end

  # def current_definition
  #   session[:definition]
  # end


  def current_external_service
    @external_service ||= ExternalService.find_by(id: session[:external_service]) if session[:external_service]
  end

  def credentials(key)
    parameter_definition = ExternalServiceParameterDefinition.find_by(key: key)
    service_parameter = current_external_service.external_service_parameters.find_by(external_service_parameter_definition_id: parameter_definition.id)
  end

  def crypt
    crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31], Rails.application.secrets.secret_key_base)
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def authorized?
    redirect_to root_path unless current_user
  end

  def user_exist?
    redirect_to users_path if current_user
  end
end
