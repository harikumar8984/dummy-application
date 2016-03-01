class  TransactionsController < ApplicationController
  skip_before_filter :is_device_id?, :only => :new
  skip_before_filter :authenticate_scope!, :only => :new
  skip_before_filter :authenticate_user_from_token!, :only => :new
  skip_before_filter :authenticate_device, :only => :new
  before_filter :authenticate_user!

  respond_to :json

  def new
    @auth_token = current_user.authentication_token if current_user
    @user_type = params[:user_type]
    @subscription = Transaction.new
  end

end

