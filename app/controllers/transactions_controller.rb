class  TransactionsController < ApplicationController
  skip_before_filter :is_device_id?, :only => [:new, :get_stripe_plan, :new_subscription, :change_card_details, :update_card_details, :paypal_transaction_process]
  skip_before_filter :authenticate_scope!, :only => [:new, :get_stripe_plan, :new_subscription, :change_card_details, :update_card_details, :paypal_transaction_process]
  skip_before_filter :authenticate_user_from_token!, :only => [:new, :get_stripe_plan, :new_subscription, :change_card_details, :update_card_details, :paypal_transaction_process]
  skip_before_filter :authenticate_device, :only => [:new, :get_stripe_plan, :new_subscription, :change_card_details, :update_card_details, :paypal_transaction_process]
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
    @stripe_customer = current_user.stripe_customer
    if @stripe_customer.update_card_detail(current_user, params)
      render template: 'transactions/show'
    else
      flash[:message] = @stripe_customer.errors.messages[:base]
      redirect_to :back
    end
  end

  # def ssl_configured?
  #   !Rails.env.development?
  # end

  def paypal_transaction_process
    amount = params[:amount].scan(/\d./).join('').to_f
    price_in_cents = Transaction.price_in_cents(amount)
    credit_card = Transaction.credit_card( params[:card_type], params[:card_number],  params[:card_verification],  params[:date],  params[:first_name],  params[:last_name])
    if credit_card.valid? 
      begin
        purchase_options = Transaction.purchase_options(request.ip, params[:first_name], params[:address1], params[:city], params[:state], params[:country], params[:zip])
        response =  Transaction.purchase(price_in_cents, credit_card, purchase_options)
        if response.success?
          flash[:message] = response
          redirect_to new_transaction_path
        else
          flash[:message] = response.message
          redirect_to new_transaction_path
        end
      rescue
        flash[:message] = "Something went wrong...!"
        redirect_to new_transaction_path
      end
    else
      flash[:message] = credit_card.errors.full_messages.join(", ")
      redirect_to :back
    end
  end
end

#4222222222222  9/23 123
#name     => "Ryan Bates",
#address1 => "123 Main St.",
#city     => "New York",
#state    => "NY",
#country  => "US",
#zip      => "10001"
