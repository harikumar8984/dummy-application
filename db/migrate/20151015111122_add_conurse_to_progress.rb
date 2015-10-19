class AddConurseToProgress < ActiveRecord::Migration
  def change
    add_reference :progresses, :course, index: true, foreign_key: true
  end
end
