require 'integration_helper'

feature "sub_comments", type: :request do
  include Acceptance::FactHelper
  include Pavlov::Helpers

  background do
    @user_a = sign_in_user create :approved_confirmed_user
    @user_b = create :approved_confirmed_user

    @factlink_user_a = create :fact, created_by: @user_a.graph_user
  end

  def add_sub_comment(comment)
    fill_in 'text_area_view', with: comment
    find('.evidence-sub-comments-button', text: 'Comment').click
    find('.evidence-sub-comment-content', text: comment)
  end

  def switch_to_user(user)
    sign_out_user
    sign_in_user @user_b
  end

  scenario "A user can comment on a comment" do
    @comment_user_b = command :create_comment, @factlink_user_a.id.to_i, "believes", "test", @user_b.id.to_s

    sub_comment_text = "Sub Comment 1"

    go_to_discussion_page_of @factlink_user_a

    find('.js-sub-comments-link', text: 'Comments').click

    add_sub_comment(sub_comment_text)

    switch_to_user(@user_b)

    go_to_discussion_page_of @factlink_user_a

    find('.js-sub-comments-link', text: 'Comments').click
    find('.evidence-sub-comment-content', text: sub_comment_text)
  end

  scenario "A user can comment on a fact relation" do
    @fact_relation_user_b = create :fact, created_by: @user_b.graph_user
    @factlink_user_a.add_evidence("supporting", @fact_relation_user_b, @user_b)

    sub_comment_text = "Sub Comment 1"

    go_to_discussion_page_of @factlink_user_a

    find('.js-sub-comments-link', text: 'Comments').click

    add_sub_comment(sub_comment_text)

    switch_to_user(@user_b)
    go_to_discussion_page_of @factlink_user_a

    find('.js-sub-comments-link', text: 'Comments').click
    find('.evidence-sub-comment-content', text: sub_comment_text)
  end
end
