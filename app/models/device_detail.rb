class DeviceDetail < ActiveRecord::Base
  belongs_to :user
  has_many :player_usage_stats, dependent: :destroy

  def device_type_enum
    [['Android'],['iPhone']]
  end
end
