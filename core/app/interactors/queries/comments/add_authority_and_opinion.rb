require_relative '../../pavlov'

module Queries
  module Comments
    class AddAuthorityAndOpinion
      include Pavlov::Query
      arguments :comment, :fact
      def execute
        KillObject.comment @comment,
          opinion_object: opinion_object,
          current_user_opinion: current_user_opinion,
          authority: authority
      end

      def authority
        query :authority_on_fact_for, @fact, @comment.created_by.graph_user
      end

      def opinion_object
        query :opinion_for_comment, @comment.id.to_s, @fact
      end

      def current_user_opinion
        query :'comments/graph_user_opinion',
              @comment.id.to_s, current_graph_user
      end

      def current_graph_user
        @options[:current_user].graph_user
      end
    end
  end
end
