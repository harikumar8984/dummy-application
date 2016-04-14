class UserMailer < ActionMailer::Base
  default from: "admin@nuryl.com"

  def user_registered_to_nuryl(user, device_type, body)
    @user = user
    @device_type = device_type
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
        @content = "Your subscription account with Nuryl has been cancelled.
        We are sorry to see you leave but hope that you have enjoyed your Nuryl experience!"
      when 'active'
        body = "Subscription Activated"
        plan =  response['plan']['id'] == 'Beta' ? 'Yearly' : response['plan']['id']
        @content = "Thank you for subscribing to Nuryl's " + plan + " subscription. We hope you enjoy your experience with us!"
      end
      mail(to: @user.email, subject: body)
  end

  def help_mail(params)
    @user = params[:name]
    @description = params[:description]
    mail(from:params[:email], to: ENV['Support_Email'], subject: 'nuryl help')
  end



end

