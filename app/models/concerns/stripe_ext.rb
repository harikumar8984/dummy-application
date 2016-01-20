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

  def self.change_plan(id, user, model)
    customer = Stripe::Customer.retrieve(user.stripe_customer_token)
    return customer.update_subscription({:plan => id })
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

  def self.cancel_subscription(user, model)
    customer = Stripe::Customer.retrieve(user.stripe_customer_token)
    #under assumption that has only active subscription at a time
    customer.subscriptions.data.each do |subscription|
        customer.subscriptions.retrieve(subscription.id).delete if subscription.status == 'active'
    end
    rescue Stripe::InvalidRequestError => e
      model.errors.add(:base, "Stripe error: #{e.message}")
      false
    rescue Stripe::CardError => e
      model.errors.add(:base, "Stripe error: #{e.message}")
      false
  end


  def self.webhook
    begin
      event_json = JSON.parse(request.body.read)
      event_object = event_json['data']['object']
      #refer event types here https://stripe.com/docs/api#event_types
      case event_json['type']
        when 'invoice.payment_succeeded'
          handle_success_invoice event_object
        when 'invoice.payment_failed'
          handle_failure_invoice event_object
        when 'charge.failed'
          handle_failure_charge event_object
        when 'customer.subscription.deleted'
        when 'customer.subscription.updated'
      end
    rescue Exception => ex
      render :json => {:status => 422, :error => "Webhook call failed"}
      return
    end
    render :json => {:status => 200}
  end

end

