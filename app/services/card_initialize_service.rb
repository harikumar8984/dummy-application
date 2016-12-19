class CardInitializeService
  def self.intialize_card(user, params)
      credit_card = ActiveMerchant::Billing::CreditCard.new(
      :first_name         => user.f_name,
      :last_name          => user.l_name,
      :number             => params[:card_number],
      :month              => 10,
      :year               => 2017,
      :verification_value => 5174
      )
    credit_card
  end

end
