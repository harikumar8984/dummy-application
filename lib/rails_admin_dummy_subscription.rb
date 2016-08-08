module RailsAdmin
  module Config
    module Actions
      class DummySubscription < RailsAdmin::Config::Actions::Base
        # This ensures the action only shows up for Users
        register_instance_option :visible? do
          authorized? && bindings[:object].class == User & !bindings[:object].stripe_account?
        end
        # We want the action on members, not the Users collection
        register_instance_option :member do
          true
        end
        register_instance_option :link_icon do
          'icon-gift'
        end
        # You may or may not want pjax for your action
        register_instance_option :pjax? do
          false
        end
        register_instance_option :controller do
          Proc.new do
            user = @object
            subscription_json = {user_id: user.id , subscription_id: 'dummy_'+Digest::SHA1.hexdigest([Time.zone.now, rand].join), status: 'active', plan_id: 'dummy', amount:  'dummy', interval: 'dummy', payment_type: 'dummy'}
            if !user.stripe_account?
              customer_json =  {customer_id: 'dummy_'+Digest::SHA1.hexdigest([Time.zone.now, rand].join), account_balance: 0.00, currency: 'usd',
                                       description: 'Dummy stripe account', user_id: user.id, payment_type: 'dummy' }
              stripe_customer = StripeCustomer.create(customer_json)
              user.reload
              user.stripe_customer.stripe_subscriptions.create(subscription_json) if user.stripe_customer
              transaction_json = {user_id: user.id, customer_id:  'dummy_'+Digest::SHA1.hexdigest([Time.zone.now, rand].join),
                                  amount: 'dummy', currency: 'dummy', transaction_id: 'dummy_'+Digest::SHA1.hexdigest([Time.zone.now, rand].join),
                                  paid: false, purchase_date: Time.zone.now, payment_type: 'dummy', description: 'Dummy transactions'}
              user.stripe_customer.transactions.create(transaction_json) if user.stripe_customer
            elsif (!user.has_subscription? || (user.has_subscription? && !user.active_subscription?))
              user.stripe_customer.stripe_subscriptions.create(subscription_json) if user.stripe_customer
            else
              flash[:notice] = "#{@object.f_name} already had active subscriptions"
            end
            flash[:notice] = "You have add dummy subscription for user #{@object.f_name}."  if flash[:notice].blank?
            redirect_to back_or_index
          end
        end
      end
    end
  end
end