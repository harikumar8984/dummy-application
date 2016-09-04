class UsersController < ApplicationController

  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  skip_before_filter :is_device_id?
  skip_before_filter :authenticate_scope!
  skip_before_filter :authenticate_user_from_token!
  skip_before_filter :authenticate_device
  before_filter :authenticate_user!

	def show
		@user = current_user
	end

	def edit
		@user = current_user
	end

	def update
		@user = current_user
		if current_user.update_with_password(user_params)
			sign_in(current_user, :bypass => true)
			redirect_to user_path
		else
			render :edit
		end
	end
	
	private

	def user_params
    params.require(:user).permit!
  end

end