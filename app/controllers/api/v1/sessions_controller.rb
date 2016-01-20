class Api::V1::SessionsController < Devise::SessionsController
  prepend_before_filter :require_no_authentication, :only => [:create]
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  skip_before_filter :authenticate_user_from_token!, :only => :create
  skip_before_filter :authenticate_device, :only => :create
  respond_to :json

  def create
    resource = User.find_for_database_authentication(:email => params[:email])
    return failure unless resource
    if resource.valid_password?(params[:password])
      sign_in(:user, resource)
      authenticate_device
      resource.ensure_authentication_token!
      return render :json=> {:success => true, :token => resource.authentication_token} if performed? == false
    end
    failure
  end

  def destroy
    user_token = request.headers["auth-token"].presence
    resource = user_token && User.find_by_authentication_token(user_token.to_s)
    resource.reset_authentication_token! if resource
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    render :status => 200, :json => { success: true, data: 'sign-out'}
  end

  def failure
    return render json: { success: false, errors: [t('invalid_login')]}, :status => :unauthorized if performed? == false
  end

end
