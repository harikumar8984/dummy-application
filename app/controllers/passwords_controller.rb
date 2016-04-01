class PasswordsController < Devise::PasswordsController
  skip_before_filter :is_device_id?, :only => [:edit, :update]
  skip_before_filter :authenticate_device, :only => [:edit,:update]
  skip_before_filter :authenticate_user_from_token!, :only => [:edit,:update]

end