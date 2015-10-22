class Course < ActiveRecord::Base
  has_many :course_contents, dependent: :destroy
  has_many :contents, through: :course_contents, dependent: :destroy
  has_many :player_usage_stats, dependent: :destroy

  def self.content_structure(course_id)
    criteria = Course.where(id: course_id).pluck(:criteria).first
    course_content = CourseContent.where(course_id: course_id).includes(:content).order(:seq_no)
    content_structure=  {criteria: criteria, course_id: course_id, video: [], text: [], audio: []}
    course_content.each do |course|
      if course.content.content_type == "Audio"
        content_structure[:audio] << course.content.id
      elsif course.content.content_type == "Video"
        content_structure[:video] << course.content.id
      elsif course.content.content_type == "Text"
        content_structure[:text] << course.content.id
      end
    end
    {content: content_structure}
  end

end
