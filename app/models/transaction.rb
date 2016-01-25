class Transaction < ActiveRecord::Base
  #extend StripeExt
  belongs_to :stripe_customer

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
    transaction_id: response['id'], invoice_id: response['invoice'], status: response['paid'],
    balance_transaction_id: response['balance_transaction'], description: response['description'],
    failure_code: response['failure_code'], failure_message: response['failure_message'],
    paid: response['paid'], transaction_type: type, statement_descriptor: response['statement_descriptor']}
  end

end
