namespace :VtigerCrmIntegration do

  desc "Import all existing users to CRM"
  task :import_users => :environment do |t,args|
    login_vtiger
    user = User.all.each do |user|
      hash = create_user_list_hash(user)
      @cmd.find_contact_by_email_or_add(nil, user.l_name, user.email,hash )
    end
   end

    desc "Updating CRM with CMS latest data"
    task :update_cms_crm => :environment do |t,args|
      login_vtiger
      #first update all users created today
      user_created_today
      #user updated today
      today =  Time.zone.now.beginning_of_day
      user = User.all.each do |user|
        if ( (user.updated_at >= today  || user.created_at >= today) ||
            (user.children && user.children.first.updated_at >= today  || user.children.first.created_at >= today) ||
            (user.stripe_customer && (user.stripe_customer.first.updated_at >= today  || user.stripe_customer.first.created_at >= today)) ||
            (user.transactions.last && (user.transactions.last.updated_at >= today  || user.transactions.last.created_at >= today)) ||
            (user.player_usage_stats.last &&  (user.player_usage_stats.last.updated_at >= today  || user.player_usage_stats.last.created_at >= today)) )
          update_crm_object(user)
        end
      end
    end

    def user_created_today
      user = User.where("created_at >= ?", Time.zone.now.beginning_of_day)
      user.each do |user|
        @cmd.find_contact_by_email_or_add(nil, user.l_name, user.email, create_user_list_hash(user) )
      end
    end

    # def is_updated_today(model)
    #  result = model.where("updated_at >= ? || created_at >= ?", Time.zone.now.beginning_of_day , Time.zone.now.beginning_of_day) rescue []
    #  result.blank? ? false : true
    # end


  # def user_updated_today
  #     user = User.where("updated_at >= ? AND created_at < ?", Time.zone.now.beginning_of_day , Time.zone.now.beginning_of_day)
  #     user.each do |user|
  #       update_crm_object(user)
  #     end
  #   end
  #
  # def updated_today(obj_model)
  #   models =  obj_model.constantize.where("updated_at >= ? || created_at >= ?", Time.zone.now.beginning_of_day , Time.zone.now.beginning_of_day).group(:user_id) rescue []
  #   models.each do |model|
  #     unless model.user.nil?
  #       user = model.user
  #       update_crm_object(user)
  #    end
  #    end
  #
  # end

  def  update_crm_object(user)
    object = @cmd.query_element_by_email(user.email, 'Contacts')
    if object[0]
      @cmd.updateobject({lastname: user.l_name, email: user.email, id: object[1], assigned_user_id: '8'}.merge(create_user_list_hash(user)))
    end
  end

  def login_vtiger
    @cmd = Vtiger::Commands.new()
    @cmd.challenge({})
    @cmd.login({})
  end

  def create_user_list_hash(user)
    device_details = {}
    device_details = create_device_hash(user, user.device_detail) unless user.device_detail.nil?
    children_details = {}
    children_details = create_children_hash(user.children.first) unless user.children.blank?
    payment_details = {}
    payment_details = create_payment_hash(user.stripe_customer) unless user.stripe_customer.nil?
    transaction_details = {}
    transaction_details = create_transaction_hash(user , user.transactions.last) if user.stripe_account? && user.active_subscription? && user.transactions.last
    player_usage_details = {}
    player_usage_details = create_player_usage_stats_hash(user, user.player_usage_stats)
    create_user_hash(user).merge(device_details).merge(children_details).merge(payment_details).merge(transaction_details).merge(player_usage_details)
  end



  def create_user_hash(user)
     {firstname: user.f_name, cf_809: user.id, cf_811: user.user_type, cf_813: user.subscription_end_date,
      cf_815: user.stripe_account? ? user.active_subscription? : false, cf_817: user.zipcode, cf_821: user.authentication_token}
  end

  def create_device_hash(user, device_detail)
      {cf_823: device_detail.device_id, cf_829: device_detail.created_at ? device_detail.created_at.to_date : '' ,
       cf_831: device_detail.updated_at ? device_detail.updated_at.to_date : '',
       cf_827: device_detail.status, cf_833: user.sign_in_count, cf_835: user.current_sign_in_at ? user.current_sign_in_at.to_date : '',
       cf_839: user.last_sign_in_at ? user.last_sign_in_at.to_date : '', cf_837: user.current_sign_in_ip, cf_841: user.last_sign_in_ip}
  end

  def create_children_hash(children)
    {cf_853: children.name, cf_851: children.dob, cf_855: children.created_at ? children.created_at.to_date : '',
     cf_857: children.updated_at ? children.updated_at.to_date : ''}
  end

  def create_payment_hash(payment)
    {cf_861: payment.customer_id, cf_865: payment.source_url, cf_867: payment.created_at ? payment.created_at.to_date : '',
     cf_869: payment.updated_at ? payment.updated_at.to_date : '', cf_911: payment.payment_type}
  end

  def create_transaction_hash(user, transaction)
    {cf_871: transaction.transaction_id, cf_873: transaction.purchase_date ? transaction.purchase_date.to_date : '',
     cf_905: transaction.status , cf_881: transaction.amount, cf_885: transaction.paid, cf_887: transaction.failure_code}
  end

  def create_player_usage_stats_hash(user, player_usage_stats)
    month_usage_stats = usage_stats(player_usage_stats , 30.days.ago.to_date + 1.day)
    year_usage_stats = usage_stats(player_usage_stats ,  1.year.ago.to_date + 1.day)
    daily_usage_stats = usage_stats(player_usage_stats ,  1.day.ago.to_date + 1.day)
    total_usage_stats = usage_stats(player_usage_stats ,  nil)
    {cf_895: daily_usage_stats.first.duration.to_f > 0 ? (daily_usage_stats.first.duration.to_f/60).round(2)  : '0.00',
     cf_897: month_usage_stats.first.duration.to_f > 0 ? (month_usage_stats.first.duration.to_f/60).round(2) : '0.00',
     cf_899: year_usage_stats.first.duration.to_f > 0 ? (year_usage_stats.first.duration.to_f/60).round(2) : '0.00',
     cf_907: total_usage_stats.first.duration.to_f > 0 ? (total_usage_stats.first.duration.to_f/60).round(2) : '0.00'
    }
  end

  def usage_stats(player_usage_stats, filter_date)
    if filter_date
      player_usage_stats.select("sum(duration) as duration").where("DATE(usage_date) >= ?", filter_date).order(usage_date: :desc)
    else
      player_usage_stats.select("sum(duration) as duration").order(usage_date: :desc)
    end
  end

end