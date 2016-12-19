namespace :ChangeUnpaidUserToInactive do
  desc "Change Unpaid User status"
  task :change_status => :environment do |t,args|
    inactive_subscription = Subscription.where("subscription_end_date <=?", Time.now - 2.day)
    inactive_subscription.each do |subscription|
      subscription.update_attributes(status: 'Cancelled')
    end
  end
end