class  TransactionsController < ApplicationController
  skip_before_filter :is_device_id?, :only => [:new, :get_stripe_plan, :new_subscription, :change_card_details, :update_card_details]
  skip_before_filter :authenticate_scope!, :only => [:new, :get_stripe_plan, :new_subscription, :change_card_details, :update_card_details]
  skip_before_filter :authenticate_user_from_token!, :only => [:new, :get_stripe_plan, :new_subscription, :change_card_details, :update_card_details]
  skip_before_filter :authenticate_device, :only => [:new, :get_stripe_plan, :new_subscription, :change_card_details, :update_card_details]
  before_filter :authenticate_user!, :only => [:new]
  #force_ssl if: :ssl_configured?
  respond_to :json

  def new
    @user = current_user if current_user
    initialize_transaction @user
  end

  def new_subscription
    @user = User.find_by_subscription_token(params[:subscription_token])
    unless @user
      return render status: 200, :json=> {:success => false, data: 'Invalid Token' }
    end
    sign_in @user
    initialize_transaction @user
    render "new"
  end


  def initialize_transaction user
    @auth_token = user.authentication_token
    @user_type = user.user_type
    @subscription = Transaction.new
    if params[:stripe_error]
      @subscription_type = params[:subscription_type]
      @amount = params[:amount]
    else
      get_stripe_plan
    end
  end

  def get_stripe_plan
    all_plan = StripeExt.get_all_plan
    if all_plan
      @plan = []
      all_plan[:data].each do |plan|
        amount = plan.amount > 0 ? (plan.amount.to_f/100) : 0.00
        if @user_type == 'beta' && plan.id != 'Yearly'
          @plan << [(plan.id == 'Beta' ? 'Yearly' : plan.id.to_s) , "$"+ amount.to_s, plan.id]
        elsif plan.id != 'Beta' && @user_type != 'beta'
          if @user_type == 'gift'
            @plan << [plan.id.to_s , "$"+ amount.to_s, plan.id] if plan.id == 'Yearly'
          else
            @plan << [plan.id.to_s , "$"+ amount.to_s, plan.id]
          end
        end
      end
    end
  end

  def change_card_details
    @user = current_user if current_user
  end

  def update_card_details
    url =  request.base_url.to_s + update_card_api_transactions_path
    begin
      puts 'inside client'
      c = RestClient::Request.execute(method: :put, url: url,header: {"device-id" => current_user.try(:device_detail).try(:device_id), "auth-token" => current_user.authentication_token})
      puts c
    rescue => e
      e.response
      puts e.message
    end
  end

  # def ssl_configured?
  #   !Rails.env.development?
  # end

end

