class Api::V1::RegistrationsController < Devise::RegistrationsController
  include ApiHelper
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  skip_before_filter :authenticate_scope!, :only => [:update]
  skip_before_filter :authenticate_device, only: [:create]
  before_filter :validate_auth_token, :except => :create
  respond_to :json

  def create
    build_resource(sign_up_params)
    #device = DeviceDetail.find_or_create_by(device_id: params[:device_id])
    if resource.save
      if resource.device_detail.nil?
        DeviceDetail.create(device_id: params[:device_id], status: "active", user_id: resource.id)
      end
      #device.update_attributes(status: 'active', user_id: resource.id)
      #creating child of user
      child = resource.children.create(dob: params[:dob])
      child.user_child.update_attributes(relationship: params[:relationship]) if child
      if resource.active_for_authentication?
        resource.ensure_authentication_token!
        sign_in(:user, resource)
        return render status: 201, :json=> {:success => true, :token => resource.authentication_token}
      else
        expire_session_data_after_sign_in!
        return render status: 201, :json => {:success => true}
      end
    else
      clean_up_passwords resource
      return render :status => 401, :json => {:errors => resource.errors}
    end
  end

  def sign_up_params
    params.require(:user).permit( :email, :password, :f_name, :l_name)
  end
end
