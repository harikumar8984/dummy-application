class  Api::V1::TransactionsController < ApplicationController
  include UserCommonMethodControllerConcern
  include TransactionCommonMethodControllerConcern
  skip_before_filter :is_device_id?, :only => [:webhook]
  skip_before_filter :authenticate_scope!, :only => [:webhook]
  skip_before_filter :authenticate_user_from_token!, :only => [:webhook]
  skip_before_filter :authenticate_device, :only => [:webhook]
  respond_to :json

  def create
      return render status: 200, :json=> {:success => false, data: [t('active_subscription')] } if current_user.has_account? && current_user.active_subscription?
      return render status: 200, :json=> {:success => false, data: [t('no_payment_gateway')] } if params[:payment_gateway_type].blank?
      service_class = payment_service
      return render status: 200, :json=> {:success => false, data: [t('invalid_payment_gateway')] } if service_class.nil?
      return render status: 200, :json=> {:success => false, data: [t('invalid_plan')] } if plan_with_name.nil?
      unless  method_exist?(service_class,:create_payment_service )
        return render status: 200, :json=> {:success => false, data: [t('no_feature_for_this_service',
                                                                        service: service_class, method: 'create payment')] }
      end
      begin
        #redirecting corresponding payment gateway service
        service_class = payment_service
        service_class.new.create_payment_service(current_user, params)
      rescue service_class::PaymentError  => e
        return render status: 200, :json=> {:success => false, data: e.message }
      end
      return render status: 201, :json=> {:success => true, data: 'Account created' }

  end

  def get_subscription_amount
    plan = plan_with_name
    if plan.nil?
      return render status: 200, :json=> {:success => false, data: [t('invalid_plan')] }
    else
      return render status: 200, :json=> {:success => true, data: {amount: plan.amount} }
    end
  end

  def change_plan
      return render status: 200, :json=> {:success => false, data: [t('no_account')] } unless current_user.has_account?
      return render status: 200, :json=> {:success => false, data: [t('no_active_subscription')] } unless  current_user.active_subscription?
      return render status: 200, :json=> {:success => false, data: [t('no_payment_gateway')] } if params[:payment_gateway_type].blank?
      service_class = payment_service
      return render status: 200, :json=> {:success => false, data: [t('invalid_payment_gateway')] } if service_class.nil?
      return render status: 200, :json=> {:success => false, data: [t('invalid_plan')] } if plan_with_name.nil?
      unless  method_exist?(service_class,:change_plan_service )
        return render status: 200, :json=> {:success => false, data: [t('no_feature_for_this_service',
                                                                        service: service_class, method: 'change plan')] }
      end
      begin
        #redirecting corresponding payment gateway service
        service_class = payment_service
        service_class.new.change_plan_service(current_user, params)
      rescue service_class::PaymentError  => e
        return render status: 200, :json=> {:success => false, data: e.message }
      end
      return render status: 201, :json=> {:success => true, data: {data: "Plan updated to " + params[:subscription_type] } }
  end

  def new_subscription
    return render status: 200, :json=> {:success => false, data: [t('no_account')] } unless current_user.has_account?
    return render status: 200, :json=> {:success => false, data: [t('no_payment_gateway')] } if params[:payment_gateway_type].blank?
    service_class = payment_service
    return render status: 200, :json=> {:success => false, data: [t('invalid_payment_gateway')] } if service_class.nil?
    return render status: 200, :json=> {:success => false, data: [t('invalid_plan')] } if plan_with_name.nil?
    unless  method_exist?(service_class,:new_subscription_service )
      return render status: 200, :json=> {:success => false, data: [t('no_feature_for_this_service',
                                                                      service: service_class, method: 'new subscription')] }
    end
    begin
      #redirecting corresponding payment gateway service
      service_class = payment_service
      service_class.new.new_subscription_service(current_user, params)
    rescue service_class::PaymentError  => e
      return render status: 200, :json=> {:success => false, data: e.message }
    end
    return render status: 201, :json=> {:success => true, data: {data: "New subscription added" } }
  end

  def cancel_subscription
    return render status: 200, :json=> {:success => false, data: [t('no_account')] } unless current_user.has_account?
    return render status: 200, :json=> {:success => false, data: [t('no_active_subscription')] } unless  current_user.active_subscription?
    return render status: 200, :json=> {:success => false, data: [t('no_payment_gateway')] } if params[:payment_gateway_type].blank?
    service_class = payment_service
    return render status: 200, :json=> {:success => false, data: [t('invalid_payment_gateway')] } if service_class.nil?
    unless  method_exist?(service_class,:cancel_subscription_service )
      return render status: 200, :json=> {:success => false, data: [t('no_feature_for_this_service',
                                                                      service: service_class, method: 'cancel subscription')] }
    end
    begin
      #redirecting corresponding payment gateway service
      service_class = payment_service
      service_class.new.cancel_subscription_service(current_user, params)
    rescue service_class::PaymentError  => e
      return render status: 200, :json=> {:success => false, data: e.message }
    end
    return render status: 201, :json=> {:success => true, data: {data: "Subscription deactivated" } }

   end

  def update_card
    return render status: 200, :json=> {:success => false, data: [t('no_account')] } unless current_user.has_account?
    return render status: 200, :json=> {:success => false, data: [t('no_payment_gateway')] } if params[:payment_gateway_type].blank?
    service_class = payment_service
    return render status: 200, :json=> {:success => false, data: [t('invalid_payment_gateway')] } if service_class.nil?
    unless  method_exist?(service_class,:update_card_details_service )
      return render status: 200, :json=> {:success => false, data: [t('no_feature_for_this_service',
                                                                      service: service_class, method: 'update card')] }
    end
    begin
      #redirecting corresponding payment gateway service
      service_class = payment_service
      service_class.new.update_card_details_service(current_user, params)
    rescue service_class::PaymentError  => e
      return render status: 200, :json=> {:success => false, data: e.message }
    end
    return render status: 201, :json=> {:success => true, data: {data: "Card updated" } }
  end


  def webhook
    begin
      StripePaymentService.new.webhook_service(request.body.read)
      #redirecting corresponding payment gateway service
      #service_class = payment_service
      #service_class.new.webhook_service(request.body.read)
    rescue service_class::PaymentError  => e
      return render status: 200, :json=> {:success => false, data: e.message }
    end
    return render status: 200, :json=> {:success => true, data: 'Success' }
  end


  def plan_with_name
    SubscriptionPlan.subscription_with_name(params[:subscription_type]).first
  end

  def get_subscription_type
    return render status: 200, :json=> {:success => false, data: [t('no_payment_gateway')] } if params[:payment_gateway_type].blank?
    service_class = payment_service
    return render status: 200, :json=> {:success => false, data: [t('invalid_payment_gateway')] } if service_class.nil?
    unless  method_exist?(service_class,:subscription_type_service )
      return render status: 200, :json=> {:success => false, data: [t('no_feature_for_this_service',
                                            service: service_class, method: 'get subscription type')] }
    end
    begin
      subscrition_types = service_class.new.subscription_type_service
    rescue service_class::PaymentError  => e
      return render status: 200, :json=> {:success => false, data: e.message }
    end
    return render status: 200, :json=> {:success => true, data: subscrition_types }
  end


  def subscription_status
      status = current_user.has_account? ? current_user.active_subscription? ? 'active' : 'canceled' : 'no_account'
      return render status: 200, :json=> {:success => true, data: {subscription_status: status } }
  end

  def method_exist? service_class, method_name
    service_class.instance_methods(false).include?(method_name)
  end

end

