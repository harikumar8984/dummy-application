# This is extended concern common metods of user & registration controller
module UserCommonMethodControllerConcern
  extend ActiveSupport::Concern

  def dob_format
    format = params[:dob].include?("/") ? "%m/%d/%Y" : "%m-%d-%Y"
    params[:dob] = Date.strptime(params[:dob], format) rescue nil
  end

  def sign_up_params
    params.permit( :email, :password, :f_name, :l_name, :zipcode)
  end

  def update_params
    params.permit( :f_name, :l_name, :zipcode)
  end

  def create_device_details(user)
    device_id = request.headers["device-id"]
    if device_id && user.device_detail.nil?
      DeviceDetail.create(device_id: device_id, status: "Active", user_id: user.id)
      return true
    end
    false
  end

end


