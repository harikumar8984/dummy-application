class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :subscription_plan
  include SharedMethod

  after_create :change_user_date
  after_destroy :change_user_date


  def status_enum
    [['Active'],['Canceled']]
  end

end
