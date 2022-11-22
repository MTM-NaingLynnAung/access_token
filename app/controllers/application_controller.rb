class ApplicationController < ActionController::Base
  before_action :authorized?
  helper_method :current_credentials, :current_user
  def current_credentials
    @current_credentials ||= FacebookCredential.find(session[:credential]) if session[:credential]
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
