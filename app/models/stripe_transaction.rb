class StripeTransaction < ActiveRecord::Base
  include SharedMethod
  #extend StripeExt
  belongs_to :stripe_customer
  after_create :change_user_date
  after_destroy :change_user_date

  def self.create_transaction(response, type, user)
    payment_type = user.my_subscription_in_a_payment_type "StripCustomer"
    if payment_type
      payment_type.transactions.create(create_json(user.id, response, type))
    else
      create(create_json(user.id, response, type))
    end
  end

  def self.create_json(user_id, response, type)
    {user_id: user_id, customer_id:  response['customer'], amount: response['amount'], currency: response['currency'],
    transaction_id: response['id'], invoice_id: response['invoice'], status: response['status'],
    balance_transaction_id: response['balance_transaction'], description: response['description'],
    failure_code: response['failure_code'], failure_message: response['failure_message'],
    paid: response['paid'], transaction_type: type, statement_descriptor: response['statement_descriptor'],
    purchase_date: Time.zone.now}
  end



  # paypal methods
  # def self.purchase(price_in_cents, credit_card, purchase_options)
  #   response = GATEWAY.purchase(price_in_cents, credit_card, purchase_options)
  #   # response.success?
  # end
  
  # def self.price_in_cents(amount)
  #   (amount*100).round
  # end
  # # private
  
  # def self.purchase_options(ip_address, first_name, address1, city, state, country, zip)
  #   {
  #     :ip => ip_address,
  #     :billing_address => {
  #       :name     => first_name,
  #       :address1 => address1,
  #       :city     => city,
  #       :state    => state,
  #       :country  => country,
  #       :zip      => zip
  #     }
  #   }
  # end
  
  # def validate_card
  #   unless credit_card.valid?
  #     credit_card.errors.full_messages.each do |message|
  #       errors.add_to_base message
  #     end
  #   end
  # end
  
  # def self.credit_card(card_type, card_number, card_verification, card_expires_on, first_name, last_name)
  #   @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
  #     :type               => card_type,
  #     :number             => card_number,
  #     :verification_value => card_verification,
  #     :month              => card_expires_on[:month],
  #     :year               => card_expires_on[:year],
  #     :first_name         => first_name,
  #     :last_name          => last_name
  #   )
  # end

end
