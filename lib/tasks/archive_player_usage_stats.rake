namespace :ArchivePlayerUsageStats do
  desc "Archive Player Usage Stats"
  task :do_archive => :environment do |t,args|
      PlayerUsageStat.where('duration =? OR usage_date =?', nil, nil).delete_all
      player_stats = PlayerUsageStat.where('usage_date <= ?',2.months.ago.end_of_month)
      columns = [:user_id, :device_detail_id, :course_id, :content_id, :usage_date, :duration ]
      player_stats.find_in_batches do |batch_stats|
        values = []
        batch_stats.each do |stat|
          stats_aggregate = PlayerUsageStatsAggregate.find_or_create_by(user_id: stat.user_id, usage_date: stat.usage_date.beginning_of_month.to_date)
          puts "**** updating stats agregate****"
          stats_aggregate.update_attributes(duration: (stats_aggregate.duration.nil? ? 0 : stats_aggregate.duration) + stat.duration )
          values << [stat.user_id, stat.device_detail_id, stat.course_id, stat.content_id, stat.usage_date, stat.duration]
          #puts values
        end
        puts "********Before Archive Import***********"
        PlayerUsageStatsArchive.import columns, values
        puts "*********After Archive Import**********"
        puts "********Before PlayerUsageStat Destoy"
        PlayerUsageStat.where(id: batch_stats.map(&:id)).destroy_all
        puts "After PlayerUsageStat Destory"
      end
  end

  desc "Clear stats agregate"
  task :do_clear_stats_agregate => :environment do |t,args|
    date_array = ['2016-09-01']
    date_array.each do |date|
      aggregate = PlayerUsageStatsAggregate.where(usage_date: date)
      user_ids = aggregate.uniq.pluck(:user_id)
      user_ids.each do |ids|
        all_record = PlayerUsageStatsAggregate.where(user_id: ids, usage_date: date)
        duration = all_record.sum(:duration)
        all_record.where('id != ?', all_record.first.id).destroy_all
        all_record = PlayerUsageStatsAggregate.where(user_id: ids, usage_date: date)
        all_record.first.update_attributes(duration: duration)
      end
    end
  end

end
