class ChildrensController < ApplicationController
  include UserCommonMethodControllerConcern
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  skip_before_filter :is_device_id?, :only => [:create, :new]
  skip_before_filter :authenticate_user_from_token!, :only => [:create, :new]
  skip_before_filter :authenticate_device, :only => [:create, :new]
  respond_to :json

  def create
    user = User.from_user_id(params[:user_id])
    if user
      params[:dob] = get_date_format(params[:dob]) rescue nil
      child = user.children.create(dob: params[:dob], name: params[:name], gender: params[:gender])
      unless child.errors.messages.blank?
        flash[:error] = child.errors.messages
        redirect_to new_children_path(user_id: user.id)
      else
        child.user_child.update_attributes(relationship: params[:relationship])
        device_type = request.user_agent.include?("iPhone") ? 'iPhone' : 'Android'
        UserMailer.user_registered_to_nuryl_with_template( user, device_type,  "Welcome to Nuryl!", "Registration").deliver
        redirect_to new_transaction_path
      end


    else
      flash[:error] = 'User not found'
      redirect_to root_path
    end

  end


  def new
    @user_id = params[:user_id]
  end

  def get_date_format dob
    event = dob
    params[:dob] = Date.new event["date(1i)"].to_i, event["date(2i)"].to_i, event["date(3i)"].to_i
  end


end
