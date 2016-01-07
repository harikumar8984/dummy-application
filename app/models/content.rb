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
  before_save :save_meta_data_content
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

  def save_meta_data_content
    #reading
    reading_path = Rails.env == 'production' ? self.new_record? ? self.name.path : open(self.name.url) : self.name.path
    info = Mp3Info.open(reading_path)
    unless info.tag.nil?
      self.title = info.tag.album if self.title.blank?
      self.artist =  info.tag.artist if self.artist.blank?
    end
    unless info.tag2.nil?
      self.creator = info.tag2.TCOM  if self.creator.blank?
    end

    #writing
    if is_new?
    open("/tmp/#{self.id}/#{info.tag.album}", 'wb') do |file|
      file << open(self.name.url).read
    end
      writing_path = "/tmp/#{self.id}/#{info.tag.album}"
    else
      writing_path = self.name.path
    end
    Mp3Info.open(writing_path) do |mp3|
      unless info.tag.nil?
        mp3.tag.album = self.title unless self.title.blank?
        mp3.tag.artist = self.artist unless self.artist.blank?
      end
      unless info.tag2.nil?
        mp3.tag2.TCOM = self.creator unless self.creator.blank?
      end
    end
    self.name = File.open("/tmp/#{self.id}/#{info.tag.album}") if is_new?

  end

  def is_new?
    if !self.new_record? && Rails.env == 'production' && !self.name_changed?
      true
    else
      false
    end
  end

end
