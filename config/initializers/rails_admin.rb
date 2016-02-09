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
      only ['User','Course', 'CourseContent', 'Content']
    end
    delete  do
      only ['User', 'Course', 'CourseContent', 'Content']
    end
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.model User do
    update do
      field :f_name
      field :l_name
    end
  end

  config.model Content do
    configure :duration do
      read_only true
    end
    list do
      field :id
      field :name do
        formatted_value do # used in form views
          value.to_s.upcase
        end

        pretty_value do # used in list view columns and show views, defaults to formatted_value for non-association fields
          value.titleize
        end

        export_value do
          value.camelize # used in exports, where no html/data is allowed
        end
      end
      field :status
    end
    include_all_fields
    exclude_fields :created_at, :updated_at, :course_contents, :courses, :progress, :player_usage_stats
  end

  config.model 'Course' do
    object_label_method do
      :custom_label_method
    end
    exclude_fields :created_at, :updated_at, :course_contents, :progress
  end

  RailsAdmin::ApplicationController.class_eval do
    before_filter :authenticate_user!
    skip_before_action :is_device_id?
    skip_before_filter :authenticate_user_from_token!
    skip_before_filter :authenticate_device
  end


  def custom_label_method
    "Course #{self.course_name}"
  end

end

