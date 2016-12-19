class IapPaymentService
  class PaymentError < StandardError; end

  def create_payment_service(user, params)
    in_app_purchase = InAppPurchase.new
      raise PaymentError.new 'IAP error: Purchase Date cannot be blank'  if params[:purchase_date].blank?
      params[:purchase_date] = dob_format(params[:purchase_date])
      raise PaymentError.new 'IAP error: Invalid Purchase Date format' if params[:purchase_date].nil?
      raise PaymentError.new 'IAP error: Apple Id cannot be blank'  if params[:apple_id].blank?
      raise PaymentError.new 'IAP error: Apple Id is not unique'  unless is_unique_apple_id(params[:apple_id]).nil?
      unless in_app_purchase.save_with_iap_payment(user, params)
        raise PaymentError.new in_app_purchase.errors.messages[:base][0]
      else
        true
      end
  end


  def subscription_type_service
   payment_type = SubscriptionPlan.where('name !=?', 'Beta')
   pay_type = []
   if payment_type.present?
     payment_type.each do |plan|
       pay_type << ENV['In_App_Purchase_Subscription']+plan.name.downcase
     end
   end
    pay_type
  end

  def new_subscription_service(user, params)
    if is_iap_account?(user)
      raise PaymentError.new 'IAP error: Apple Id cannot be blank'  if params[:apple_id].blank?
      iap =  my_subscription(user)
      if iap.present?
        unless iap.iap_new_subscription(params, user)
          raise PaymentError.new iap.errors.messages[:base][0]
        end
      end
    end
  end

  def cancel_subscription_service(user, params)
    if is_iap_account?(user)
      iap =  my_subscription(user)
      if iap.present?
        unless iap.iap_cancel_subscription(user)
          raise PaymentError.new iap.errors.messages[:base][0]
        end
      end
   end
  end

  def dob_format(date_input)
    format = date_input.include?("/") ? "%m/%d/%Y" : "%m-%d-%Y"
    Date.strptime(date_input, format)
  end

  def is_unique_apple_id id
    InAppPurchase.where(apple_id: id).first
  end

  def is_iap_account?(user)
    unless user.account_type("IAP")
      raise PaymentError.new 'Current subscription is not IAP subscription.'
      return false
    else
      true
    end
  end

  def my_subscription(user)
    iap =  user.my_subscription_in_a_payment_type('InAppPurchase')
    unless iap
      raise PaymentError.new 'User do not have any In App subscription.'
      return false
    else
      iap
    end
  end

end