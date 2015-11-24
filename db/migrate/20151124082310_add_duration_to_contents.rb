class AddDurationToContents < ActiveRecord::Migration
  def change
    add_column :contents, :duration, :float
  end
end
