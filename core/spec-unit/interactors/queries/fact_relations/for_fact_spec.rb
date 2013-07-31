require 'pavlov_helper'
require_relative '../../../../app/interactors/queries/fact_relations/for_fact.rb'

describe Queries::FactRelations::ForFact do
  include PavlovSupport

  before do
    stub_classes 'KillObject'
  end

  describe '#call' do
    it 'returns a dead object' do
      fact_relation = mock(id: '1', class: 'FactRelation')
      graph_user = mock
      opinion_on = mock
      user = mock(graph_user: graph_user)
      impact_opinion = mock
      dead_fact_relation = mock
      sub_comments_count = 2
      fact = mock
      type = :supporting
      fact.stub(:evidence).with(type).and_return([fact_relation])
      pavlov_options = { current_user: user }

      query = described_class.new fact: fact, type: :supporting,
        pavlov_options: pavlov_options

      Pavlov.stub(:old_query)
            .with(:'sub_comments/count',fact_relation.id, fact_relation.class, pavlov_options)
            .and_return(sub_comments_count)
      Pavlov.stub(:old_query)
            .with(:'opinions/impact_opinion_for_fact_relation', fact_relation, pavlov_options)
            .and_return(impact_opinion)

      fact_relation.should_receive(:sub_comments_count=).with(sub_comments_count)
      graph_user.stub(:opinion_on).with(fact_relation).and_return(opinion_on)
      KillObject.stub(:fact_relation)
                .with(fact_relation,
                      current_user_opinion: opinion_on,
                      impact_opinion:impact_opinion,
                      evidence_class: 'FactRelation')
                .and_return(dead_fact_relation)

      result = query.call

      expect(result).to eq [dead_fact_relation]
    end

    it 'works without a current user' do
      fact_relation = mock(id: '1', class: 'FactRelation')
      impact_opinion = mock
      type = :supporting
      fact = mock
      fact.stub(:evidence).with(type).and_return([fact_relation])
      dead_fact_relation = mock
      sub_comments_count = 2

      query = described_class.new fact: fact, type: type

      Pavlov.stub(:old_query)
            .with(:'sub_comments/count',fact_relation.id, fact_relation.class)
            .and_return(sub_comments_count)
      Pavlov.stub(:old_query)
            .with(:'opinions/impact_opinion_for_fact_relation', fact_relation)
            .and_return(impact_opinion)

      fact_relation.should_receive(:sub_comments_count=).with(sub_comments_count)
      KillObject.stub(:fact_relation)
                .with(fact_relation,
                      current_user_opinion:nil,
                      impact_opinion:impact_opinion,
                      evidence_class: 'FactRelation')
                .and_return(dead_fact_relation)

      result = query.call

      expect(result).to eq [dead_fact_relation]
    end
  end
end
