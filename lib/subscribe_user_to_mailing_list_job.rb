class SubscribeUserToMailingListJob < ActiveJob::Base
  queue_as :default

  def perform(user, list_id)
    gb = Gibbon::Request.new(api_key:  ENV['MAILCHIMP_API_KEY'], debug: true)
    gb.lists(list_id).members.create(body: {email_address: user.email, status: 'subscribed', merge_fields: {FNAME: user.f_name, LNAME: user.l_name}})
  end
end

