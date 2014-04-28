require 'pavlov'

class Activity < ActiveRecord::Base
  class ListenerCreator
    #
    # in the following code, 'you' is anyone in the write_ids
    #

    def reject_self followers, activity
      followers.reject {|id| id.to_s == activity.user_id.to_s }
    end

    def people_who_follow_user_of_activity
      ->(a) { reject_self(Backend::UserFollowers.follower_ids(followee_id: a.user_id), a) }
    end

    def forUser_comment_was_added_to_a_fact_you_follow
      {
        subject_type: "Comment",
        action: :created_comment,
        write_ids: ->(a) { reject_self(Backend::Followers.followers_for_fact_id(a.subject.fact_data.fact_id),a) }
      }
    end

    def forUser_follower_created_comment
      {
        subject_type: "Comment",
        action: :created_comment,
        write_ids: people_who_follow_user_of_activity
      }
    end

    def forUser_someone_added_a_subcomment_to_a_fact_you_follow
      {
        subject_type: "SubComment",
        action: :created_sub_comment,
        write_ids: ->(a) { reject_self(Backend::Followers.followers_for_fact_id(a.subject.parent.fact_data.fact_id),a) }
      }
    end

    def forUser_follower_created_sub_comment
      {
        subject_type: "SubComment",
        action: :created_sub_comment,
        write_ids: people_who_follow_user_of_activity
      }
    end

    def followed_someone_else
      # If you follow someone, you get activities when they follow someone,
      # except when they follow you
      {
        subject_type: 'User',
        action: 'followed_user',
        write_ids: ->(a) { (Backend::UserFollowers.follower_ids(followee_id: a.user_id) - [a.subject_id.to_i]) }
      }
    end

    def create_activity_listeners
      Activity::Listener.reset
      # TODO clear activity listeners for develop
      create_stream_activities
      create_global_all_activities
      create_global_discussions
    end

    def create_stream_activities
      # NOTE: Please update the tags above and in _activity.json.jbuilder when changing this!!
      stream_activities = [
        followed_someone_else,
        forUser_comment_was_added_to_a_fact_you_follow,
        forUser_someone_added_a_subcomment_to_a_fact_you_follow,
        forUser_follower_created_comment,
        forUser_follower_created_sub_comment,
      ]

      stream_activities.map{ |a| a[:action] }.flatten.map(&:to_s).each do |action|
        unless Activity.valid_actions.include? action
          fail "Invalid activity action for stream: #{action}"
        end
      end

      Activity::Listener.register do
        activity_for "User"
        named :stream_activities
        stream_activities.each { |a| activity a }
      end

      Activity::Listener.register do
        activity_for "User"
        named :own_activities
        stream_activities.each do |a|
          activity a.merge({
            write_ids: ->(a) {[a.user_id]}
          })
        end
      end

    end

    def create_global_all_activities
      write_ids = ->(a) { [0] } # irrelevant, fake id; GlobalFeed is a singleton.

      Activity::Listener.register do
        activity_for "GlobalFeed"
        named :all_activities
        activity subject_type: "Comment",
                 action: :created_comment,
                 write_ids: write_ids
        activity subject_type: "SubComment",
                 action: :created_sub_comment,
                 write_ids: write_ids
      end

    end

    def create_global_discussions
      write_ids = ->(a) { [0] } # irrelevant, fake id; GlobalFeed is a singleton.

      Activity::Listener.register do
        activity_for "GlobalFeed"
        named :all_discussions
        activity subject_type: "FactData",
                 action: :created_fact,
                 write_ids: write_ids
      end

    end
  end
end
