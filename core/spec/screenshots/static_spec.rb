require 'acceptance_helper'

describe "Static pages:", type: :feature, driver: :poltergeist_slow do
  include ScreenshotTest
  include FeedHelper

  describe "Homepage" do
    it do
      create_default_activities_for create(:user)

      visit "/"
      assume_unchanged_screenshot "static_homepage"
    end
  end

  describe "Publisher landing page" do
    it "renders correct with feedback opened" do
      visit "/"

      first('a', text: 'On your site').click
      find('a', text: 'Other platforms').click

      find('a', text: 'Feedback').click
      within_frame 0 do
        # wait for frame to load:
        find(:button, 'Send feedback')
      end

      assume_unchanged_screenshot "static_on_your_site_with_feedback"
    end
  end

  describe "Blog page" do
    it do
      visit blog_4_lessons_you_can_learn_from_factlinks_pivot_path
      assume_unchanged_screenshot "static_blogpost"
    end
  end
end
