class Users::SetupController < ApplicationController

  layout "one_column"

  def edit
    authorize! :set_up, current_user
    @user = current_user
  end

  def update
    authorize! :set_up, current_user

    @user = current_user
    @user.full_name = user_params[:full_name] || ''
    @user.set_up = true
    @user.save

    if @user.changed?
      render 'users/setup/edit'
    else
      remembered_sign_in @user, bypass: true # http://stackoverflow.com/questions/4264750/devise-logging-out-automatically-after-password-change
      redirect_to '/'
    end
  end

  private

  def user_params
    params[:user] || {}
  end

end
