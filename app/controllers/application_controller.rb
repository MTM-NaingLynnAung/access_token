class ApplicationController < ActionController::Base
  helper_method :current_credentials
  def current_credentials
    @current_credentials ||= FacebookCredential.find(session[:credential]) if session[:credential]
  end
end
