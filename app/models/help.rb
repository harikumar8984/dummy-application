class Help < ActiveRecord::Base
  validates :name, :email, :description, presence: true
end
