module Interactors
  module Comments
    class Create
      include Pavlov::Interactor

      arguments :fact_id, :type, :content

      def execute
        comment = command(:'create_comment',
                              fact_id: fact_id, type: type, content: content,
                              user_id: pavlov_options[:current_user].id.to_s)

        command(:'comments/set_opinion',
                    comment_id: comment.id.to_s, opinion: 'believes',
                    graph_user: pavlov_options[:current_user].graph_user)

        create_activity comment

        query(:'comments/add_opinion_and_can_destroy',
                  comment: comment)
      end

      def create_activity comment
        # TODO fix this ugly data access shit, need to think about where to kill objects, etc
        refetched_comment = Comment.find(comment.id)
        command(:'create_activity',
                    graph_user: pavlov_options[:current_user].graph_user,
                    action: :created_comment, subject: refetched_comment,
                    object: comment.fact_data.fact)
      end

      def authorized?
        pavlov_options[:current_user]
      end

      def validate
        validate_regex   :content, content, /\S/,
          "should not be empty."
        validate_integer :fact_id, fact_id
        validate_in_set  :type, type, ['believes', 'disbelieves', 'doubts']
      end
    end
  end
end
