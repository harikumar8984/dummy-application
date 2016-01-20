class Transaction < ActiveRecord::Base
  #extend StripeExt
  belongs_to :user

  def save_with_payment(user, params)
     plan_id = user.type_of_subscription.camelize unless user.type_of_subscription.nil?
     if plan_id.nil?
       self.errors.add(:base, "User don't provide any type of subscription")
       return false
     end
    customer = StripeExt.create_customer(user.email, plan_id, params[:card_id], self)
    if customer
      user.update_stripe_customer_token(customer.id)
      if user.transactions.blank?
        user.transactions.create(create_json(customer))
      else
        user.transactions.first.update_attributes(create_json(customer))
      end
    end
  end

  def create_json(customer)
    subscription_details = {}
    source_details = {customer_id: customer.id, account_balance: customer.account_balance, currency: customer.currency,
                      default_source: customer.default_source, delinquent: customer.delinquent,
                      description: customer.description, source_url: customer.sources.url }
    unless customer.subscriptions.data[0].nil?
      subscription_details= {subscription_id: customer.subscriptions.data[0].id,
                             plan_id: customer.subscriptions.data[0].plan.nil? ? '' : customer.subscriptions.data[0].plan.id,
                             amount: customer.subscriptions.data[0].plan.nil? ? '' : customer.subscriptions.data[0].plan.amount,
                             interval: customer.subscriptions.data[0].plan.nil? ? '' : customer.subscriptions.data[0].plan.interval,
                             quantity: customer.subscriptions.data[0].quantity,
                             tax_percent: customer.subscriptions.data[0].tax_percent,
                             subscription_url: customer.subscriptions.data[0].url}

    end
    source_details.merge(subscription_details)
  end

end
