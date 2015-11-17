class Api::V1::RegistrationsController < Devise::RegistrationsController
  include ApiHelper
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  skip_before_filter :authenticate_scope!, :only => [:update]
  skip_before_filter :authenticate_user_from_token!, :only => :create
  skip_before_filter :authenticate_device, :only => :create
  respond_to :json

  def create
    build_resource(sign_up_params.merge!(status: 'ACTIVE'))
    #device = DeviceDetail.find_or_create_by(device_id: params[:device_id])
    if resource.save
      device_id = request.headers["device-id"]
      if resource.device_detail.nil?
        DeviceDetail.create(device_id: device_id, status: "Active", user_id: resource.id)
      end
      #device.update_attributes(status: 'active', user_id: resource.id)
      #creating child of user
      child = resource.children.create(dob: params[:dob], name: params[:baby_name])
      unless child.errors.messages.blank?
        return render :status => 200, :json => {:success => false, :auth_token => resource.authentication_token, :errors => child.errors.messages}
      else
       child.user_child.update_attributes(relationship: params[:relationship])
      end
      UserMailer.user_registered_to_nuryl( resource, "Nuryl Registration").deliver
      if resource.active_for_authentication?
        resource.ensure_authentication_token!
        return render status: 201, :json=> {:success => true, :auth_token => resource.authentication_token}
      else
        expire_session_data_after_sign_in!
        return render status: 201, :json => {:success => true}
      end
    else
      clean_up_passwords resource
      return render :status => 200, :json => {:success => false, :errors => resource.errors}
    end
  end

  def sign_up_params
    params.permit( :email, :password, :f_name, :l_name, :type_of_subscription, :zipcode)
  end
end
