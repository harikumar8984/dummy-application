class Changetablename < ActiveRecord::Migration
  def change
    rename_table :progresses, :progress
  end
end


