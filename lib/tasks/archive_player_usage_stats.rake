namespace :ArchivePlayerUsageStats do
  desc "Archive Player Usage Stats"
  task :do_archive => :environment do |t,args|
    if Date.today == Date.today.beginning_of_month
      PlayerUsageStat.where('duration =? OR usage_date =? OR usage_date=?', nil, nil, '0000-00-00').delete_all
      player_stats = PlayerUsageStat.where('usage_date <= ?',2.months.ago.at_beginning_of_month)
      columns = [:user_id, :device_detail_id, :course_id, :content_id, :usage_date, :duration ]
      player_stats.find_in_batches do |batch_stats|
        values = []
        batch_stats.each do |stat|
          stats_aggregate = PlayerUsageStatsAggregate.find_or_initialize_by(user_id: stat.user_id, usage_date: stat.usage_date.beginning_of_month)
          if stats_aggregate.new_record?
            stats_aggregate.duration =  stat.duration
            stats_aggregate.save
          else
            stats_aggregate.update_attributes(duration: (stats_aggregate.duration.nil? ? 0 : stats_aggregate.duration) + stat.duration )
          end
          values << [stat.user_id, stat.device_detail_id, stat.course_id, stat.content_id, stat.usage_date, stat.duration]
        end
        PlayerUsageStatsArchive.import columns, values
      end
      player_stats.destroy_all
    end
  end
end
