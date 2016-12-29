class PaypalPurchase < ActiveRecord::Base
  has_many :subscription_details, as: :subscription
  has_many :paypal_transactions
  include Tokenable

  def save_with_paypal_payment(params)
      update_attributes(purchase_date: Time.now)
      paypal_transactions.create(create_json(params))
      plan = SubscriptionPlan.subscription_with_name(duration).first
      user = User.find(user_id)
      unless user.nil?
        if user.account_type('PAYPAL')
          user.update_my_subscription_plan(Date.today, plan)
          user.update_my_subscription_status('Active')
        else
         user.create_my_subscription('PAYPAL', plan, Date.today, 'Active')
         user.create_my_subscription_details(self)
        end
        return true
      end
  end

  def paypal_url(params, return_path)
    plan = SubscriptionPlan.subscription_with_name(params[:subscription_type]).first
    values = {
        business: ENV["PAYPAL_EMAIL"],
        cmd: "_xclick",
        upload: 1,
        return: return_path,
        invoice: token,
        amount: params[:amount],
        item_name: "Nuryl " + params[:subscription_type].to_s + ' Subscription',
        item_number: params[:subscription_type].to_s,
        quantity: '1',
        notify_url: "#{ENV["PAYPAL_APP_HOST"]}/transactions/paypal_hook"
    }
    "#{ENV['PAYPAL_HOST']}/cgi-bin/webscr?" + values.to_query
  end


  # def paypal_url(params, return_path)
  #   plan = SubscriptionPlan.subscription_with_name(params[:subscription_type]).first
  #   values = {
  #       business: ENV["PAYPAL_EMAIL"],
  #       upload: 1,
  #       no_shipping: 1,
  #       return: return_path,
  #       notify_url: "#{ENV['PAYPAL_APP_HOST']}/transactions/paypal_hook",
  #       invoice: token,
  #       item_name: "Nuryl " + params[:subscription_type].to_s + ' Subscription',
  #       cmd: "_xclick-subscriptions",
  #       a3: params[:amount],
  #       p3: 1,
  #       #srt: plan.cycles_from_plan,
  #       t3: plan.period_from_plan
  #   }
  #   "#{ENV['PAYPAL_HOST']}/cgi-bin/webscr?" + values.to_query
  # end


  def create_json(params)
    {notification_params: params, status: params[:status], transaction_id: params[:txn_id], purchase_date: Time.now}
  end

end
