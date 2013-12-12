require 'pavlov'

class Activity < OurOhm
  class ListenerCreator
    #
    # in the following code, 'you' is anyone in the write_ids
    #
    include Activity::Followers

    def reject_self followers, activity
      followers.reject {|id| id == activity.user_id}
    end

    def people_who_follow_sub_comment
      ->(a) { reject_self(followers_for_sub_comment(a.subject), a) }
    end

    def people_who_follow_a_fact_which_is_object
      ->(a) { reject_self(followers_for_fact(a.object),a) }
    end

    def forGraphUser_fact_relation_was_added
      {
        subject_class: "FactRelation",
        action: [:created_fact_relation],
        write_ids: people_who_follow_a_fact_which_is_object
      }
    end

    def forGraphUser_comment_was_added
      {
        subject_class: "Comment",
        action: :created_comment,
        write_ids: people_who_follow_a_fact_which_is_object
      }
    end

    def forGraphUser_someone_send_you_a_message
      {
        subject_class: "Conversation",
        action: [:created_conversation],
        write_ids: ->(a) { reject_self(followers_for_conversation(a.subject),a) }
      }
    end

    def forGraphUser_someone_send_you_a_reply
      {
        subject_class: "Message",
        action: [:replied_message],
        write_ids: ->(a) { reject_self(followers_for_conversation(a.subject.conversation),a) }
      }
    end

    def forGraphUser_someone_added_a_subcomment_to_your_comment_or_fact_relation
      {
        subject_class: "SubComment",
        action: :created_sub_comment,
        write_ids: people_who_follow_sub_comment
      }
    end

    def forGraphUser_someone_added_a_subcomment_to_a_fact_you_follow
      {
        subject_class: "SubComment",
        action: :created_sub_comment,
        write_ids: people_who_follow_a_fact_which_is_object
      }
    end

    def forGraphUser_someone_opinionated_a_fact_you_created
      {
        subject_class: "Fact",
        action: [:believes, :doubts, :disbelieves],
        extra_condition: ->(a) { a.subject.created_by_id != a.user.id },
        write_ids: ->(a) { [a.subject.created_by_id] }
      }
    end

    def forGraphUser_someone_added_a_fact_you_created_to_his_channel
      {
        subject_class: "Fact",
        action: :added_fact_to_channel,
        extra_condition: ->(a) do
          (a.subject.created_by_id != a.user_id)
        end,
        write_ids: ->(a) { [a.subject.created_by_id] }
      }
    end

    def forGraphUser_someone_followed_you
      {
        subject_class: 'GraphUser',
        action: 'followed_user',
        write_ids: ->(a) { [a.subject_id]}
      }
    end

    def create_activity_listeners
      Activity::Listener.reset
      # TODO clear activity listeners for develop
      create_notification_activities
      create_stream_activities
    end

    def create_notification_activities
      notification_activities = [
        forGraphUser_fact_relation_was_added,
        forGraphUser_someone_send_you_a_message,
        forGraphUser_someone_send_you_a_reply,
        forGraphUser_comment_was_added,
        forGraphUser_someone_added_a_subcomment_to_your_comment_or_fact_relation,
        forGraphUser_someone_followed_you
      ]

      notification_activities.map{ |a| a[:action] }.flatten.map(&:to_s).each do |action|
        unless Activity.valid_actions_in_notifications.include? action
          fail "Invalid activity action for notifications: #{action}"
        end
      end

      Activity::Listener.register do
        activity_for "GraphUser"
        named :notifications
        notification_activities.each { |a| activity a }
      end
    end

    def create_stream_activities
      Activity::Listener.register_listener Activity::Listener::Stream.new

      stream_activities = [
        forGraphUser_fact_relation_was_added,
        forGraphUser_comment_was_added,
        forGraphUser_someone_added_a_subcomment_to_a_fact_you_follow,
        forGraphUser_someone_opinionated_a_fact_you_created,
        forGraphUser_someone_added_a_fact_you_created_to_his_channel,
      ]

      stream_activities.map{ |a| a[:action] }.flatten.map(&:to_s).each do |action|
        unless Activity.valid_actions_in_stream_activities.include? action
          fail "Invalid activity action for notifications: #{action}"
        end
      end

      Activity::Listener.register do
        activity_for "GraphUser"
        named :stream_activities
        stream_activities.each { |a| activity a }
      end
    end

  end
end
