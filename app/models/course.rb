class Course < ActiveRecord::Base
  has_many :course_contents, dependent: :destroy
  has_many :contents, through: :course_contents, dependent: :destroy
# has_many :player_usage_stats, dependent: :destroy
  has_many :progress, dependent: :destroy
  validates :status, inclusion: { in: %w(ACTIVE INACTIVE) , message: "%{value} is not a valid status" }
  validates :course_name,:status,:criteria, presence: true

  def self.content_structure(course_id)
    criteria = Course.where(id: course_id).pluck(:criteria).first
    course_content = CourseContent.where(course_id: course_id).includes(:content).order(:seq_no)
    content_structure=  {criteria: criteria, course_id: course_id, video: [], text: [], audio: []}
    course_content.each do |course|
      is_file = course.content.is_file_exist?
      if is_file
        type = course.content.content_type.downcase.to_sym if course.content.content_type
        content_structure[type] << course.content.id
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
