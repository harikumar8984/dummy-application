class Transaction < ActiveRecord::Base
  include SharedMethod
  #extend StripeExt
  belongs_to :stripe_customer
  after_create :change_user_date
  after_destroy :change_user_date

  def self.create_transaction(response, type)
    user = User.user_from_stripe_customer(response['customer'])
      if user
        if user.stripe_account?
            user.stripe_customer.transactions.create(create_json(user.id, response, type))
        else
          create(create_json(user.id, response, type))
        end
         UserMailer.transaction_mail(user, response).deliver
      end

  end

  def self.create_json(user_id, response, type)
    {user_id: user_id, customer_id:  response['customer'], amount: response['amount'], currency: response['currency'],
    transaction_id: response['id'], invoice_id: response['invoice'], status: response['status'],
    balance_transaction_id: response['balance_transaction'], description: response['description'],
    failure_code: response['failure_code'], failure_message: response['failure_message'],
    paid: response['paid'], transaction_type: type, statement_descriptor: response['statement_descriptor'],
    purchase_date: Time.now, payment_type: 'stripe'}
  end

  def self.save_with_in_app_transaction(user, params)
    user.stripe_customer.transactions.create(create_iap_transaction_json(user, params))
  end

  def self.create_iap_transaction_json(user, params)
    {user_id: user.id, customer_id:  params[:apple_id], amount: params[:amount], currency: params[:currency],
     transaction_id: params[:transaction_id], status: params[:transaction_status],failure_message: params[:failure_messsage],
     paid: params[:paid], purchase_date: params[:purchase_date], payment_type: 'iap'}
  end

end
