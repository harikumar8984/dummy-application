module StripeExt
  extend ActiveSupport::Concern

  def self.retrieve_plan(id, model)
    return Stripe::Plan.retrieve(id)
    rescue Stripe::InvalidRequestError => e
     model.errors.add(:base, "Stripe error: #{e.message}")
     false
  end

  def self.create_customer(email, plan, card, model)
    Stripe::Customer.create(email: email, plan: plan , card: card)
    rescue Stripe::InvalidRequestError => e
      model.errors.add(:base, "Stripe error: #{e.message}")
      false
    rescue Stripe::CardError => e
      model.errors.add(:base, "Stripe error: #{e.message}")
      false
  end

  def self.change_plan(plan_id, subscription_id, user, model)
    customer = Stripe::Customer.retrieve(user.stripe_customer_token)
    subscription = customer.subscriptions.retrieve(subscription_id)
    subscription.plan = plan_id
    return subscription.save
    rescue Stripe::InvalidRequestError => e
      model.errors.add(:base, "Stripe error: #{e.message}")
      false
    rescue Stripe::CardError => e
      model.errors.add(:base, "Stripe error: #{e.message}")
      false
  end

  def self.new_subscription(id, user, model)
    customer = Stripe::Customer.retrieve(user.stripe_customer_token)
    return customer.subscriptions.create(:plan => id)
   rescue Stripe::InvalidRequestError => e
    model.errors.add(:base, "Stripe error: #{e.message}")
    false
  rescue Stripe::CardError => e
    model.errors.add(:base, "Stripe error: #{e.message}")
    false
  end

  def self.cancel_subscription(user, subscription_id , model)
    customer = Stripe::Customer.retrieve(user.stripe_customer_token)
    #under assumption that has only active subscription at a time
    customer.subscriptions.retrieve(subscription_id).delete
    rescue Stripe::InvalidRequestError => e
      model.errors.add(:base, "Stripe error: #{e.message}")
      false
    rescue Stripe::CardError => e
      model.errors.add(:base, "Stripe error: #{e.message}")
      false
  end


  def self.webhook(event_json)
    begin
      event_object = event_json['data']['object']
      case event_json['type']
        when 'charge.succeeded'
          Transaction.create_transaction(event_object, event_json['type'])
        when 'charge.failed'
          Transaction.create_transaction(event_object, event_json['type'])
        when 'customer.subscription.deleted'
          StripeSubscription.subscription_details_to_user(event_object, event_json['type'])
        when 'customer.subscription.created'
          StripeSubscription.subscription_details_to_user(event_object, event_json['type'])
        # when 'customer.subscription.updated'
        #   StripeSubscription.subscription_details_to_user(event_object, event_json['type'])
      end
    rescue Exception => ex
      return false
    end

  end

end

