class AddUserToDeviceDetails < ActiveRecord::Migration
  def change
    add_reference :device_details, :user, index: true, foreign_key: true
  end
end
