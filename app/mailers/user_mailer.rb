class UserMailer < ActionMailer::Base
  default from: "admin@nuryl.com"

  def user_registered_to_nuryl(user, body)
    @user = user
    mail(to: @user.email, subject: body)
  end

end