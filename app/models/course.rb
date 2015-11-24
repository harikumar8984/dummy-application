class Course < ActiveRecord::Base
  has_many :course_contents, dependent: :destroy
  has_many :contents, through: :course_contents, dependent: :destroy
  has_many :player_usage_stats, dependent: :destroy
  validates :status, inclusion: { in: %w(ACTIVE INACTIVE) , message: "%{value} is not a valid status" }
  validates :course_name,:status,:criteria, presence: true

  def self.content_structure(course_id)
    criteria = Course.where(id: course_id).pluck(:criteria).first
    course_content = CourseContent.where(course_id: course_id).includes(:content).order(:seq_no)
    content_structure=  {criteria: criteria, course_id: course_id, duration: 0.00, video: [], text: [], audio: []}
    course_content.each do |course|
      is_file = course.content.is_file_exist?
      if is_file
        type = course.content.content_type.upcase if course.content.content_type
        if type == "AUDIO"
          content_structure[:audio] << course.content.id
        elsif type == "VIDEO"
          content_structure[:video] << course.content.id
        elsif type == "TEXT"
          content_structure[:text] << course.content.id
        end
        content_structure[:duration] += course.content.duration
      end
    end
    {content: content_structure}
  end

  def criteria_enum
    [['Welcome Content'],['Month 5'],['Month 6'],['Month 7'], ['Month 8'], ['Month 9'], ['Month 10'], ['Month 11'], ['Year 1']]
  end

  def status_enum
    [['ACTIVE'],['INACTIVE']]
  end

end
