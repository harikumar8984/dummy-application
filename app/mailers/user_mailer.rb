class UserMailer < ActionMailer::Base
  default from: "admin@nuryl.com"

  def user_registered_to_nuryl_with_template(user, device_type, body, context)
    @user = user
    content = MailTemplate.find_by_device_type_and_context(device_type, context).content rescue nil
    unless  content.nil?
      liquid_template(content)
      mail(to: @user.email, subject: body)
    end
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

  def test_mail(response, status)
    @response = response
    mail(from: ENV['Support_Email'], to:'harikumar8984@gmail.com', subject: status)
  end

  def payment_form_mail(user, context, subject)
    @user = user
    content = MailTemplate.find_by_context(context).content rescue nil
    unless  content.nil?
      liquid_template(content)
      mail(to: @user.email, subject: subject)
    end
  end

  def liquid_template(content)
    template = Liquid::Template.parse(content)
    @template = template.render('name' => @user.f_name).html_safe
  end

end

