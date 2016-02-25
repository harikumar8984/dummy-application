class  TransactionsController < ApplicationController
  skip_before_filter :is_device_id?, :only => :new
  skip_before_filter :authenticate_scope!, :only => :new
  skip_before_filter :authenticate_user_from_token!, :only => :new
  skip_before_filter :authenticate_device, :only => :new

  respond_to :json

  def new
    @auth_token = current_user.authentication_token if current_user
    @subscription = Transaction.new
  end

end

