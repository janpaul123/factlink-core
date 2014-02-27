module Backend
  module Activities
    extend self

    def activities_below(activities_set:, timestamp:)
      retrieved_activities = activities_set.below(timestamp || 'inf',
                               count: 20,
                               reversed: true,
                               withscores: true).compact

      retrieved_activities.map do |activity_hash|
        begin
          activity = activity_hash[:item]

          h = {
            timestamp: activity_hash[:score],
            user: Pavlov.query(:dead_users_by_ids, user_ids: activity.user.user_id).first,
            action: activity.action,
            created_at: activity.created_at.to_time,
            time_ago: TimeFormatter.as_time_ago(activity.created_at.to_time),
            id: activity.id
          }
          case activity.action
          when "created_comment", "created_sub_comment"
            h[:fact] = Pavlov.query(:'facts/get_dead', id: activity.object.id.to_s)
          when "followed_user"
            subject_user = Pavlov.query(:dead_users_by_ids, user_ids: activity.subject.user_id).first
            h[:followed_user] = subject_user
          end

          h
        rescue
          nil
        end
      end.compact
    end
  end
end
