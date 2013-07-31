require 'pavlov_helper'
require_relative '../../../../app/interactors/queries/fact_relations/for_fact.rb'

describe Queries::FactRelations::ForFact do
  include PavlovSupport

  before do
    stub_classes 'KillObject'
  end

  describe '#call' do
    it 'calls add_sub_comments_count_and_opinions_and_evidence_class for each fact_relation' do
      fact_relation = double
      dead_fact_relation = double
      fact = double
      type = :supporting

      interactor = described_class.new fact, :supporting

      fact.stub(:evidence).with(type).and_return([fact_relation])
      Pavlov.stub(:query)
            .with(:'fact_relations/add_sub_comments_count_and_opinions_and_evidence_class', fact_relation)
            .and_return(dead_fact_relation)

      result = interactor.call

      expect(result).to eq [dead_fact_relation]
    end
  end
end
