require 'pavlov_helper'
require_relative '../../../../app/interactors/queries/comments/for_fact.rb'

describe Queries::Comments::ForFact do
  include PavlovSupport

  before do
    stub_classes 'Comment', 'KillObject', 'Fact', 'OpinionType'
    stub_const 'Backend::SubComments', Module.new
  end

  describe '#call' do
    it 'correctly' do
      comment = double(id: '2a', class: 'Comment')
      fact = double(data_id: '10')
      dead_comment = double
      sub_comments_count = 2
      pavlov_options = { current_user: double }
      query = described_class.new fact_data_id: fact.data_id, pavlov_options: pavlov_options

      Comment.should_receive(:where)
             .with(fact_data_id: fact.data_id)
             .and_return [comment]
      Pavlov.should_receive(:query)
            .with(:'comments/add_votes_and_deletable',
                      comment: comment, pavlov_options: pavlov_options)
            .and_return(dead_comment)

      expect(query.call).to eq [dead_comment]
    end
  end
end
