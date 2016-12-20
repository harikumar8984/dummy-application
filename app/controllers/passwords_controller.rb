class PasswordsController < Devise::PasswordsController

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?
    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      if Devise.sign_in_after_reset_password
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message(:notice, flash_message) if is_flashing_format?
      else
        set_flash_message!(:notice, :updated_not_active) if is_flashing_format?
      end
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      set_minimum_password_length
      respond_with resource
    end
  end


  protected
  def after_resetting_password_path_for(resource)
    new_session_path(resource_name)
  end
end