class StripeCustomer < ActiveRecord::Base
  belongs_to :user
  has_many :transactions, dependent: :destroy
  has_many :stripe_subscriptions, dependent: :destroy

  def save_with_payment(user, params)
    plan_id = params[:subscription_type].capitalize unless params[:subscription_type].nil?
    if plan_id.nil?
      self.errors.add(:base, "User don't provide any type of subscription")
      return false
    end
    customer = StripeExt.create_customer(user.email, plan_id, params[:card_id], self)
    if customer
      user.update_stripe_customer_token(customer.id)
      stripe_customer = StripeCustomer.create(create_json(customer, user))
      subscription_json =StripeSubscription.create_json(customer.subscriptions.data[0], user)
      stripe_customer.stripe_subscriptions.create(subscription_json)
    end
  end

  def create_json(customer, user)
    {customer_id: customer.id, account_balance: customer.account_balance, currency: customer.currency,
    default_source: customer.default_source, description: customer.description,
    source_url: customer.sources.url, user_id: user.id }
  end




end
