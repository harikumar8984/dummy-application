namespace :VtigerCrmIntegration do

  desc "Import all existing users to CRM"
  task :import_users => :environment do |t,args|
    if [1,7, 13, 19 ].include?(Time.now.in_time_zone('Eastern Time (US & Canada)').hour)
      login_vtiger
      #user = User.all
      user = User.where("created_at >=?" ,Time.now - 2.day)
      user.each do |user|
        hash = create_user_list_hash(user)
        @cmd.find_contact_by_email_or_add(nil, user.l_name, remove_special_char(user.email), hash )
      end
    end
  end

  desc "Updating CRM with CMS latest data"
  task :update_cms_crm => :environment do |t,args|
  if [1,7, 13, 19 ].include?(Time.now.in_time_zone('Eastern Time (US & Canada)').hour)
    login_vtiger
    puts ('******#####Vtiger Updation Start######********')
    users = User.where("changed_date >=?" ,Time.now - 10.day)
    users.each do |user|
        puts user.email
        update_crm_object(user)
        puts (user.email+ 'updated to Vtiger')
    end
    puts ('**********#######All CMS data updated to crm#######*********')
  end
  end

   def remove_special_char words
     words.gsub(/[+ &"]/,'') unless words.nil?
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
    user_record = User.find_by_sql ("SELECT u.id, u.f_name, u.l_name, u.email, u.user_type, u.zipcode, u.current_sign_in_at, u.last_sign_in_at,
           u.current_sign_in_ip, u.last_sign_in_ip, u.sign_in_count, u.created_at, d.device_id, d.device_type, c.name as child_name, c.dob, c.gender,
           sp.name as payment_interval, sp.amount, s.status, s.subscription_start_date, s.subscription_end_date, s.subscription_type
           FROM users u left join device_details d on d.user_id = u.id left join user_children uc on uc.user_id = u.id left join children c on c.id = uc.child_id
           left join subscriptions s on s.user_id = u.id left join subscription_plans sp on sp.id = s.subscription_plan_id where u.id =#{user.id}")
      if  user_record
         device_details = create_device_hash(user_record[0])
         children_details = {}
         children_details = create_children_hash(user_record[0])
         payment_details = {}
         payment_details = create_payment_hash(user_record[0])
         player_usage_details = {}
         player_usage_details = create_player_usage_stats_hash(user.id)

       create_user_hash(user_record[0]).merge(device_details).merge(children_details).merge(payment_details).merge(player_usage_details)
    end
  end

  def create_user_hash(user)
     {firstname: user.f_name, cf_809: user.id, cf_917: user.user_type, cf_817: user.zipcode}
  end

  def create_device_hash(device_detail)
      {cf_823: device_detail.device_id,
       cf_825: device_detail.device_type,
       cf_829: device_detail.created_at ? device_detail.created_at.to_date : '',
       cf_943: device_detail.current_sign_in_at ? device_detail.current_sign_in_at.to_date : '',
       cf_839: device_detail.last_sign_in_at ? device_detail.last_sign_in_at.to_date : '',
       cf_951: device_detail.current_sign_in_ip,
       cf_841: device_detail.last_sign_in_ip,
       cf_833: device_detail.sign_in_count}
  end

  def create_children_hash(children)
    {cf_853: remove_special_char(children.child_name), cf_851: children.dob,
     cf_893: children.gender }
  end

  def create_payment_hash(payment)
    {cf_933: payment.subscription_start_date ? payment.subscription_start_date.to_date : '',
     cf_935: payment.subscription_end_date ? payment.subscription_end_date.to_date : '' ,
     cf_937: payment.subscription_type, cf_939: payment.payment_interval,
     cf_941: payment.status,  cf_949: payment.amount }
  end


  def create_player_usage_stats_hash(user_id)
    month_usage_stats = usage_stats_query("PlayerUsageStat", user_id , Date.today.at_beginning_of_month)
    daily_usage_stats_1 =  daily_usage_stats("PlayerUsageStat", user_id,  Date.today)
    daily_usage_stats_2 = daily_usage_stats("PlayerUsageStat", user_id,  Date.today - 1.day)
    daily_usage_stats_3 = daily_usage_stats("PlayerUsageStat", user_id, Date.today - 2.day)
    year_usage_stats = usage_yearly_stats(user_id , Date.today.at_beginning_of_year)
    total_usage_stats = usage_yearly_stats(user_id , nil)
    {cf_923: daily_usage_stats_1.first.duration.nil? ? '00:00:00' : Time.at(daily_usage_stats_1.first.duration).utc.strftime("%H:%M:%S"),
     cf_925: daily_usage_stats_2.first.duration.nil? ? '00:00:00' : Time.at(daily_usage_stats_2.first.duration).utc.strftime("%H:%M:%S"),
     cf_927: daily_usage_stats_3.first.duration.nil? ? '00:00:00' : Time.at(daily_usage_stats_3.first.duration).utc.strftime("%H:%M:%S"),
     cf_897: month_usage_stats.first.duration.nil? ? '00:00:00' : Time.at(month_usage_stats.first.duration).utc.strftime("%H:%M:%S"),
     cf_899: year_usage_stats == 0 ? '00:00:00'  : Time.at(year_usage_stats).utc.strftime("%H:%M:%S"),
     cf_913: total_usage_stats == 0 ? '00:00:00' : Time.at(total_usage_stats).utc.strftime("%H:%M:%S")
    }
  end

  def usage_yearly_stats(user_id, filter_date)
     current_duration = usage_stats_query("PlayerUsageStat", user_id, filter_date)
     aggregate_duration = usage_stats_query("PlayerUsageStatsAggregate", user_id, filter_date)
     (current_duration.first.duration.nil? ? 0 : current_duration.first.duration) + (aggregate_duration.first.duration.nil? ? 0 : aggregate_duration.first.duration)
  end

  def usage_stats_query(model, user_id, filter_date)
    if filter_date.nil?
      model.constantize.find_by_sql("Select sum(duration) as duration, max(usage_date) from #{model.tableize} \
       where user_id = #{user_id}")
    else
      model.constantize.find_by_sql("Select sum(duration) as duration, max(usage_date) from #{model.tableize } \
       where (user_id =#{user_id} and date(usage_date) >= '#{filter_date.strftime('%Y-%m-%d')}')")
    end
  end

  def daily_usage_stats(model, user_id, filter_date)
    model.constantize.find_by_sql("Select sum(duration) as duration, max(usage_date) from #{model.tableize } \
       where user_id = #{user_id} and date(usage_date) = '#{filter_date.strftime('%Y-%m-%d')}'")
  end

end