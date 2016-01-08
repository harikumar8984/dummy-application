class Api::V1::UsersController < ApplicationController
  skip_before_filter :authenticate_user_from_token!, :only => :validate_unique_email
  skip_before_filter :authenticate_device, :only => :validate_unique_email
  respond_to :json

  def course_content
    content = {content: []}
    course_id = Course.where(criteria: params[:criteria]).pluck(:id).first
    content = Course.content_structure(course_id) unless course_id.nil?
    render :json => content
  end

  def validate_unique_email
    return render status: 200, :json=> {:success => false, errors: [t('no_email')]}  if params[:email].nil?
    user = User.find_by_email(params[:email])
    if user.blank?
        return render status: 200, :json=> {:success => true}
    else
        return render status: 200, :json=> {:success => false, messages: [t('email_already_exist')] }
    end
  end

  def get_content
    content = Content.active.where(id: params[:content_id]).first
    course = Course.where(id: params[:course_id]).first
    if is_blank_course_content(course, content)
      return render status: 200, :json=> {:success => false, messages: course.blank? ? [t('course_not_found')] : [t('content_not_found')] }
    end
    if content.is_file_exist?
      song_url = Rails.env.production? ? content_url(content) : request.base_url.to_s + content_url(content)
      progress = Progress.create(content_id: content.id, user_id: current_user.id, course_id: course.id,status: "TRANSMITTED")
      #data = Rails.env.production? ? open(content.name.url) : File.open(content.name.path,'r')
      return render status: 200, :json=> {:success => true, data: song_url }
      #send_data data.read, :disposition => 'inline'
    else
      return render status: 200, :json=> {:success => false, messages: [t('content_not_found')] }
    end
  end

  def player_usage_status
    usage_status_json = JSON.parse(params[:usage_status])
    course = Course.where(id: params[:course_id]).first
    user_id = current_user.id
    device_details = DeviceDetail.where(device_id: request.headers["device-id"]).first
    values = []
    columns = [:user_id, :device_detail_id, :course_id, :content_id, :usage_date, :duration ]
    usage_status_json.each do |usage_status|
      content = Content.active.where(id: usage_status[0]).first
      if is_blank_course_content(course, content)
        return render status: 200, :json=> {:success => false, messages: course.blank? ? [t('course_not_found')] : [t('content_not_found')] }
      end
      usage_status[1].each do |usage|
        values << [user_id, device_details.id, course.id, content.id, usage[0], usage[1]]
     end
    end
    PlayerUsageStat.import columns, values
    return render status: 201, :json=> {:success => true}
  end

  def content_url(content)
    params[:encrypted] ? content.name.encrypted.url : content.name.url
  end

  def is_blank_course_content(course, content)
    if course.blank? || content.blank?
      true
    end
  end

end