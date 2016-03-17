# This is extended concern common metods of user & registrations controller
module UserCommonMethodControllerConcern
  extend ActiveSupport::Concern

  #HRR can send date in any format
  def dob_format
    begin
      date_format = Date.parse(params[:dob])
    rescue ArgumentError
      format = params[:dob].include?("/") ? "%m/%d/%Y" : "%m-%d-%Y"
      date_format = Date.strptime(params[:dob], format) rescue nil
    ensure
      params[:dob] = date_format
    end
  end

  def sign_up_params
    params.permit( :email, :password, :f_name, :l_name, :zipcode, :user_type, :gifter_first_name, :gifter_last_name, :gifter_email )
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


