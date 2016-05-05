class  TransactionsController < ApplicationController
  skip_before_filter :is_device_id?, :only => [:new, :get_stripe_plan]
  skip_before_filter :authenticate_scope!, :only => [:new, :get_stripe_plan]
  skip_before_filter :authenticate_user_from_token!, :only => [:new, :get_stripe_plan]
  skip_before_filter :authenticate_device, :only => [:new, :get_stripe_plan]
  before_filter :authenticate_user!
  force_ssl if: :ssl_configured?
  respond_to :json

  def new
    @auth_token = current_user.authentication_token if current_user
    @user_type = params[:user_type]
    @subscription = Transaction.new
    get_stripe_plan
  end

  def get_stripe_plan
    all_plan = StripeExt.get_all_plan
    if all_plan
      @plan = []
      all_plan[:data].each do |plan|
        amount = plan.amount > 0 ? (plan.amount.to_f/100) : 0.00
        if params[:user_type] == 'beta' && plan.id != 'Yearly'
          @plan << [(plan.id == 'Beta' ? 'Yearly' : plan.id.to_s) + " ($"+ amount.to_s+")", plan.id]
        elsif plan.id != 'Beta' && params[:user_type] != 'beta'
          if params[:user_type] == 'gift'
            @plan << [plan.id.to_s + " ($"+ amount.to_s+")", plan.id] if plan.id == 'Yearly'
          else
            @plan << [plan.id.to_s + " ($"+ amount.to_s+")", plan.id]
          end
        end
      end
    end
  end

  def ssl_configured?
    !Rails.env.development?
  end

end

