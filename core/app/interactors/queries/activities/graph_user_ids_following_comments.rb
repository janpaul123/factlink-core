require 'pavlov'
module Queries
  module Activities
    class GraphUserIdsFollowingComments
      include Pavlov::Query

      arguments :comments

      private

      def execute
        follower_ids.uniq
      end

      def follower_ids
        comments_creators_ids +
          comments_opinionated_ids +
          sub_comments_on_comments_creators_ids
      end

      def comments_creators_ids
        comments.map {|comment| comment.created_by.graph_user_id}
      end

      def comments_opinionated_ids
        comments.flat_map {|comment| comment.believable.opinionated_users_ids}
      end

      def sub_comments_on_comments_creators_ids
        sub_comments.map(&:created_by)
                    .map(&:graph_user_id)
      end

      def comment_ids
        comments.map(&:id).map(&:to_s)
      end

      def sub_comments
        query :'sub_comments/index', comment_ids, 'Comment'
      end

    end
  end
end
