require 'pavlov_helper'
require_relative '../../../../app/interactors/queries/channels/get_by_slug_title'

describe Queries::Channels::GetBySlugTitle do
  include PavlovSupport

  describe '#call' do
    before do
      stub_classes('Channel')
    end

    it 'correctly' do
      channel = double slug_title:'foo'
      channel_set = double first: channel
      current_user = double :current_user, graph_user_id: 10
      query = described_class.new(slug_title: channel.slug_title,
        pavlov_options: { current_user: current_user })

      Channel.stub(:find)
             .with(slug_title: 'foo', created_by_id: 10)
             .and_return(channel_set)

      expect(query.call).to eq channel
    end
  end
end
