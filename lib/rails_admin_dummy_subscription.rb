module RailsAdmin
  module Config
    module Actions
      class DummySubscription < RailsAdmin::Config::Actions::Base
        # This ensures the action only shows up for Users
        register_instance_option :visible? do
          authorized? && bindings[:object].class == User & !bindings[:object].account_type("STRIPE")
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
            plan = SubscriptionPlan.subscription_with_name('Monthly').first
            unless user.active_subscription?
              user.create_my_subscription('Dummy', plan, Date.today, 'Active')
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