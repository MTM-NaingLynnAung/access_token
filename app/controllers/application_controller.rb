class ApplicationController < ActionController::Base
  before_action :authorized?
  helper_method :current_user, :crypt
  
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
