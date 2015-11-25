require 'openssl'
require 'base64'
require 'mp3info'

class Content < ActiveRecord::Base
  has_many :course_contents , dependent: :destroy
  has_many :courses, through: :course_contents, dependent: :destroy
  has_many :player_usage_stats, dependent: :destroy
  has_many :progress, dependent: :destroy
  validates :content_type, inclusion: { in: %w(VIDEO AUDIO TEXT), message: "%{value} is not a valid type" }
  validates :status, inclusion: { in: %w(ACTIVE INACTIVE) , message: "%{value} is not a valid status" }
  validates :name, :status, :content_type, presence: true
  mount_uploader :name, ContentUploader
  before_save :add_file_duration
  scope :active, -> { where(status: 'ACTIVE') }

  def content_type_enum
    [['VIDEO'],['AUDIO'],['TEXT']]
  end

  def status_enum
    [['ACTIVE'],['INACTIVE']]
  end

  def is_file_exist?
    self.name.file.exists? || File.exists?(self.name.path)
  end

  def add_file_duration
    info = Mp3Info.open(self.name.path)
    self.duration =  info.length.round(2) unless info.nil?
  end

end
