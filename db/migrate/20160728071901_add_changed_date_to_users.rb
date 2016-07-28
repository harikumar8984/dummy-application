class AddChangedDateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :changed_date, :datetime
  end
end
