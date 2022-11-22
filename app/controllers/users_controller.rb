class UsersController < ApplicationController
  skip_before_action :authorized?, only: [:new, :create]
  before_action :set_user
  def index
    @users = UserService.index
  end
  
  def show
   
  end

  def new
    @user = UserService.new
  end

  def create
    @user = UserService.create(user_params)
    isSave = UserService.save(@user)
    if isSave
      redirect_to users_path, notice: 'User was successfully created'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    
  end

  def update
    
    isUpdate = UserService.update(@user, user_params)
    if isUpdate
      redirect_to users_path, notice: 'User was successfully updated'
    else
      
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    UserService.delete(params[:id])
    redirect_to users_path, notice: 'User was successfully deleted'
  end

  private
  def set_user
    @user = UserService.set_user(params[:id])
  end
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
