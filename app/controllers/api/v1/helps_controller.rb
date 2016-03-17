class  Api::V1::HelpsController < ApplicationController
  skip_before_filter :is_device_id?, :only => [:create, :help_desk_webhook]
  skip_before_filter :authenticate_scope!, :only => [:create, :help_desk_webhook]
  skip_before_filter :authenticate_user_from_token!, :only =>  [:create, :help_desk_webhook]
  skip_before_filter :authenticate_device, :only => [:create, :help_desk_webhook]
  before_filter :fresh_desk_intialize, :only => [:create]
  respond_to :json

  def create
    binding.pry
   help_obj =  Help.create(help_params.merge(status: 'new'))
   binding.pry
    begin
      binding.pry
      @client.post_tickets(help_desk_params(help_obj.id))
    rescue Exception => ex
      return render :status => 404, :json => {:success => false, data: "Fresh Desk error: #{ex.message}"}
    end
    UserMailer.help_mail(help_params).deliver
    return render :status => 201, :json => {:success => true}
  end


  def help_params
    params.permit(:name, :email, :description)
  end

  def help_desk_params(id)
    help_params.merge(subject: "Support Needed For #{params[:name]}_##{id}" )
  end

  def fresh_desk_intialize
  @client = Freshdesk.new( ENV['FreshDesk_Url'],  ENV['FreshDesk_Api_Key'])
  end

  # def help_desk_webhook
  #   return render :status => 201, :json => {:success => true}
  # end

end
