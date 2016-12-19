class AddSubscriptionPlanData < ActiveRecord::Migration
  def up
      SubscriptionPlan.find_or_create_by(name: 'Beta', display_name: 'Yearly', amount:'79.99', interval: 'Yearly')
      SubscriptionPlan.find_or_create_by(name: 'Monthly', display_name: 'Monthly', amount:'9.99', interval: 'Monthly')
      SubscriptionPlan.find_or_create_by(name: 'Yearly', display_name: 'Yearly', amount:'79.99', interval: 'Yearly')
      SubscriptionPlan.find_or_create_by(name: 'Gift', display_name: 'Gift', amount:'99.99', interval: 'Yearly')
    end
end
