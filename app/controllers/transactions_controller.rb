class  TransactionsController < ApplicationController
  include TransactionCommonMethodControllerConcern
  skip_before_filter :is_device_id?, :only => [:new,  :new_subscription, :change_card_details, :update_card_details, :create,:paypal_hook]
  skip_before_filter :authenticate_scope!, :only => [:new, :new_subscription, :change_card_details, :update_card_details, :create, :paypal_hook]
  skip_before_filter :authenticate_user_from_token!, :only => [:new, :new_subscription, :change_card_details, :update_card_details, :create, :paypal_hook]
  skip_before_filter :authenticate_device, :only => [:new, :new_subscription, :change_card_details, :update_card_details, :create, :paypal_hook]
  before_filter :authenticate_user!, :only => [:new]
  before_filter :reset_flash_message, :only => [:create, :update_card_details]
  before_filter :authenticate_user!, :except => [:paypal_hook]
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
    if params[:payment_error]
      @subscription_type = params[:subscription_type]
      @amount = params[:amount]
      @payment_gateway_type = params[:payment_gateway_type]
    else
      @plan = SubscriptionPlan.where('name !=?', 'Beta')
    end
  end

  def change_card_details
    @user = current_user if current_user
  end

  def update_card_details
    no_account?
    is_payment_gateway?
    unless flash[:message].blank?
      redirect_to :back
    else
      begin
          service_class = payment_service
          service_class.new.update_card_details_service(current_user, params)
      rescue service_class::PaymentError  => e
        flash[:message] =  e.message
        return redirect_to :back
      end
    render template: 'transactions/show'
    end
  end

  def create
    is_already_active?
    is_type_mismatch?
    is_payment_gateway?
    is_invalid_plan?
    unless flash[:message].blank?
      return redirect_to new_transaction_path(payment_error: true, payment_gateway_type: params[:payment_gateway_type], subscription_type:params[:subscription_type], amount: params[:amount] )
    else
      begin
        service_class = payment_service
        if service_class == PaypalPaymentService
          create_payment_by_paypal
        else
          service_class.new.create_payment_service(current_user, params)
          #after Creating Payment
          sign_out current_user
          redirect_to ENV['AFTER_SUBSCRIPTION_URL']
        end
      rescue service_class::PaymentError  => e
          flash[:message] =  e.message
          return redirect_to new_transaction_path(payment_error: true, payment_gateway_type: params[:payment_gateway_type], subscription_type:params[:subscription_type], amount: params[:amount] )
      end
    end
  end

  def create_payment_by_paypal
    @paypal_purchase = PaypalPurchase.new
    @paypal_purchase = PaypalPurchase.create(user_id: current_user.id, duration: params[:subscription_type])
    redirect_to @paypal_purchase.paypal_url(params, ENV['AFTER_SUBSCRIPTION_URL'])
  end

  def paypal_hook
    params.permit! # Permit all Paypal input params
    status = params[:payment_status]
    if status == "Completed"
      @paypal_purchase = PaypalPurchase.where(token: params[:invoice]).first
      @paypal_purchase.save_with_paypal_payment(params) unless @paypal_purchase.nil?
    end
    render nothing: true
  end

  def is_payment_gateway?
    if params[:payment_gateway_type].blank?
      flash[:message] =t('no_payment_gateway')
    elsif payment_service.nil?
      flash[:message] =t('invalid_payment_gateway')
    end
  end


  def no_account?
    flash[:message] =t('no_account') unless current_user.has_account?
  end

  def is_already_active?
    flash[:message] =t('active_subscription') if current_user.has_account? && current_user.active_subscription?
  end

  def is_type_mismatch?
    flash[:message] =t('user_type_mismatch') if current_user.user_type != params[:user_type]
  end

  def is_invalid_plan?
    plan = SubscriptionPlan.subscription_with_name(params[:subscription_type]).first
    flash[:message] =t('invalid_plan') if plan.nil?
  end

  def reset_flash_message
    flash[:message] = ''
  end

end


