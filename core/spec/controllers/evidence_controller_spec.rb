require 'spec_helper'
require 'pavlov_helper'

describe CommentsController do
  render_views

  # described here since about to be merged
  describe :index do
    include Pavlov::Helpers
    let(:current_user){create :user}
    def pavlov_options
      {current_user: current_user}
    end
    it "should keep doing the same" do
      Timecop.freeze Time.local(1995, 4, 30, 15, 35, 45)
      FactoryGirl.reload # hack because of fixture in check

      fact = create :fact
      interactor :'comments/create', fact.id.to_i, 'believes', 'Gerard'
      interactor :'comments/create', fact.id.to_i, 'believes', 'Henk'

      authenticate_user!(current_user)

      get 'index', type:'believes', id: fact.id, format: 'json'

      response_body = response.body.to_s
      # strip mongo id, since otherwise comparison will always fail
      response_body.gsub!(/"id":\s*"[^"]*"/, '"id": "<STRIPPED>"')
      Approvals.verify(response_body, format: :json, name: 'comments#index should keep the same content')
    end
  end
end

describe SupportingEvidenceController do
  include PavlovSupport
  render_views

  let(:user) {create(:user)}

  let(:f1) {create(:fact)}
  let(:f2) {create(:fact)}

  before do
    # TODO: remove this once activities are not created in the models any more, but in interactors
    stub_const 'Activity::Subject', Class.new
    Activity::Subject.should_receive(:activity).any_number_of_times
  end

  describe :index do
    before do
      FactoryGirl.reload # hack because of fixture in check
      @fr = f1.add_evidence(:supporting, f2, user)
    end

    it "should show" do
      should_check_can :get_evidence, f1

      get 'index', :fact_id => f1.id, :format => 'json'
      response.should be_success
    end

    it "should keep doing the same" do

      should_check_can :get_evidence, f1
      get 'index', fact_id: f1.id, format: 'json'
      response_body = response.body.to_s
      # strip mongo id, since otherwise comparison will always fail
      response_body.gsub!(/"id":\s*"[^"]*"/, '"id": "<STRIPPED>"')
      Approvals.verify(response_body, format: :json, name: 'evidence_controller_response')
    end

    it "should show the correct evidence" do
      should_check_can :get_evidence, f1

      get 'index', :fact_id => f1.id, :format => 'json'
      parsed_content = JSON.parse(response.body)
      parsed_content[0]["fact_base"]["id"].should == f2.id
    end
  end

  describe :combined_index do
    let(:current_user){create :user}

    it 'response with success' do
      fact_id = 1
      authenticate_user!(current_user)
      controller.should_receive(:interactor).
        with(:"evidence/index", fact_id.to_s, :supporting).
        and_return []

      get :combined_index, fact_id: fact_id, format: :json

      response.should be_success
    end
  end

  describe :create do
    before do
      authenticate_user!(user)
      should_check_can :add_evidence, f1
    end

    context "adding new evidence to a fact" do

      it "should return the new evidence" do
        displaystring = "Nieuwe features van Mark"

        post 'create', fact_id: f1.id, displaystring: displaystring, format: :json
        response.should be_success

        parsed_content = JSON.parse(response.body)
        parsed_content["fact_base"]["displaystring"].should == displaystring

        FactRelation[parsed_content["id"].to_i].fact.id.should == f1.id
      end

    end

    context "adding a new fact as evidence to a fact" do
      it "should return the existing fact as new evidence" do
        post 'create', fact_id: f1.id, evidence_id: f2.id, format: :json

        parsed_content = JSON.parse(response.body)
        parsed_content["fact_base"]["fact_id"].should == f2.id

        response.should be_success
      end

      it "should set the user's opinion on the added new fact"

      it "should not set the user's opinion on the evidence to believe" do
        f2.add_opinion(:disbelieves, user.graph_user)
        f2.calculate_opinion 2

        post 'create', fact_id: f1.id, evidence_id: f2.id, format: :json
        response.should be_success

        parsed_content = JSON.parse(response.body)

        opinions = parsed_content["fact_base"]["fact_wheel"]["opinion_types"]

        opinions["believe"]["percentage"].should == 0
        opinions["doubt"]["percentage"].should == 0
        opinions["disbelieve"]["percentage"].should == 100
      end
    end
  end

  describe :set_opinion do
    it "should be able to set an opinion" do
      pending "moving the routes - currently does not match routes in Rspec"
      authenticate_user!(user)

      should_check_can :opinionate, @fr
      post :set_opinion, username: 'ohwellwhatever', id: 1, fact_id: f1.id, evidence_id: @fr.id, type: :believes, format: :json

      response.should be_success

      parsed_content = JSON.parse(response.body)
      parsed_content.first.should have_key("fact_base")
    end
  end

  describe '.sub_comments_index' do
    it 'calls the interactor with the correct parameters' do
      fact_relation_id = 123
      sub_comments = mock
      controller.stub(params: {id: fact_relation_id.to_s})

      controller.should_receive(:interactor).with(:'sub_comments/index_for_fact_relation', fact_relation_id).
        and_return(sub_comments)
      controller.should_receive(:render).with('sub_comments/index')

      controller.sub_comments_index

      controller.instance_variable_get(:@sub_comments).should eq sub_comments
    end
  end

  describe '.sub_comments_create' do
    it 'calls the interactor with the correct parameters' do
      fact_relation_id = 123
      content = 'hoi'
      sub_comment = mock
      controller.stub(params: {content: content, id: fact_relation_id.to_s})

      controller.should_receive(:interactor).with(:'sub_comments/create_for_fact_relation', fact_relation_id, content).
        and_return(sub_comment)
      controller.should_receive(:render).with('sub_comments/show')

      controller.sub_comments_create

      controller.instance_variable_get(:@sub_comment).should eq sub_comment
    end
  end

end
