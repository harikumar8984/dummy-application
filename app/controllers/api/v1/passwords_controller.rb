class Api::V1::PasswordsController < Devise::PasswordsController
  prepend_before_filter :require_no_authentication, :only => [:create]
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  #before_filter :validate_auth_token, :except => :create
  include Devise::Controllers::Helpers
  include ApiHelper
  skip_before_filter :is_device_id?, :only => [:create, :edit, :update_password]
  skip_before_filter :authenticate_device, :only => [:create, :edit, :update_password]
  skip_before_filter :authenticate_user_from_token!, :only => [:create, :edit, :update_password]
  respond_to :json

  def create
    self.resource = resource_class.send_reset_password_instructions(params)
    yield resource if block_given?
    if successfully_sent?(resource)
      render :status => 201, :json => { :success => true}
    else
      render :status => 200, :json => {   :success => false, :errors => 'Email not found' }
    end
  end

  def update_password_api
    user = user_from_auth_token
     if user
       if user.update_with_password(current_password: params[:current_password], password:  params[:password], password_confirmation: params[:password_confirmation])
         render :status => 201, :json => { :success => true, :data => 'Password Updated'}
       else
          render :status => 200, :json => { :success => false,  data: user.errors.messages}
       end
     end
   end

end
