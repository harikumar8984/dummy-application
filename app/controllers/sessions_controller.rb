class SessionsController < Devise::SessionsController
  prepend_before_filter :require_no_authentication, :only => [:create]
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  #before_filter :validate_auth_token, :except => :create
  include Devise::Controllers::Helpers
  include ApiHelper
  skip_before_filter :is_device_id?
  skip_before_filter :authenticate_device
  skip_before_filter :authenticate_user_from_token!
  #respond_to :json

  def create
    resource = User.find_for_database_authentication(:email => params[:user][:email])
    return failure unless resource
    #only for admin sign in
    if resource.valid_password?(params[:user][:password]) && resource.admin?
      sign_in(:user, resource)
      resource.ensure_authentication_token!
      redirect_to rails_admin_path
      return
    end
    failure
  end


  def failure
    return render json: { success: false, errors: [t('devise.sessions.invalid_login')] }, :status => :unauthorized
  end

  def new
    if user_signed_in? && current_user.admin?
      redirect_to rails_admin_path
    else
      super
    end
  end


end
