class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_filter :is_device_id?
  # This is our new function that comes before Devise's one
  before_filter :authenticate_user_from_token!
  # # This is Devise's authentication
  # before_filter :authenticate_user!
  before_filter :authenticate_device
  after_filter :account_info_on_response, :if => Proc.new { |c| !(c.response.body.include? "html") &&  (JSON.parse(c.response.body)['success'] == true)   }

  # def after_sign_in_path_for(resource)
  #   edit_user_registration_path
  # end


  private

  # For this example, we are simply using token authentication
  # via parameters. However, anyone could use Rails's token
  # authentication features to get the token from a header.
  def authenticate_user_from_token!
    user_token = request.headers["auth-token"].presence
    user       = user_token && User.find_by_authentication_token(user_token.to_s)
    if user
      sign_in user, store: false
    else
      render :status => 401, :json => {:success => false, errors: user_token.blank? ? [t('devise.failure.no_token')] : [t('devise.failure.invalid')]}
    end
  end

  def authenticate_device
      device_id = request.headers["device-id"].presence
      device_details = DeviceDetail.where(device_id: device_id.strip, user_id: current_user.id, status: 'active') if device_id
      if device_details.blank?
        render :status => 401,:json=> {:success => false, errors: device_id.blank? ? [t('devise.failure.Invalid device id')] : [t('devise.failure.invalid_device')]}
      end
  end

  def is_device_id?
    device_id = request.headers["device-id"]
    if device_id.blank?
      render :status => 401,:json=> {:success => false, errors:  [t('devise.failure.no_device')]}
    end
  end

  def user_from_auth_token
    user_token = request.headers["auth-token"].presence
    user       = user_token && User.find_by_authentication_token(user_token.to_s)
    user
  end

  def account_info_on_response
    if current_user
      user = User.user_from_authentication(current_user.authentication_token)
      unless user.stripe_account?
        response_body_json = JSON.parse(response.body).merge({stripe_account: false })
      else
        response_body_json = JSON.parse(response.body).merge({is_active: user.active_subscription? })
      end
      response.body = response_body_json.to_json
    end
  end


end
