class AddDeviceOsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :device_os, :string
  end
end
