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

end


