class CreateUserChildren < ActiveRecord::Migration
  def change
    create_table :user_children do |t|
      t.string :relationship

      t.timestamps null: false
    end
  end
end
