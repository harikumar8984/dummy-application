module StripeExt
  extend ActiveSupport::Concern

  def self.retrieve_plan(id, model)
    begin
      return Stripe::Plan.retrieve(id)
    rescue => e
      model.errors.add(:base, "Stripe error: #{e.message}")
      false
    end
  end

  def self.create_customer(email, plan, card, model)
    begin
      Stripe::Customer.create(email: email, plan: plan , card: card)
    rescue => e
      model.errors.add(:base, "Stripe error: #{e.message}")
      false
    end
  end

  def self.change_plan(plan_id, subscription_id, user, model)
    begin
      customer = stripe_customer_from_token(model.customer_id)
      subscription = customer.subscriptions.retrieve(subscription_id)
      subscription.plan = plan_id
      return subscription.save
    rescue  => e
      model.errors.add(:base, "Stripe error: #{e.message}")
      false
    end
  end

  def self.new_subscription(id, model)
    begin
      customer = stripe_customer_from_token(model.customer_id)
      return customer.subscriptions.create(:plan => id)
    rescue => e
      model.errors.add(:base, "Stripe error: #{e.message}")
      false
    end
  end

  def self.cancel_subscription(subscription_id , model)
    begin
      customer = stripe_customer_from_token(model.customer_id)
      #under assumption that has only active subscription at a time
      return customer.subscriptions.retrieve(subscription_id).delete
    rescue => e
      model.errors.add(:base, "Stripe error: #{e.message}")
      false
    end
  end


  def self.get_all_plan
    begin
      Stripe::Plan.all
    rescue => e
      false
    end
  end


  def self.update_card(user, card, model)
    customer = stripe_customer_from_token(model.customer_id)
    customer.source = card # obtained with Stripe.js
    return customer.save
  rescue => e
      model.errors.add(:base, "Stripe error: #{e.message}")
      return false
  end


  def self.webhook(event_json)
    begin
      event_object = event_json['data']['object']
      user = User.user_from_payment_token(event_object['customer'], "StripeCustomer".constantize)
      if user
        case event_json['type']
          when 'charge.succeeded'
            StripeTransaction.create_transaction(event_object, event_json['type'], user)
            if user.account_type('STRIPE')
              plan_id = user.subscription.subscription_plan_id rescue nil
              plan = SubscriptionPlan.find(plan_id) unless plan_id.nil?
              user.update_my_subscription_plan(Date.today, plan)
              user.update_my_subscription_status('Active')
            end
          when 'charge.failed'
            StripeTransaction.create_transaction(event_object, event_json['type'], user)
          when 'customer.subscription.deleted'
            StripeSubscription.subscription_details_to_user(event_object, event_json['type'])
            user.cancel_my_subscription('InActive')
          when 'customer.subscription.created'
            StripeSubscription.subscription_details_to_user(event_object, event_json['type'])
          # when 'customer.subscription.updated'
          #   StripeSubscription.subscription_details_to_user(event_object, event_json['type'])
        end
      end
    rescue Exception => ex
      return false
    end

  end

  def self.stripe_customer_from_token token
    Stripe::Customer.retrieve(token)
  end

end

