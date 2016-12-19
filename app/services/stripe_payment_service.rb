class StripePaymentService
  class PaymentError < StandardError; end

  def create_payment_service(user, params)
      stripe_customer = StripeCustomer.new
       unless stripe_customer.save_with_stripe_payment(user, params)
         raise PaymentError.new stripe_customer.errors.messages[:base][0]
       else
         true
       end
  end

  def update_card_details_service(user, params)
    if is_stripe_account?(user)
      stripe_customer =  my_subscription(user)
      if stripe_customer.present?
        unless stripe_customer.stripe_update_card_detail(user, params)
          raise PaymentError.new stripe_customer.errors.messages[:base][0]
        else
          true
        end
      end
    end
  end

  def change_plan_service(user, params)
    if is_stripe_account?(user)
      stripe_customer =  my_subscription(user)
      if stripe_customer.present?
        subscription_id =stripe_customer.try(:stripe_subscriptions).try(:active).try(:first).try(:subscription_id)
        unless stripe_customer.stripe_change_plan(params[:subscription_type], subscription_id, user)
          raise PaymentError.new stripe_customer.errors.messages[:base][0]
        end
      end
    end
  end

  def new_subscription_service(user, params)
    raise PaymentError.new 'STRIPE error: User already have an active subscription.' if user.active_subscription?
    stripe_customer =  my_subscription(user)
    if stripe_customer.present?
      unless stripe_customer.stripe_new_subscription(params[:subscription_type], user)
        raise PaymentError.new stripe_customer.errors.messages[:base][0]
      end
    end
  end

  def cancel_subscription_service(user, params)
    if is_stripe_account?(user)
    stripe_customer =  my_subscription(user)
    if stripe_customer.present?
      subscription_id =stripe_customer.try(:stripe_subscriptions).try(:active).try(:first).try(:subscription_id)
      unless stripe_customer.stripe_cancel_subscription(subscription_id, user)
        raise PaymentError.new stripe_customer.errors.messages[:base][0]
      end
    end
    end
  end

  def webhook_service(params)
    event_json = JSON.parse(params)
    StripeExt.webhook(event_json)
  end


  def is_stripe_account?(user)
    unless user.account_type("STRIPE")
      raise PaymentError.new 'Current Subscription is not stripe subscription.'
      return false
    else
      true
    end
  end


  def my_subscription(user)
    stripe_customer =  user.my_subscription_in_a_payment_type('StripeCustomer')
    unless stripe_customer
      raise PaymentError.new 'User do not have any stripe subscription.'
      return false
    else
      stripe_customer
    end
  end

end