class SubscriptionDetail < ActiveRecord::Base
  belongs_to :subscription, polymorphic: true
  belongs_to :user
  include SharedMethod

  after_create :change_user_date
  after_destroy :change_user_date
end
