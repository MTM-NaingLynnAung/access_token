class SessionsController < ApplicationController
  before_action :user_exist?, only: [:new]
  skip_before_action :authorized?
  def new

  end
  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to users_path, notice: 'Login successful'
    else
      flash[:alert] = 'Email or Password incorrect'
      render :new, status: :unprocessable_entity
    end



      # hydra = Typhoeus::Hydra.new
      # request = Typhoeus::Request.new(url, followlocation: true)
      # request.run
      # request.on_complete do |response|
      #   #do_something_with response
      #   puts "++++++++++++++++++++++++++++#{response.success?}"
      #   if response.success?
      #     puts "-----------------------success--------------------"
      #     redirect_to request.base_url
      #   else
      #     puts "------------failure--------------------"
      #     render :new
      #   end
      # end
      # puts "------------------------#{request}"
      # hydra.queue(request)
      # hydra.run
      
  end
  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Logout successful"
  end
end
