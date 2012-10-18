require 'spec_helper'

describe ConversationsController do
  render_views


  describe :show do
    let(:user) { User.create }
    let(:conv) do
      c = create(:conversation_with_messages, message_count: 4, user_count: 3)
      c.recipients << user
      c.save
      c
    end

    describe "json" do
      it "should contain conversation fields" do
        authenticate_user!(user)

        get :show, id: conv.id.to_s, format: 'json'
        expect(response).to be_success
        json = JSON.parse(response.body)

        expect(json["id"]).to eq(conv.id.to_s)
        expect(json["fact_data_id"]).to eq(conv.fact_data.id.to_s)
      end

      it "should contain messages" do
        authenticate_user!(user)

        get :show, id: conv.id.to_s, format: 'json'
        expect(response).to be_success
        json = JSON.parse(response.body)
        expect(json["messages"][0]["id"]).to eq(conv.messages[0].id.to_s)
        expect(json["messages"][1]["sender_id"]).to eq(conv.messages[1].sender.id.to_s)
        expect(json["messages"][2]["content"]).to eq(conv.messages[2].content)
      end
    end

    describe "html" do
      it "should be successful" do
        get :show, id: 0
        expect(response).to be_success
      end
    end
  end
end
