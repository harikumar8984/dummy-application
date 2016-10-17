class StripeCustomer < ActiveRecord::Base
  include SharedMethod
  belongs_to :user
  has_many :transactions, dependent: :destroy
  has_many :stripe_subscriptions, dependent: :destroy
  after_create :change_user_date
  after_destroy :change_user_date

  def save_with_stripe_payment(user, params)
    unless params[:subscription_type].nil?
       if user.user_type == 'beta' && params[:subscription_type].capitalize == 'Yearly'
         plan_id = 'Beta'
       else
        plan_id = params[:subscription_type].capitalize
       end
    end
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
      paid_user_to_mailing_list(user)
    end
  end

  def update_card_detail(user, params)
    customer = StripeExt.update_card(user, params[:card_id], self)
    if customer
      update_attributes(default_source: customer.default_source)
      return true
    end
  end


  def save_with_in_app_payment(user, params)
    StripeCustomer.create(create_iap_json(user, params))
    paid_user_to_mailing_list(user)
  end

  def create_json(customer, user)
    {customer_id: customer.id, account_balance: customer.account_balance, currency: customer.currency,
    default_source: customer.default_source, description: customer.description,
    source_url: customer.sources.url, user_id: user.id, payment_type: 'stripe' }
  end

  def create_iap_json(user, params)
    {customer_id: params[:apple_id],  currency: params[:currency],user_id: user.id, payment_type: 'iap' }
  end

  private

  def paid_user_to_mailing_list user
    PaidUserToMailingListJob.perform_later(user , ENV["SUBSCRIBED_USER_MAILCHIMP_LIST_ID"], ENV['PAID_USER_MAILCHIMP_LIST_ID'])
  end



end
