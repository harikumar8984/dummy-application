RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan


  config.authorize_with do
    if current_user
        redirect_to main_app.root_path unless current_user.admin?
    end
  end

  config.current_user_method(&:current_user)

  config.excluded_models = ["UserChild"]

  ## == Pundit ==
  # config.authorize_with :pundit

  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new do
      only ['Course', 'CourseContent', 'Content']
    end
    export
    bulk_delete
    show
    edit do
      only ['Course', 'CourseContent', 'Content']
    end
    delete  do
      only ['Course', 'CourseContent', 'Content']
    end
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  RailsAdmin::ApplicationController.class_eval do
    skip_before_action :is_device_id?
    skip_before_filter :authenticate_user_from_token!
    skip_before_filter :authenticate_device
  end

end

