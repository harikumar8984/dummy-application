class Api::V1::UsersController < ApplicationController
  skip_before_filter :authenticate_user_from_token!, :only => :validate_unique_email
  skip_before_filter :authenticate_device, :only => :validate_unique_email
  respond_to :json

  def welcome_content
    #Under the assumption for welcome content the course id will be one
    content = Course.content_structure(Course.first.id)
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
    unless content.blank?
      progress = Progress.create(content_id: content.id, user_id: current_user.id, course_id: params[:course_id],status: "TRANSMITTED")
      return render status: 200, :json=> {:success => true, data: request.base_url.to_s + content.name.url }
    else
      return render status: 200, :json=> {:success => false, messages: [t('content_not_found')] }
    end
  end

end