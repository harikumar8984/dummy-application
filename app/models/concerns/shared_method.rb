module SharedMethod
  extend ActiveSupport::Concern

  def change_user_date
    user = User.find(self.user_id)
    user.update_attributes(changed_date: Time.zone.now)  unless user.nil?
  end

end
