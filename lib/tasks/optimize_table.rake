namespace :optimize_table do

	desc "Optimizing table player_usage_stats."

	task :optimize_player_usage_stats, [:player_usage_stats] => :environment do |t, args|

		users = PlayerUsageStat.select('user_id').uniq
		users.each do |m|

			@user_record = PlayerUsageStat.where(user_id: m.user_id)

			usage_dates = @user_record.select('usage_date').uniq
			course_ids = @user_record.select('course_id').uniq
			content_ids = @user_record.select('content_id').uniq

			usage_dates.each do |n|
				course_ids.each do |p|
					content_ids.each do |q|

						record = @user_record.where(usage_date: n.usage_date, course_id: p.course_id, content_id: q.content_id)
						unless record.count <= 1
							@duration = 0
							device_id = record.select('device_detail_id').first.device_detail_id
							record.each do |w|
								@duration += w.duration
							end

							PlayerUsageStat.where(user_id: m.user_id, course_id: p.course_id,
								content_id: q.content_id, usage_date: n.usage_date).destroy_all

							PlayerUsageStat.create(user_id: m.user_id, course_id: p.course_id, content_id: q.content_id,
								usage_date: n.usage_date, device_detail_id: device_id, duration: @duration)
						end
					end
				end
			end
		end
		PlayerUsageStat.where(usage_date: 0000-00-00, duration: nil).delete_all
	end
end