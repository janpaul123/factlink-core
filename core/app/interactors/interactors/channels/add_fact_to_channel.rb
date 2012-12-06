module Interactors
  module Channels
    class AddFact
      include Pavlov::Interactor

      arguments :fact, :channel

      def execute
        command :"channels/add_fact", @fact, @channel

        # TODO 0612
        # command :'site/add_top_topics', @fact.site.id, @topic.id

        command :create_activity, @channel.created_by, :added_fact_to_channel, @fact, @channel
      end

      def authorized?
        @options[:no_current_user] == true or @options[:current_user]
      end
    end
  end
end
