class StripeCustomer < ActiveRecord::Base
  include SharedMethod
  has_many :stripe_transactions, dependent: :destroy
  has_many :stripe_subscriptions, dependent: :destroy
  has_many :subscription_details, as: :subscription

  def save_with_stripe_payment(user, params)
    unless params[:subscription_type].nil?
        plan_id = params[:subscription_type].capitalize
    end
    if plan_id.nil?
      self.errors.add(:base, "User don't provide any type of subscription")
      return false
    end
    customer = StripeExt.create_customer(user.email, plan_id, params[:card_id], self)
    if customer
      stripe_customer = StripeCustomer.create(create_json(customer, user))
      subscription_json =StripeSubscription.create_json(customer.subscriptions.data[0], user)
      stripe_customer.stripe_subscriptions.create(subscription_json)
      if stripe_customer
        plan = SubscriptionPlan.subscription_with_name(params[:subscription_type]).first
        user.create_my_subscription('STRIPE', plan, Date.today, 'Active')
        user.create_my_subscription_details(stripe_customer)
        return true
      end
    end
  end

  def stripe_update_card_detail(user, params)
    customer = StripeExt.update_card(user, params[:card_id], self)
    if customer
      update_attributes(default_source: customer.default_source)
      return true
    end
  end

  def stripe_change_plan(plan_name, subscription_id, user)
    customer = StripeExt.change_plan(plan_name, subscription_id, user, self)
    if customer
      update_stripe_plan_details(customer)
      plan = SubscriptionPlan.subscription_with_name(plan_name).first
      user.update_my_subscription_plan(Date.today, plan)
      return true
    end
  end


  def stripe_new_subscription(subscription_type, user)
    customer = StripeExt.new_subscription(subscription_type, self )
    if customer
      create_stripe_new_subscription(customer, user)
      plan = SubscriptionPlan.subscription_with_name(subscription_type).first
      user.create_my_subscription('STRIPE', plan, Date.today, 'Active')
      user.update_my_subscription_plan(Date.today, plan)
      user.update_my_subscription_status('Active')
    end
  end

  def stripe_cancel_subscription(subscription_id, user)
    customer = StripeExt.cancel_subscription(subscription_id, self)
    if customer
      deactivate_stripe_subscription(customer)
      user.cancel_my_subscription('Cancelled')
    end
  end

  def update_stripe_plan_details(response)
    subscription = StripeSubscription.find_by_subscription_id(response.id)
    subscription.update_plan_details(response.plan) if subscription
  end

  def create_stripe_new_subscription(response, user)
      subscription_json = StripeSubscription.create_json(response, user)
      self.stripe_subscriptions.create(subscription_json)
  end

  def deactivate_stripe_subscription(response)
    StripeSubscription.update_with_status(response)
  end

  def create_json(customer, user)
    {customer_id: customer.id, account_balance: customer.account_balance, currency: customer.currency,
    default_source: customer.default_source, description: customer.description,
    source_url: customer.sources.url, user_id: user.id}
  end


  def self.fetch_user_from_payment_token(token)
    where(customer_id:  token).first
  end

  def active_subscription
    stripe_subscriptions.active.first
  end

  def active_subscription_plan
    stripe_subscriptions.active.first.plan_id
  end

  def has_subscription?
    stripe_subscriptions.present?
  end






end
