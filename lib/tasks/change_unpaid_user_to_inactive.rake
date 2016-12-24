namespace :ChangeUnpaidUserToInactive do
  desc "Change Unpaid User status"
  task :change_status => :environment do |t,args|
    inactive_subscription = Subscription.where("subscription_end_date <=? and status =?", Time.now - 2.day, 'Active')
    inactive_subscription.each do |subscription|
      subscription.update_attributes(status: 'Canceled')
    end
  end
end