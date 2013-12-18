module Screenshots
  module DiscussionHelper

    include Acceptance::FactHelper
    include Acceptance::CommentHelper

    def create_discussion
      factlink = backend_create_fact_with_long_text
      comment_text = '1. Comment'

      sub_comment_text = "\n\nThis is a subcomment\n\nwith some  whitespace \n\n"
      sub_comment_text_normalized = "This is a subcomment with some whitespace"

      supporting_factlink = backend_create_fact_with_long_text
      go_to_discussion_page_of supporting_factlink
      click_agree

      go_to_discussion_page_of factlink
      click_agree

      add_comment :doubts, comment_text
      add_existing_factlink :believes, supporting_factlink

      vote_comment :down, comment_text

      within('.evidence-argument', text: comment_text, visible: false) do
        find('a', text: 'Comment').click
        add_sub_comment(sub_comment_text)
        assert_sub_comment_exists sub_comment_text_normalized
      end

      within('.evidence-argument', text: supporting_factlink.data.displaystring, visible: false) do
        find('.js-down').click
        eventually_succeeds do
          find('a', text: 'Comment').click
          find('.spec-sub-comments-form').should_not eq nil
        end
        add_sub_comment(sub_comment_text)
        assert_sub_comment_exists sub_comment_text_normalized
      end

      factlink
    end

  end
end
