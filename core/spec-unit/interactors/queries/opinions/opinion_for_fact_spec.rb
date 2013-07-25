require 'pavlov_helper'
require_relative '../../../../app/interactors/queries/opinions/opinion_for_fact.rb'

describe Queries::Opinions::OpinionForFact do
  include PavlovSupport

  describe '#call' do
    before do
      stub_classes 'Opinion::FactCalculation'
    end

    it 'returns the dead opinion on the fact' do
      dead_opinion = mock
      fact = mock
      fact_calculation = mock(get_opinion: dead_opinion)
      Opinion::FactCalculation.stub(:new).with(fact)
        .and_return(fact_calculation)


      query = described_class.new fact
      result = query.call

      expect(result).to eq dead_opinion
    end
  end
end