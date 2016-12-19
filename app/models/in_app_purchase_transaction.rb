class InAppPurchaseTransaction < ActiveRecord::Base
  belongs_to :in_app_purchase

  def self.create_json(iap, user, params)
    {user_id: user.id, transaction_date: params[:purchase_date],transaction_id: params[:transaction_id] || iap.apple_id,
     currency: params[:currency], amount:  params[:amount], failure_message: params[:failure_message], paid: params[:paid],
     transaction_status: params[:transaction_status], in_app_purchase_id: iap.id}
  end
end
