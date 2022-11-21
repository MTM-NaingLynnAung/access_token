class SessionsController < ApplicationController

  def new

  end
  def create
    
      session[:credential] = nil
      credential = FacebookCredential.from_omniauth(params)
      session[:credential] = credential.id
      url = "https://www.facebook.com/dialog/oauth?client_id=#{params[:app_id]}&redirect_uri=http://localhost:3000/success"
      
      request = Typhoeus::Request.new(url, followlocation: true)
      
      request.on_complete do |response|
        
        if response.success?
          # hell yeah
          puts '-------------------success--------------------'
          redirect_to request.base_url
        else
          # Received a non-successful http response.
          puts ("-----------------failure-----------------")
          render :new
        end
      end
      request.run


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
    session[:credential] = nil
    redirect_to root_path, notice: "Logout successful"
  end
end
