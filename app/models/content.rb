class Content < ActiveRecord::Base
  has_many :course_contents , dependent: :destroy
  has_many :courses, through: :course_contents, dependent: :destroy
  has_many :player_usage_stats, dependent: :destroy
end
