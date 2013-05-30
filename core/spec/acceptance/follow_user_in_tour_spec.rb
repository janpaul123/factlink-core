require 'acceptance_helper'

feature "follow_users_in_tour", type: :request do
  include PavlovSupport

  before do
    @user = create :approved_confirmed_user

    @user1 = create :user
    @user2 = create :user
    Pavlov.command :"users/add_handpicked_user", @user1.id.to_s
    Pavlov.command :"users/add_handpicked_user", @user2.id.to_s

    as(@user1) do |pavlov|
      @user1_channel1 = pavlov.command :'channels/create', 'toy'
      @user1_channel2 = pavlov.command :'channels/create', 'story'
      Authority.from(@user1_channel2.topic, for: @user1.graph_user) << 3
    end
    as(@user2) do |pavlov|
      @user2_channel1 = pavlov.command :'channels/create', 'war'
      @user2_channel2 = pavlov.command :'channels/create', 'games'
      Authority.from(@user2_channel2.topic, for: @user2.graph_user) << 4568
    end
  end

  scenario "The user should be able to follow/unfollow users from the tour" do
    sign_in_user @user

    visit interests_path

    page.should have_content('What is this?')

    click_on 'Got it!'

    page.should_not have_content('What is this?')

    page.should have_content("#{@user1.first_name} #{@user1.last_name}")
    page.should have_content("#{@user2.first_name} #{@user2.last_name}")

    page.should have_content(@user1_channel1.title)
    page.should have_content(@user1_channel2.title)
    page.should have_content(@user2_channel1.title)
    page.should have_content(@user2_channel2.title)
  end
end
