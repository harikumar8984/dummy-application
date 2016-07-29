namespace :VtigerCrmIntegration do

  desc "Import all existing users to CRM"
  task :import_users => :environment do |t,args|
    #if [1,7, 13, 19 ].include?(Time.now.in_time_zone('Eastern Time (US & Canada)').hour)
      login_vtiger
      user = User.where("created_at >=?" ,Time.now - 1.day)
      user.each do |user|
        hash = create_user_list_hash(user)
        @cmd.find_contact_by_email_or_add(nil, user.l_name, remove_special_char(user.email), hash )
      end
    #end
  end

  desc "Updating CRM with CMS latest data"
  task :update_cms_crm => :environment do |t,args|
  if [1,7, 13, 19 ].include?(Time.now.in_time_zone('Eastern Time (US & Canada)').hour)
    login_vtiger
    puts ('******#####Vtiger Updation Start######********')
    users = User.where("changed_date >=?" ,Time.now - 1.day)
    users.each do |user|
        puts user.email
        update_crm_object(user)
        puts (user.email+ 'updated to Vtiger')
    end
    puts ('**********#######All CMS data updated to crm#######*********')
  end
  end

   def remove_special_char words
     words.gsub(/[+ &"]/,'')
   end

    def user_created_yesterday
      user = User.where("created_at >= ?", Time.zone.now.beginning_of_day)
      user.each do |user|
        @cmd.find_contact_by_email_or_add(nil, user.l_name, remove_special_char(user.email), create_user_list_hash(user) )
      end
    end


  def  update_crm_object(user)
    object = @cmd.query_element_by_email(user.email, 'Contacts')
    if object[0]
      @cmd.updateobject({lastname: user.l_name, email: remove_special_char(user.email), id: object[1], assigned_user_id: '8'}.merge(create_user_list_hash(user)))
    end
  end

  def login_vtiger
    @cmd = Vtiger::Commands.new()
    @cmd.challenge({})
    @cmd.login({})
  end

  def create_user_list_hash(user)
    device_details = {}
    device_details = create_device_hash(user.device_detail) unless user.device_detail.nil?
    children_details = {}
    children_details = create_children_hash(user.children.first) unless user.children.blank?
    payment_details = {}
    payment_details = create_payment_hash(user.stripe_customer) unless user.stripe_customer.nil?
    transaction_details = {}
    transaction_details = create_transaction_hash(user , user.transactions.last) if user.stripe_account? && user.active_subscription? && user.transactions.last
    player_usage_details = {}
    player_usage_details = create_player_usage_stats_hash(user.player_usage_stats, user.player_usage_stats_aggregate)
    create_user_hash(user).merge(device_details).merge(children_details).merge(payment_details).merge(transaction_details).merge(player_usage_details)
  end

  def create_user_hash(user)
     {firstname: user.f_name, cf_809: user.id, cf_917: user.user_type, cf_813: user.subscription_end_date,
      cf_915: user.stripe_account? ? user.active_subscription? : false, cf_817: user.zipcode, cf_821: user.authentication_token,
      cf_835: user.current_sign_in_at ? user.current_sign_in_at.to_date : '',
      cf_839: user.last_sign_in_at ? user.last_sign_in_at.to_date : '', cf_837: user.current_sign_in_ip, cf_841: user.last_sign_in_ip,
      cf_833: user.sign_in_count}
  end

  def create_device_hash(device_detail)
      {cf_823: device_detail.device_id, cf_829: device_detail.created_at ? device_detail.created_at.to_date : '' ,
       cf_831: device_detail.updated_at ? device_detail.updated_at.to_date : '',
       cf_827: device_detail.status, cf_825: device_detail.device_type}
  end

  def create_children_hash(children)

    {cf_853: remove_special_char(children.name), cf_851: children.dob, cf_855: children.created_at ? children.created_at.to_date : '',
     cf_857: children.updated_at ? children.updated_at.to_date : ''}
  end

  def create_payment_hash(payment)
    {cf_861: payment.customer_id, cf_865: payment.source_url, cf_867: payment.created_at ? payment.created_at.to_date : '',
     cf_869: payment.updated_at ? payment.updated_at.to_date : '', cf_911: payment.payment_type}
  end

  def create_transaction_hash(user, transaction)
     if transaction.payment_type == 'stripe'
      amount =  transaction.amount > 0 ? (transaction.amount.to_f/ 100).to_f : 0.00
     else
       amount = transaction.amount
     end

    {cf_871: transaction.transaction_id, cf_873: transaction.purchase_date ? transaction.purchase_date.to_date : '',
     cf_905: transaction.status , cf_881: amount, cf_885: transaction.paid, cf_887: transaction.failure_code,
     cf_929: user.active_subscription.interval}
  end

  def create_player_usage_stats_hash(player_usage_stats, player_usage_stats_aggregate)
    month_usage_stats = usage_stats(player_usage_stats , Date.today.at_beginning_of_month)
    daily_usage_stats_1 = usage_stats(player_usage_stats ,  Date.today)
    daily_usage_stats_2 = usage_stats(player_usage_stats ,  Date.today - 1.day)
    daily_usage_stats_3 = usage_stats(player_usage_stats ,  Date.today - 2.day)
    year_usage_stats = usage_yearly_stats(player_usage_stats , player_usage_stats_aggregate,  Date.today.at_beginning_of_year)
    total_usage_stats = usage_yearly_stats(player_usage_stats ,  player_usage_stats_aggregate, nil)
    {cf_923: daily_usage_stats_1.first.duration.nil? ? '00:00:00' : Time.at(daily_usage_stats_1.first.duration).utc.strftime("%H:%M:%S"),
     cf_925: daily_usage_stats_2.first.duration.nil? ? '00:00:00' : Time.at(daily_usage_stats_2.first.duration).utc.strftime("%H:%M:%S"),
     cf_927: daily_usage_stats_3.first.duration.nil? ? '00:00:00' : Time.at(daily_usage_stats_3.first.duration).utc.strftime("%H:%M:%S"),
     cf_897: month_usage_stats.first.duration.nil? ? '00:00:00' : Time.at(month_usage_stats.first.duration).utc.strftime("%H:%M:%S"),
     cf_899: year_usage_stats == 0 ? '00:00:00'  : Time.at(year_usage_stats).utc.strftime("%H:%M:%S"),
     cf_913: total_usage_stats == 0 ? '00:00:00' : Time.at(total_usage_stats).utc.strftime("%H:%M:%S")
    }
  end

  def usage_yearly_stats(player_usage_stats, aggregate, filter_date)
     current_duration = usage_stats_query(player_usage_stats, filter_date)
     aggregate_duration = usage_stats_query(aggregate, filter_date)
     (current_duration.first.duration.nil? ? 0 : current_duration.first.duration) + (aggregate_duration.first.duration.nil? ? 0 : aggregate_duration.first.duration)
  end

  def usage_stats(player_usage_stats, filter_date)
    usage_stats_query(player_usage_stats, filter_date)
  end

  def usage_stats_query(model, filter_date)
    if filter_date.nil?
      model.select("sum(duration) as duration").order(usage_date: :desc)
    else
      model.select("sum(duration) as duration").where("DATE(usage_date) >= ?", filter_date).order(usage_date: :desc)
    end
  end

end