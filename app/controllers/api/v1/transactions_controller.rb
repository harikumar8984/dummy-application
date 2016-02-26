class  Api::V1::TransactionsController < ApplicationController
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
    #return render status: 200, :json=> {:success => false, data: [t('already_stripe_account')] } if current_user.stripe_account?
    if current_user.stripe_account?
      flash[:message] =t('already_stripe_account')
      return redirect_to :back
    end
    @stripe_customer = StripeCustomer.new
    if @stripe_customer.save_with_payment(current_user, params)
      sign_out current_user
      flash[:message] =t('download_nurl_app')
      redirect_to root_path
      #return render status: 201, :json=> {:success => true, data: 'Stripe account created' }
    else
      #return render status: 200, :json=> {:success => false, data: @stripe_customer.errors.messages }
      flash[:message] =  @stripe_customer.errors.messages
      return redirect_to :back
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
      return render status: 201, :json=> {:success => true, data: {data: "Subscription deactivated" } }
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


end

