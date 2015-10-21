class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  #before_filter :authenticate_device
  # This is our new function that comes before Devise's one
  #before_filter :authenticate_user_from_token!
  # # This is Devise's authentication
  # before_filter :authenticate_user!

  # def after_sign_in_path_for(resource)
  #   edit_user_registration_path
  # end


  private

  # For this example, we are simply using token authentication
  # via parameters. However, anyone could use Rails's token
  # authentication features to get the token from a header.
  def authenticate_user_from_token!
    user_token = params[:user_token].presence || params[:auth_token].presence
    user       = user_token && User.find_by_authentication_token(user_token.to_s)
    if user
      sign_in user, store: false
    else
      render :status => 401, :json => {errors: [t('api.v1.token.invalid_token')]}
    end
  end



  def authenticate_device
    render :json=> {:success => false, :message => "Device id missed"} if params[:device_id].blank?
    return
      device_details = DeviceDetail.where(device_id: params[:device_id].strip, status: 'active')
      if device_details.blank?
        render :json=> {:success => false, :message => "Invalid device id"}
      end
  end
end
