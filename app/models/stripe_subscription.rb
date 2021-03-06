class StripeSubscription < ActiveRecord::Base
  belongs_to :stripe_customers
  scope :active, -> { where(status: 'active') }

  def status_enum
    [['active'],['canceled']]
  end

  def self.create_json(subscription, user)
    plan_details = {}
    subscription_details = {subscription_id: subscription.id, status: subscription.status,
     tax_percent: subscription.tax_percent, subscription_url: subscription.url, user_id: user.id}

    unless subscription.plan.nil?
      plan_details= {
          plan_id: subscription.plan.id, amount: subscription.plan.amount, interval: subscription.plan.interval
      }

    end
    subscription_details.merge(plan_details)
  end


  def update_plan_details(plan)
    self.update_attributes(plan_id: plan.id, interval: plan.interval, amount: plan.amount)
  end

  def self.subscription_details_to_user(response, type)
    update_with_status(response)
  end

  def self.update_with_status(response)
    subscription = where(subscription_id:  response['id']).first
    subscription.update_attributes(status: response['status']) if subscription
  end
end
