class RegistrationsController < Devise::RegistrationsController
  include ApiHelper
  include UserCommonMethodControllerConcern
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  skip_before_filter :is_device_id?, :only => [:create, :new]
  skip_before_filter :authenticate_scope!, :only => [:update]
  skip_before_filter :authenticate_user_from_token!, :only => [:create, :new]
  skip_before_filter :authenticate_device, :only => [:create, :new]
  respond_to :json
  #layout "rails_admin/application", :only => [:new]

  def create
    params[:user_type] = params[:user_type] || 'beta'
    build_resource(sign_up_params.merge!(status: 'ACTIVE'))
    if resource.save
      if resource.active_for_authentication?
        resource.ensure_authentication_token!
        sign_in resource
        redirect_to new_children_path(user_id: resource)
      else
        expire_session_data_after_sign_in!
        return redirect_to root_path
      end
    else
      clean_up_passwords resource
      flash[:error] = resource.errors
      redirect_to root_path
    end
  end


  def new
    @user_type = params[:user_type] || 'standard'
    @user = User.new
  end


end
