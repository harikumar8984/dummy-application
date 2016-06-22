class Api::V1::UsersController < ApplicationController
  include UserCommonMethodControllerConcern
  skip_before_filter :is_device_id?, :only => :validate_unique_email
  skip_before_filter :authenticate_user_from_token!, :only => :validate_unique_email
  skip_before_filter :authenticate_device, :only => :validate_unique_email
  respond_to :json

  def course_content
    unless has_stripe_account_active?
      content = {content: []}
      course_category = CourseCategory.where(name: params[:criteria]).first
      course =  course_category.course unless course_category.nil?
      content = Course.content_structure(course.id) unless course.nil?
      render :json => {:success => true, data: content }
    end
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
    unless has_stripe_account_active?
      content = Content.active.where(id: params[:content_id]).first
      course = Course.where(id: params[:course_id]).first
      if is_blank_course_content(course, content)
        return render status: 200, :json=> {:success => false, messages: course.blank? ? [t('course_not_found')] : [t('content_not_found')] }
      end
      if content.is_file_exist?
        song_url = Rails.env.production? ? content_url(content) : request.base_url.to_s + content_url(content)
        #we don't have to verify this progress of transmitting data
        #progress = Progress.create(content_id: content.id, user_id: current_user.id, course_id: course.id,status: "TRANSMITTED")
        #data = Rails.env.production? ? open(content.name.url) : File.open(content.name.path,'r')
        return render status: 200, :json=> {:success => true, data: {url: song_url, title: content.title, artist: content.artist, creator: content.creator } }
        #send_data data.read, :disposition => 'inline'
      else
        return render status: 200, :json=> {:success => false, messages: [t('content_not_found')] }
      end
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
    puts params[:usage_status]
    usage_status_json.each do |usage_status|
      content = Content.active.where(id: usage_status[0]).first
      if is_blank_course_content(course, content)
        return render status: 200, :json=> {:success => false, messages: course.blank? ? [t('course_not_found')] : [t('content_not_found')] }
      end
      usage_status[1].each do |usage|
        stats = PlayerUsageStat.where(user_id: user_id, device_detail_id: device_details.id, course_id: course.id, content_id: content.id, usage_date: usage.flatten[0].to_date ).first
        if stats
          stats.update_attributes(duration: stats.duration.to_i + usage.flatten[1].to_i)
        else
          values << [user_id, device_details.id, course.id, content.id, usage.flatten[0], usage.flatten[1]]
       end
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
    query_filter = 'date'
    case params[:filter]
       when "7_Days" then
         filter_date =  1.week.ago.to_date + 1.day
      when "1_Month" then
         filter_date = 30.days.ago.to_date + 1.day
       when '1_Year' then
         filter_date =  1.year.ago.to_date.beginning_of_month.next_month
         query_filter = 'month'
      else
        filter_date =  1.day.ago.to_date + 1.day
     end
    data = []
    data = (filter_date..Date.today()).map{ |m| m.strftime('%Y%m') }.uniq.map{ |m| {month: Date::ABBR_MONTHNAMES[ Date.strptime(m, '%Y%m').mon ], duration: 0}} if params[:filter] == '1_Year'
    Date.today().downto(filter_date){|date|  data << ({date: date, duration: 0})} unless params[:filter] == '1_Year'
    usage_stats = user.player_usage_stats.select(" usage_date as usage_date, sum(duration) as duration").where("DATE(usage_date) >= ?", filter_date).group("#{query_filter}(usage_date)").order(usage_date: :desc)
    usage_stats.each do |usage_status|
      if usage_status.usage_date
        date_hash = data.find { |h| h[:month] == usage_status.usage_date.to_date.strftime("%b") } if params[:filter] == '1_Year'
        date_hash = data.find { |h| h[:date] == usage_status.usage_date.to_date} unless params[:filter] == '1_Year'
        date_hash[:duration] = usage_status.duration unless date_hash.blank?
      end
    end
    return render status: 200, :json=> {:success => true, data: data }
   end

  def edit_profile
    user = user_from_auth_token
    child = user.children.first
    data = {f_name: user.f_name, l_name: user.l_name, baby_name: child.name, dob: child.dob, zipcode: user.zipcode, gender: child.gender}
    return render status: 200, :json=> {:success => true, data: data }
  end


  def update_profile
    @user = user_from_auth_token
    @user.update_attributes(update_params)
    params[:dob] = dob_format(params[:dob]) if params[:dob]
    child = @user.children.first
    if child.nil?
      child = @user.children.create(dob: params[:dob], name: params[:baby_name], gender: params[:baby_gender])
    else
      child = @user.children.first.update_attributes(dob: params[:dob], name: params[:baby_name],gender: params[:baby_gender])
    end

    unless child
      return render :status => 200, :json => {:success => false, :errors => "Child data not updated"}
    else
      return render status: 201, :json=> {:success => true, data: {data: "Profile updated" } }
    end
  end

  def has_stripe_account_active?
    if params[:criteria] == 'beta_playlist_2'
      return false
    elsif params[:course_id]
      beta_category = CourseCategory.where(name: 'beta_playlist_2').first
      unless beta_category.nil? && beta_category.course.nil?
        if params[:course_id].to_i == beta_category.course.id
          return false
        end
      end
    end
    return render status: 200, :json=> {:success => false, data: [t('no_stripe_account')] } unless current_user.stripe_account?
    return render status: 200, :json=> {:success => false, data: [t('no_active_stripe_subscription')] } unless current_user.active_subscription?
  end

  def send_subscription_mail
    current_user.update_attributes(subscription_token: subscription_token)
    UserMailer.payment_form_mail(current_user, 'Subscription', 'Begin Using the Nuryl App Today! Here is Your Special Offer.').deliver
    return render status: 200, :json=> {:success => true}
  end

  def get_urls
    if params[:type].nil? || params[:name].nil?
      return render status: 200, :json=> {:success => false, data: [t('no_params_type_name')]}
    end
    data = ENV[(params[:type] + '_' + params[:name]).downcase]
    return render status: 200, :json=> {:success => false, data:[t('url_not_found')] } if data.nil?
    return render status: 200, :json=> {:success => true, data: data }
  end


  private
  def subscription_token
    loop do
      token = User.friendly_token
      break token unless User.where(subscription_token: token).first
    end
  end




end