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
    #only for rails_admin sign in
    if resource.valid_password?(params[:user][:password])
      sign_in(:user, resource)
      resource.ensure_authentication_token!
      if resource.admin?
      redirect_to rails_admin_path
      else
        if resource.children.blank?
          redirect_to new_children_path(user_id: resource.id)
        elsif resource.active_subscription?
          render template: 'transactions/paid_user'
        else
          redirect_to new_transaction_path(user_type: resource.user_type)
        end
      end
      return
    end
    failure
  end


  def failure
    flash[:message] = t('devise.sessions.invalid_login')
    redirect_to root_path(invalid_login: true)
  end

  def new
    @user_type = params[:user_type] || 'beta'
    if user_signed_in? && current_user.admin?
      redirect_to rails_admin_path
      @user = User.new
    elsif user_signed_in?
      redirect_to new_transaction_path
    else
      super
    end
  end


end
