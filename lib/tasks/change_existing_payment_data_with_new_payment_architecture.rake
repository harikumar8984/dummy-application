namespace :ChangeExistingPaymentDataWithNewPaymentArchitecture do
  desc "Change Existing Payment Data With New Payment Architecture"
  task :change_data => :environment do |t,args|

    StripeCustomer.where(payment_type: nil).each do |stripe_customer|
        stripe_customer.update_attributes(payment_type: 'stripe')
        subscription = get_subscription stripe_customer
        subscription.update_attributes(payment_type: 'stripe') unless subscription.nil?
    end


    StripeCustomer.all.each do |stripe_customer|
      user = User.where(id: stripe_customer.user_id).first
      if user
        subscription = get_subscription stripe_customer
        if subscription
          status = get_status subscription
          plan = get_plan subscription
          start_date = get_start_date(user, stripe_customer, subscription)
          if subscription.payment_type == 'stripe'
              user.create_my_subscription('STRIPE', plan, start_date, status)
              user.create_my_subscription_details(stripe_customer)
          elsif  subscription.payment_type == 'iap'
              iap_payment= InAppPurchase.create(create_json(user, subscription, stripe_customer))
              create_iap_transaction(iap_payment, user, set_transaction_params(subscription, stripe_customer))
              user.create_my_subscription('IAP', plan, start_date, status)
              user.create_my_subscription_details(iap_payment)
              stripe_customer.destroy
          elsif subscription.payment_type == 'dummy'
              user.create_my_subscription('DUMMY', plan, start_date, status)
              stripe_customer.destroy
          end
        else
          logger = Logger.new('no_subscription.txt')
          logger.info '**********user*********' + user.id.to_s
          logger.info '**********sc***********' + stripe_customer.id.to_s
        end
      end


    end
  end

  def get_subscription stripe_customer
    if stripe_customer.stripe_subscriptions.count == 1
      subscription = stripe_customer.stripe_subscriptions.last
    else
      subscription = stripe_customer.active_subscription
      subscription = stripe_customer.stripe_subscriptions.last if subscription.nil?
    end
    subscription
  end

 def get_plan subscription
   return SubscriptionPlan.subscription_with_name(get_plan_name subscription).first
 end

  def get_plan_name subscription
    plan_name = subscription.plan_id.capitalize
    if plan_name == 'Dummy'
      'Monthly'
    else
      plan_name
    end
  end

  def get_start_date (user, stripe_customer, subscription)
    plan_name = get_plan_name subscription
    if plan_name == "Yearly" || "Gift" || 'Beta'
      start_date = stripe_customer.created_at.to_date
    end
    if plan_name == "Monthly"
      if subscription.payment_type == 'stripe'
          start_date = StripeTransaction.where(user_id: user.id).last.created_at.to_date rescue nil
          start_date.nil? ? subscription.updated_at.to_date : start_date
      elsif  subscription.payment_type == 'iap' || subscription.payment_type == 'dummy'
        start_date = Date.today
      end
    end
    start_date
  end

  def get_status subscription
   subscription.status.capitalize rescue 'Cancelled'
  end


  def set_transaction_params(subscription, stripe_customer)
    params = {:transaction_date=> stripe_customer.created_at.to_date, :currency => stripe_customer.currency,
              :amount => subscription.amount, :transaction_id => stripe_customer.customer_id,
              :transaction_status => subscription.status, :paid => true}
  end

  def create_json(user, subscription, stripe_customer)
    {apple_id: stripe_customer.customer_id,  user_id: user.id, purchase_start_date: stripe_customer.created_at.to_date,
     status: subscription.status, duration: get_plan_name(subscription)}
  end

  def create_iap_transaction(iap_payment, user, params)
    InAppPurchaseTransaction.create(iap_payment.in_app_purchase_transactions.create_json(iap_payment, user, params))
  end

end

