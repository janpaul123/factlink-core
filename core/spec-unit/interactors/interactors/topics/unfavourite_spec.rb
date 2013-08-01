require 'pavlov_helper'
require_relative '../../../../app/interactors/interactors/topics/unfavourite'

describe Interactors::Topics::Unfavourite do
  include PavlovSupport

  describe '#authorized?' do
    before do
      described_class.any_instance.stub(validate: true)
    end

    it 'throws when no current_user' do
      expect { described_class.new(mock, mock) }
        .to raise_error Pavlov::AccessDenied,'Unauthorized'
    end

    it 'throws when cannot edit favourites' do
      user = stub
      current_user = stub
      ability = stub
      ability.stub(:can?).with(:edit_favourites, user).and_return(false)
      pavlov_options = { current_user: current_user, ability: ability }

      Pavlov.stub(:old_query).
        with(:user_by_username, 'username', pavlov_options).
        and_return(user)

      expect { described_class.new 'username', 'slug_title', pavlov_options }.
        to raise_error Pavlov::AccessDenied, 'Unauthorized'
    end
  end

  describe '#call' do
    it 'calls a command to unfavourite topic' do
      user = mock(graph_user_id: mock)
      user_name = 'username'
      slug_title = 'slug-title'

      current_user = stub

      ability = stub
      ability.stub(:can?).with(:edit_favourites, user).and_return(true)

      pavlov_options = { current_user: current_user, ability: ability }

      topic = mock(id: mock)

      Pavlov.stub(:old_query)
        .with(:'user_by_username', user_name, pavlov_options)
        .and_return(user)
      Pavlov.stub(:old_query)
        .with(:'topics/by_slug_title', slug_title, pavlov_options)
        .and_return(topic)
      Pavlov.should_receive(:old_command)
        .with(:'topics/unfavourite', user.graph_user_id, topic.id.to_s, pavlov_options)

      interactor = described_class.new user_name, slug_title, pavlov_options

      interactor.should_receive(:mp_track)
        .with('Topic: Unfavourited', slug_title: slug_title)

      expect(interactor.call).to eq nil
    end
  end

  describe 'validations' do
    it 'without user_id doesn\t validate' do
      expect_validating(1, 'headline')
        .to fail_validation('user_name should be a nonempty string.')
    end

    it 'without user_id doesn\t validate' do
      expect_validating('karel', 43)
        .to fail_validation('slug_title should be a nonempty string.')
    end
  end
end
