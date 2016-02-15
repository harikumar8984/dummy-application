class CourseCategory < ActiveRecord::Base
  has_one :course, dependent: :destroy
end
