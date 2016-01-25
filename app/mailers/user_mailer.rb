class UserMailer < ActionMailer::Base
  default from: "admin@nuryl.com"

  def user_registered_to_nuryl(user, body)
    @user = user
    mail(to: @user.email, subject: body)
  end

  def transaction_mail(user, response)
    @user = user
    @status = true  if response['paid']
    @amount = response['amount']
    @error_code = response['failure_code']
    @error_message = response['failure_message']
    body = @status ? "Payment Sucess" : "Payment Failed"
    mail(to: @user.email, subject: body)
  end

  def subscription_mail(user, response)
    @user = user
   case response['status']
      when 'canceled'
        body = "Subscription Deactivated"
        @content = "Your subscription de-activated."
      when 'active'
        body = "Subscription Activated"
        @content = "Your subscription activated. You have choosen " + response['plan']['id'] + "plan."
      end
      mail(to: @user.email, subject: body)
  end

end

