class DeviceDetail < ActiveRecord::Base
  belongs_to :user
  has_many :player_usage_stats, dependent: :destroy
end
