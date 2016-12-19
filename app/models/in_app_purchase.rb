class InAppPurchase < ActiveRecord::Base
  has_many :subscription_details, as: :subscription
  has_many :in_app_purchase_transactions, dependent: :destroy
  scope :with_apple_id, ->(apple_id, user_id) {where(apple_id: apple_id, user_id: user_id)}

  def save_with_iap_payment(user, params)
    iap_payment= InAppPurchase.create(create_json(user, params))
    if iap_payment.present?
      create_iap_transaction(iap_payment, user, params)
      plan = SubscriptionPlan.subscription_with_name(params[:subscription_type]).first
      user.create_my_subscription('IAP', plan, Date.today,'Active')
      user.create_my_subscription_details(iap_payment)
      return true
    else
      self.errors.add(:base, "IAP error: #{e.message}")
      return false
    end
  end

  def iap_cancel_subscription(user)
    user.cancel_my_subscription('Cancelled')
  end


  def iap_new_subscription(params, user)
    in_app_purchase = InAppPurchase.with_apple_id(params[:apple_id], user.id).first
    if in_app_purchase.nil?
      self.errors.add(:base, "Apple Id provided is not a valid one for this user")
      return false
    else
      in_app_purchase.update_attributes(purchase_start_date: params[:purchase_date],
                                        status: params[:status], duration: params[:subscription_type] )
      create_iap_transaction(in_app_purchase, user, params)
      plan = SubscriptionPlan.subscription_with_name(params[:subscription_type]).first
      user.update_my_subscription_plan(Date.today, plan)
      user.update_my_subscription_status('Active')
    end
  end

  def create_iap_transaction(iap_payment, user, params)
    InAppPurchaseTransaction.create(iap_payment.in_app_purchase_transactions.create_json(iap_payment, user, params))
  end

  def create_json(user, params)
    {apple_id: params[:apple_id],  user_id: user.id, purchase_start_date: params[:purchase_date],
     status: params[:status], duration: params[:subscription_type]}
  end

end
