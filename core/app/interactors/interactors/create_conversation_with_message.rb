require 'pavlov'
require_relative '../util/mixpanel'

module Interactors
  class CreateConversationWithMessage
    include Pavlov::Interactor
    include Util::Mixpanel

    arguments :fact_id, :recipient_usernames, :sender_id, :content

    def execute
      conversation = old_command :create_conversation, @fact_id, @recipient_usernames

      begin
        old_command :create_message, @sender_id, @content, conversation
      rescue
        conversation.delete # TODO replace this with a rollback of the create command
        raise
      end

      sender = User.find(@sender_id)
      old_command :create_activity, sender.graph_user, :created_conversation, conversation, nil

      track_mixpanel

      conversation
    end

    def track_mixpanel
      mp_track :conversation_created
      mp_increment_person_property :conversations_created
    end

    def authorized?
      #relay authorization to commands, only require a user to check
      pavlov_options[:current_user].id.to_s == @sender_id.to_s
    end
  end
end
