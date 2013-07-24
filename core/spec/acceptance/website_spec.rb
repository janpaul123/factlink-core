require 'acceptance_helper'

describe "Logged-out visitors", type: :request do
  before do
    visit "/"
  end

  context "when not logged in" do
    it "should be able to view the About page" do
      pending if ENV['IS_FEATURE_BUILD']

      click_link "About"

      within(:css, "h1") do
        page.should have_content("About Factlink")
      end
    end

    it "should be able to view the Team page" do
      pending if ENV['IS_FEATURE_BUILD']

      click_link "Team"
      within(:css, "h1") do
        page.should have_content("The people behind Factlink")
      end
    end

    it "should be able to view the Jobs page" do
      pending if ENV['IS_FEATURE_BUILD']

      click_link "Jobs"
      within(:css, "h1") do
        page.should have_content("Jobs")
      end
    end

    it "should be able to view the Contact page" do
      pending if ENV['IS_FEATURE_BUILD']

      click_link "Contact"
      within(:css, "h1") do
        page.should have_content("Get in touch")
      end
    end

    it "should be able to view the TOS page" do
      pending if ENV['IS_FEATURE_BUILD']

      click_link "Terms of Service"
      within(:css, "h1") do
        page.should have_content("Terms of Service")
      end
    end

    it "should be able to view the Privacy Policy page" do
      pending if ENV['IS_FEATURE_BUILD']

      click_link "Privacy"
      within(:css, "h1") do
        page.should have_content("Privacy Policy")
      end
    end
  end
end
