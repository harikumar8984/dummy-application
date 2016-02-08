class Api::V1::PasswordsController < Devise::PasswordsController
  prepend_before_filter :require_no_authentication, :only => [:create]
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  #before_filter :validate_auth_token, :except => :create
  include Devise::Controllers::Helpers
  include ApiHelper
  skip_before_filter :is_device_id?
  skip_before_filter :authenticate_device
  skip_before_filter :authenticate_user_from_token!
  respond_to :json

  def create
    @user = User.find_by_email(params[:email])
    if @user
      render :status => 201, :json => { :success => true,  data: {reset_password_token: reset_password_token} }
    else
      render :status => 422, :json => {   :success => false, :errors => 'Email not found' }
    end
  end


   def update
     user = User.find_by_reset_password_token(params[:reset_password_token])
     if user
       if user.update_attributes(password: params[:password])
          render :status => 201, :json => { :success => true, :auth_token => user.authentication_token}
       else
          render :status => 200, :json => { :success => false,  data: user.errors.messages}
       end
     else
       render :status => 200, :json => { :success => false,  data: 'Invalid reset password token'}
     end
   end

  def reset_password_token
    raw, enc = Devise.token_generator.generate(@user.class, :reset_password_token)
    @user.reset_password_token   = enc
    @user.reset_password_sent_at = Time.now.utc
    @user.save(validate: false)
    @user.reset_password_token
  end

end
