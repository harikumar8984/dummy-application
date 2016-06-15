class MailTemplate < ActiveRecord::Base

  def device_type_enum
    [['Android'],['iPhone']]
  end

  def context_enum
    [['Registration'], ['Subscription']]
  end

end
