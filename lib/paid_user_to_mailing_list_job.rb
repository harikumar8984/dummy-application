class PaidUserToMailingListJob < ActiveJob::Base
  queue_as :default

  def perform(user, subscribe_list_id, paid_list_id)
    gb = Gibbon::Request.new(api_key:  ENV['MAILCHIMP_API_KEY'], debug: true)
    member_id = Digest::MD5.hexdigest(user.email.downcase)
    gb.lists(subscribe_list_id).members(member_id).update(body: { status: "unsubscribed" }) rescue nil
    gb.lists(paid_list_id).members(member_id).upsert(body: {email_address: user.email, status: 'subscribed', merge_fields: {FNAME: user.f_name, LNAME: user.l_name}})
  end
end
