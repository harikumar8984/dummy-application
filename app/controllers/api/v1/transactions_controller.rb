class  Api::V1::TransactionsController < ApplicationController
  include UserCommonMethodControllerConcern
  skip_before_filter :is_device_id?, :only => [:webhook,:new,:create,:get_subscription_amount]
  skip_before_filter :authenticate_scope!, :only => [:webhook,:new]
  skip_before_filter :authenticate_user_from_token!, :only =>  [:webhook,:new]
  skip_before_filter :authenticate_device, :only => [:webhook,:new,:create,:get_subscription_amount]
  before_filter :intialize_transaction, :except => [:webhook, :create]
  respond_to :json

  def new
    @subscription = Transaction.new
  end

  def create
    if params[:html_format]
     if current_user.user_type != params[:user_type]
       flash[:message] =t('user_type_mismatch')
       return redirect_to new_transaction_path(stripe_error: true, subscription_type:params[:subscription_type], amount: params[:amount] )
    elsif current_user.stripe_account?
        flash[:message] =t('already_stripe_account')
        return redirect_to new_transaction_path(stripe_error: true, subscription_type:params[:subscription_type], amount: params[:amount] )
     end
   else
     return render status: 200, :json=> {:success => false, data: [t('already_stripe_account')] } if current_user.stripe_account?
  end
    @stripe_customer = StripeCustomer.new
    if @stripe_customer.save_with_stripe_payment(current_user, params)
      if params[:html_format]
        sign_out current_user
        flash[:message] =t('subscription_sucess')
        redirect_to root_path
      else
        return render status: 201, :json=> {:success => true, data: 'Stripe account created' }
      end
    else
      if params[:html_format]
        flash[:message] =  @stripe_customer.errors.messages[:base][0]
        return redirect_to new_transaction_path(stripe_error: true, subscription_type:params[:subscription_type], amount: params[:amount] )
      else
        return render status: 200, :json=> {:success => false, data: @stripe_customer.errors.messages }
      end
    end
  end

  def get_subscription_amount
    #Stripe save amount in Cents
    plan = StripeExt.retrieve_plan(params[:subscription_type], @transaction )
    unless plan
      return render status: 200, :json=> {:success => false, data: @transaction.errors.messages }
    else plan
      return render status: 200, :json=> {:success => true, data: {amount: plan.amount > 0 ? (plan.amount.to_f/100) : 0.00 } }
    end
  end

  def change_plan
    return render status: 200, :json=> {:success => false, data: [t('no_stripe_account')] } unless current_user.stripe_account?
    return render status: 200, :json=> {:success => false, data: [t('no_active_stripe_subscription')] } unless current_user.active_subscription?
    subscription_id = current_user.stripe_customer.stripe_subscriptions.active.first.subscription_id
    subscription = StripeExt.change_plan(params[:subscription_type], subscription_id, current_user, @transaction )
    unless subscription
      return render status: 200, :json=> {:success => false, data: @transaction.errors.messages }
    else update_stripe_customer_plan_details(subscription)
      return render status: 201, :json=> {:success => true, data: {data: "Plan updated to " + subscription.plan.interval } }
    end
  end

  def new_subscription
    return render status: 200, :json=> {:success => false, data: [t('no_stripe_account')] } unless current_user.stripe_account?
    return render status: 200, :json=> {:success => false, data: [t('active_stripe_subscription')] } if current_user.active_subscription?
    new_subscription = StripeExt.new_subscription(params[:subscription_type], current_user, @transaction )
    unless new_subscription
      return render status: 200, :json=> {:success => false, data: @transaction.errors.messages }
    else create_new_subscription(new_subscription)
     return render status: 201, :json=> {:success => true, data: {data: "New subscription added" } }
    end
  end

  def cancel_subscription
    return render status: 200, :json=> {:success => false, data: [t('no_stripe_account')] } unless current_user.stripe_account?
    return render status: 200, :json=> {:success => false, data: [t('no_active_stripe_subscription')] } unless current_user.active_subscription?
    subscription_id = current_user.stripe_customer.stripe_subscriptions.active.first.subscription_id
    cancel_subscription = StripeExt.cancel_subscription(current_user, subscription_id ,@transaction )
    unless cancel_subscription
      return render status: 200, :json=> {:success => false, data: @transaction.errors.messages }
    else deactivate_subscription(cancel_subscription)
      UserMailer.test_mail(cancel_subscription, 'from_cancel_subscription').deliver
      return render status: 201, :json=> {:success => true, data: {data: "Subscription deactivated" } }
    end
  end

  def update_customer
    return render status: 200, :json=> {:success => false, data: [t('no_stripe_account')] } if current_user.stripe_customer_token.nil?
    @stripe_customer = StripeCustomer.new
    if @stripe_customer.update_customer(current_user, params)
           return render status: 201, :json=> {:success => true, data: {data: "Card updated" } }
    else
      return render status: 200, :json=> {:success => false, data: @stripe_customer.errors.messages }
    end
  end

  def intialize_transaction
    @transaction = Transaction.new
  end

  def webhook
    event_json = JSON.parse(request.body.read)
    StripeExt.webhook(event_json )
    return render status: 200, :json=> {:success => true, data: 'Success' }
  end

  def update_stripe_customer_plan_details(response)
    subscription = StripeSubscription.find_by_subscription_id(response.id)
    subscription.update_plan_details(response.plan) if subscription
  end

  def create_new_subscription(response)
    subscription_json = StripeSubscription.create_json(response, current_user)
    current_user.stripe_customer.stripe_subscriptions.create(subscription_json) if current_user.stripe_customer
  end

  def deactivate_subscription(response)
    StripeSubscription.update_with_status(response)
  end

  #type of subscription for IOS APP
  def get_subscription_type
    all_plan = StripeExt.get_all_plan
    if all_plan
    user_type = current_user.user_type
    subscrition_type = []
    all_plan[:data].each do |plan|
      if user_type == 'beta' && plan.id == 'Beta' || plan.id == 'Monthly'
        subscrition_type << ENV['In_App_Purchase_Subscription']+plan.id.downcase
      elsif plan.id != 'Beta' && user_type != 'beta'
        subscrition_type << ENV['In_App_Purchase_Subscription']+plan.id.downcase
      end
    end
    else
      return render status: 200, :json=> {:success => false, data: 'stripe error' }
    end
    return render status: 200, :json=> {:success => true, data: subscrition_type }
  end

  def in_app_purchase_details
    user = user_from_auth_token
    if !user.stripe_account?
      stripe_customer = StripeCustomer.new
      stripe_customer.save_with_in_app_payment(user, params)
      user = user_from_auth_token
      StripeSubscription.save_with_in_app_subscription(user, params)
     elsif (!user.has_subscription? || (user.has_subscription? && !user.active_subscription?))
       StripeSubscription.save_with_in_app_subscription(user, params)
    end
    params[:purchase_date] = dob_format(params[:purchase_date]) if params[:purchase_date]
    Transaction.save_with_in_app_transaction(user, params)
    return render status: 201, :json=> {:success => true, data: {data: "IAP details updated" } }
  end

  def cancel_in_app_subscription
    return render status: 200, :json=> {:success => false, data: [t('no_stripe_account')] } unless current_user.stripe_account?
    return render status: 200, :json=> {:success => false, data: [t('no_active_stripe_subscription')] } unless current_user.active_subscription?
    return render status: 200, :json=> {:success => false, data: [t('no_active_stripe_subscription')] } unless current_user.active_subscription.payment_type == 'iap'
    StripeSubscription.update_with_in_app_subscription(current_user, 'canceled')
    return render status: 201, :json=> {:success => true, data: {data: "Subscription deactivated" } }
  end

  def subscription_status
      status = current_user.stripe_account? ? current_user.active_subscription? ? 'active' : 'canceled' : 'no_account'
      return render status: 200, :json=> {:success => true, data: {subscription_status: status } }
  end

end

