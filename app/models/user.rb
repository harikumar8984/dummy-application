class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_save :ensure_authentication_token!
  after_create :subscribe_user_to_mailing_list

  has_many :user_children, dependent: :destroy
  has_many :children, through: :user_children, dependent: :destroy
  has_one :device_detail, dependent: :destroy
  has_many :player_usage_stats, dependent: :destroy
  has_many :player_usage_stats_aggregate, dependent: :destroy
  has_many :progress, dependent: :destroy
  has_one :subscription
  has_many :subscription_details

  validates :f_name,:l_name, presence: true
  after_create :change_date

  def ensure_authentication_token!
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def admin?
    email == "admin@nuryl.com"
  end


  def self.user_from_authentication(token)
    User.find_by_authentication_token(token.to_s)
  end

  def self.user_from_payment_token(token, payment_class)
    payment_object = payment_class.fetch_user_from_payment_token(token)
    User.find(payment_object.user_id) unless payment_object.nil?
  end

  def self.from_user_id(id)
    where(id:  id).first
  end

  def has_account?
    subscription.present?
  end

  def account_type(account_type)
    has_account? && subscription.subscription_type == account_type
  end

  def account_type?
    subscription.subscription_type if has_account?
  end

  def active_subscription?
    has_account? && subscription.status == 'Active'
  end


  def my_subscription
    #under the assumption that last will be active one
    payment_type = subscription_details.try(:last).try(:subscription_type).try(:constantize)
    unless payment_type.nil?
      payment_type.find(subscription_details.last.subscription_id)
    else
      false
    end

  end

  def my_subscription_in_a_payment_type payment_type_class
    last_payment_type = subscription_details.where(subscription_type: payment_type_class).try(:last)
    payment_type = last_payment_type.try(:subscription_type).try(:constantize)
    unless payment_type.nil?
      return payment_type.find(last_payment_type.subscription_id)
    else
      return false
    end
  end

  def create_my_subscription(type, plan, start_date, status)
    plan_id = plan.nil? ? nil : plan.id
    unless has_account?
      Subscription.create(user_id: self.id, status: status , subscription_type: type, subscription_plan_id: plan_id, subscription_start_date: start_date, subscription_end_date: end_date(start_date, plan))
    else
      subscription.update_attributes(status: status, subscription_type: type, subscription_plan_id: plan_id, subscription_start_date: start_date, subscription_end_date: end_date(start_date, plan) )
    end
    paid_user_to_mailing_list
  end

  def create_my_subscription_details (obj)
    subscription_details.create(subscription: obj)
  end

  def update_my_subscription_plan(start_date, plan)
    subscription.update_attributes(subscription_plan_id: plan.id, subscription_start_date: start_date, subscription_end_date: end_date(start_date, plan))
  end

  def update_my_subscription_status status
    subscription.update_attributes(status: status)
  end

  def cancel_my_subscription status
    subscription.update_attributes(status: status, subscription_end_date: Date.today)
  end

  def end_date(start_date, plan)
     return nil if plan.nil?
     start_date + plan.date_from_plan
  end

  # Generate a friendly string randomly to be used as token.
  def self.friendly_token
    SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz')
  end

  def change_date
    update_attributes(changed_date: Time.zone.now)
  end


  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

  def subscribe_user_to_mailing_list
    SubscribeUserToMailingListJob.perform_later(self , ENV["SUBSCRIBED_USER_MAILCHIMP_LIST_ID"])
  end

  def paid_user_to_mailing_list
    PaidUserToMailingListJob.perform_later(self , ENV["SUBSCRIBED_USER_MAILCHIMP_LIST_ID"], ENV['PAID_USER_MAILCHIMP_LIST_ID'])
  end

end
