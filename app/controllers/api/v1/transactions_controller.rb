class  Api::V1::TransactionsController < ApplicationController
  skip_before_filter :is_device_id?, :only => :new
  skip_before_filter :authenticate_scope!, :only => :new
  skip_before_filter :authenticate_user_from_token!, :only => :new
  skip_before_filter :authenticate_device, :only => :new

  before_filter :intialize_transaction
  respond_to :json

  def new
    @subscription = Transaction.new
  end

  def create
    if @transaction.save_with_payment(current_user, params)
      return render status: 201, :json=> {:success => true, data: 'Stripe account created' }
    else
      return render status: 200, :json=> {:success => false, data: @transaction.errors.messages }
    end
  end

  def get_subscription_amount
    plan = StripeExt.retrieve_plan(params[:subscription_type], @transaction )
    unless plan
      return render status: 200, :json=> {:success => false, data: @transaction.errors.messages }
    else plan
      return render status: 200, :json=> {:success => true, data: {amount: plan.amount > 0 ? plan.amount/100 : 0.00 } }
    end
  end

  def change_plan
    changed_plan = StripeExt.change_plan(params[:subscription_type], current_user, @transaction )
    unless changed_plan
      return render status: 200, :json=> {:success => false, data: @transaction.errors.messages }
    else changed_plan
    return render status: 201, :json=> {:success => true, data: {data: "Plan updated to " + changed_plan.plan.interval } }
    end
  end

  def new_subscription
    new_subscription = StripeExt.new_subscription(params[:subscription_type], current_user, @transaction )
    unless new_subscription
      return render status: 200, :json=> {:success => false, data: @transaction.errors.messages }
    else new_subscription
    return render status: 201, :json=> {:success => true, data: {data: "New subscription added" } }
    end
  end

  def cancel_subscription
    cancel_subscription = StripeExt.cancel_subscription(current_user, @transaction )
    unless cancel_subscription
      return render status: 200, :json=> {:success => false, data: @transaction.errors.messages }
    else cancel_subscription
      return render status: 201, :json=> {:success => true, data: {data: "Subscription deactivated" } }
    end
  end

  def intialize_transaction
    @transaction = current_user.transactions.new
  end

end

