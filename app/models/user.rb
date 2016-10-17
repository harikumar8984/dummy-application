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
  has_one :stripe_customer, dependent: :destroy
  has_many :transactions, dependent: :destroy

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

  def update_stripe_customer_token(token)
    update_attributes(stripe_customer_token: token, subscription_token: nil)
  end

  def self.user_from_authentication(token)
    User.find_by_authentication_token(token.to_s)
  end

  def self.user_from_stripe_customer(token)
    where(stripe_customer_token:  token).first
  end

  def self.from_user_id(id)
    where(id:  id).first
  end

  def stripe_account?
    stripe_customer.present?
  end

  def active_subscription?
    stripe_customer.stripe_subscriptions.active.present?
  end

  def active_subscription
    stripe_customer.stripe_subscriptions.active.first
  end

  def active_subscription_plan
    stripe_customer.stripe_subscriptions.active.first.plan_id
  end

  def payment_type
    stripe_customer.payment_type
  end

  def has_subscription?
    stripe_customer.stripe_subscriptions.present?
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

end
