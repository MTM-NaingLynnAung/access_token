class SessionsController < ApplicationController

  def new
  end
  def create
    credential = FacebookCredential.from_omniauth(params)
    session[:credential] = credential.id
    url = "https://www.facebook.com/dialog/oauth?client_id=#{params[:app_id]}&redirect_uri=http://localhost:3000/success"
    redirect_to url
  end
  def destroy
    session[:credential] = nil
    redirect_to root_path, notice: "Logout successful"
  end
end
