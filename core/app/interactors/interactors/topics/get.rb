module Interactors
  module Topics
    class Get
      include Pavlov::Interactor
      include Util::CanCan

      arguments :slug_title

      def execute
        KillObject.topic topic,
          current_user_authority: authority
      end

      def topic
        @topic ||= query :'topics/by_slug_title', slug_title: slug_title
      end

      def authority
        query :authority_on_topic_for, topic: topic, graph_user: graph_user
      end

      def graph_user
        pavlov_options[:current_user].graph_user
      end

      def validate
        validate_string :slug_title, slug_title
      end

      def authorized?
        return unless pavlov_options[:current_user]
        can? :show, topic
      end
    end
  end
end
