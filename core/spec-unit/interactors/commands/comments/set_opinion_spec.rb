require 'pavlov_helper'
require_relative '../../../../app/interactors/commands/comments/set_opinion.rb'

describe Commands::Comments::SetOpinion do
  include PavlovSupport

  before do
    stub_classes 'Believable::Comment'
  end

  describe '.execute' do
    it "sets the opinion on the believable belonging to this comment" do
      opinion = mock

      believable = mock
      graph_user = mock

      command = Commands::Comments::SetOpinion.new mock, opinion, mock
      command.stub believable: believable,
                   graph_user: graph_user


      believable.should_receive(:add_opiniated)
                .with(opinion, graph_user)
      command.execute
    end
  end

  describe '.believable' do
    it "returns the Believable::Comment for this comment" do
      id = mock
      believable = mock
      command = Commands::Comments::SetOpinion.new id, mock, mock

      Believable::Comment.should_receive(:new)
                       .with(id)
                       .and_return(believable)

      expect(command.believable).to eq believable
    end
  end

  describe '.graph_user' do
    it "returns the graph_user passed in" do
      graph_user = mock
      command = Commands::Comments::SetOpinion.new mock, mock, graph_user
      expect(command.graph_user).to eq graph_user
    end
  end
end
