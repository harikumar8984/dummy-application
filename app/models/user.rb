class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_save :ensure_authentication_token!

  has_many :user_children, dependent: :destroy
  has_many :children, through: :user_children, dependent: :destroy
  has_one :device_detail, dependent: :destroy
  has_many :player_usage_stats, dependent: :destroy
  has_many :progress, dependent: :destroy
  has_many :transactions, dependent: :destroy

  validates :f_name,:l_name, :type_of_subscription, presence: true

  def ensure_authentication_token!
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def admin?
    email == "admin@nuryl.com"
  end

  def update_stripe_customer_token(token)
    update_attributes(stripe_customer_token: token)
  end

  def self.user_from_authentication(token)
    User.find_by_authentication_token(token.to_s)
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

end
