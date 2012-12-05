require 'pavlov_helper'

require_relative '../../../../app/interactors/interactors/channels/add_fact_to_channel'

describe Interactors::Channels::AddFactToChannel do
  describe '.execute' do
    it 'correctly' do
      fact = mock
      channel = mock
      user = mock

      Interactors::Channels::AddFactToChannel.any_instance.should_receive(:authorized?).and_return true

      interactor = Interactors::Channels::AddFactToChannel.new fact, channel

      channel.should_receive(:created_by).and_return(user)

      interactor.should_receive(:command).with(:"channels/add_fact_to_channel", fact, channel)
      interactor.should_receive(:command).with(:"create_activity", user, :added_fact_to_channel, fact, channel)

      interactor.execute
    end
  end

  describe '.authorized?' do
    it 'returns the passed current_user' do
      current_user = mock
      interactor = Interactors::Channels::AddFactToChannel.new mock, mock, current_user: current_user

      expect(interactor.authorized?).to eq current_user
    end

    it 'returns true when the :no_current_user option is true' do
      interactor = Interactors::Channels::AddFactToChannel.new mock, mock, no_current_user: true

      expect(interactor.authorized?).to eq true
    end

    it 'returns false when neither :current_user or :no_current_user are passed' do
      expect(lambda { Interactors::Channels::AddFactToChannel.new mock, mock }).to raise_error(Pavlov::AccessDenied)
    end
  end
end
