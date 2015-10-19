class CreateDeviceDetails < ActiveRecord::Migration
  def change
    create_table :device_details do |t|
      t.string :status
      t.timestamps null: false
    end
  end
end
