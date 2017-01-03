class SubscriptionPlan < ActiveRecord::Base
  scope :subscription_with_name, ->(name) {where(name: name)}
  has_many :subscriptions

  def date_from_plan
    interval == "Yearly" ? 1.year : 1.month
  end

  def cycles_from_plan
    interval == "Yearly" ? 3 : 36
  end

  def period_from_plan
    interval == "Yearly" ? "Year" : "Month"
  end

end
