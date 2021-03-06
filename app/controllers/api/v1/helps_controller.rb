class  Api::V1::HelpsController < ApplicationController
  skip_before_filter :is_device_id?, :only => [:create]
  skip_before_filter :authenticate_scope!, :only => [:create]
  skip_before_filter :authenticate_user_from_token!, :only =>  [:create]
  skip_before_filter :authenticate_device, :only => [:create]
  #before_filter :fresh_desk_intialize, :only => [:create]
  respond_to :json

  def create
    help_obj = Help.new(help_params.merge(status: 'new'))
    # begin
    #   @client.post_tickets(help_desk_params(help_obj.id))
    # rescue Exception => ex
    #   return render :status => 404, :json => {:success => false, data: "Fresh Desk error: #{ex.message}"}
    # end
    if help_obj.save
      UserMailer.help_mail(help_params).deliver
      return render :status => 201, :json => {:success => true}
    else
      return render :status => 200, :json => {:success => false, :errors => help_obj.errors}
    end
  end


  def help_params
    params.permit(:name, :email, :description)
  end

  # def help_desk_params(id)
  #   help_params.merge(subject: "Support Needed For #{params[:name]}_##{id}" )
  # end

  # def fresh_desk_intialize
  # @client = Freshdesk.new( ENV['FreshDesk_Url'],  ENV['FreshDesk_Api_Key'])
  # end

  # def help_desk_webhook
  #   return render :status => 201, :json => {:success => true}
  # end

end
