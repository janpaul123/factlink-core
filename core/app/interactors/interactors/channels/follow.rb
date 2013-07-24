module Interactors
  module Channels
    class Follow
      include Pavlov::Interactor

      arguments :channel_id, :pavlov_options

      def validate
        validate_integer_string :channel_id, channel_id
      end

      def execute
        follower = old_command :'channels/follow', channel
        if follower
          old_command :'channels/added_subchannel_create_activities', follower, channel
          old_command :'topics/favourite', current_graph_user_id,
                                       channel.topic.id.to_s
        end
      end

      def current_graph_user_id
        pavlov_options[:current_user].graph_user_id
      end

      def channel
        @channel ||= old_query :'channels/get', channel_id
      end

      def authorized?
         # this is no stub, every user can follow another channel
        pavlov_options[:current_user]
      end
    end
  end
end
