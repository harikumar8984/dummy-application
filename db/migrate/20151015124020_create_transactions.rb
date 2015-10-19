class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.datetime :date
      t.string :status
      t.string :details

      t.timestamps null: false
    end
  end
end
