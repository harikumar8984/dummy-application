# This is extended concern common metods of user & registrations controller
module TransactionCommonMethodControllerConcern
  extend ActiveSupport::Concern

  def payment_service
    (params[:payment_gateway_type].to_s.downcase.titleize + "_payment_service").camelize.constantize rescue nil
  end

end