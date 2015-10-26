class AddContentToProgress < ActiveRecord::Migration
  def change
    add_reference :progresses, :content, index: true, foreign_key: true
  end
end
