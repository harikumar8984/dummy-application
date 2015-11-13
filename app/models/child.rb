class Child < ActiveRecord::Base
  has_one :user, through: :user_child , dependent: :destroy
  has_one :user_child
  #validates :dob, presence: true
end
