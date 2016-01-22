class Api::V1::UsersController < ApplicationController
  include UserCommonMethodControllerConcern
  skip_before_filter :authenticate_user_from_token!, :only => :validate_unique_email
  skip_before_filter :authenticate_device, :only => :validate_unique_email
  respond_to :json

  def course_content
    content = {content: []}
    course_id = Course.where(criteria: params[:criteria]).pluck(:id).first
    content = Course.content_structure(course_id) unless course_id.nil?
    render :json => {:success => true, data: content }
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
      return render status: 200, :json=> {:success => true, data: {url: song_url, title: content.title, artist: content.artist, creator: content.creator } }
      #send_data data.read, :disposition => 'inline'
    else
      return render status: 200, :json=> {:success => false, messages: [t('content_not_found')] }
    end
  end

  def player_usage_status
    unless params[:usage_status]
      return render status: 200, :json=> {:success => false, messages: 'Please provide duration details of songs' }
    end
    usage_status_json = JSON.parse(params[:usage_status].to_json)
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

  def send_usage_statics_info
    user = user_from_auth_token
    filter = case params[:filter]
               when "7_Days" then 7.days
               when "1_Month" then 1.month
               when '1_Year' then 1.year
               else  1.day
             end
    filter_date = Date.today() - filter
    data = []
    usage_stats = user.player_usage_stats.select(" usage_date as usage_date, sum(duration) as duration").where("DATE(usage_date) >= ?", filter_date).group("date(usage_date)")
    usage_stats.each do |usage_status|
      if usage_status.usage_date
        data << ({date: usage_status.usage_date.to_date, duration: usage_status.duration})
      end
    end
    return render status: 200, :json=> {:success => true, data: data }
   end

  def edit_profile
    user = user_from_auth_token
    child = user.children.first
    data = {f_name: user.f_name, l_name: user.l_name, baby_name: child.name, dob: child.dob, zipcode: user.zipcode}
    return render status: 200, :json=> {:success => true, data: data }
  end


  def update_profile
    @user = user_from_auth_token
    @user.update_attributes(update_params)
    dob_format if params[:dob]
    child = @user.children.first.update_attributes(dob: params[:dob], name: params[:baby_name])
    unless child
      return render :status => 200, :json => {:success => false, :errors => "Child data not updated"}
    else
      return render status: 201, :json=> {:success => true, data: {data: "Profile updated" } }
    end
  end

end