class CreateProgresses < ActiveRecord::Migration
  def change
    create_table :progresses do |t|
      t.datetime :started_at
      t.datetime :finished_at
      t.string :details
      t.string :status

      t.timestamps null: false
    end
  end
end
