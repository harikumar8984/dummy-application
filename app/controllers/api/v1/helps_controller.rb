class  Api::V1::HelpsController < ApplicationController
  skip_before_filter :is_device_id?, :only => [:create]
  skip_before_filter :authenticate_scope!, :only => [:create]
  skip_before_filter :authenticate_user_from_token!, :only =>  [:create]
  skip_before_filter :authenticate_device, :only => [:create]
  respond_to :json

  def create
    Help.create(help_params)
    UserMailer.help_mail(help_params).deliver
    return render :status => 201, :json => {:success => true}
  end


  def help_params
    params.permit(:name, :email, :description)
  end

end
