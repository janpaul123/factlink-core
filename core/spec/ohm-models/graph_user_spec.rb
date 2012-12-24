require 'spec_helper'

describe GraphUser do
  def self.others(opinion)
    others = [:believes, :doubts, :disbelieves]
    others.delete(opinion)
    others
  end

  subject {FactoryGirl.create :graph_user }
  let(:fact) {FactoryGirl.create(:fact,:created_by => subject)}

  context "Initially" do
    context "the subjects channels" do
      it { subject.created_facts_channel.title.should == "Created" }
      it { subject.stream.title.should == "All" }
    end
  end

  describe "removing a channel" do
    it "should be removed from the graph_users channels" do
      u1 = create :graph_user
      ch1 = create :channel, created_by: u1
      u1.channels.should include(ch1)
      ch1.real_delete
      u1 = GraphUser[u1.id]
      u1.channels.should_not include(ch1)
    end
  end

  [:believes, :doubts, :disbelieves].each do |type|
    context "after adding #{type} to a fact" do
      before do
        fact.add_opinion(type,subject)
      end

      it { expect(subject.has_opinion?(type,fact)).to be_true}

      others(type).each do |other_type|
        it { expect(subject.has_opinion?(other_type,fact)).to be_false}
      end


      it do
        subject.channels.each do |ch|
          ch.should be_a Channel
        end
      end
    end
  end

end
