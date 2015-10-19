class CourseContent < ActiveRecord::Base
  belongs_to :course
  belongs_to :content
end
