require 'pavlov_helper'
require_relative '../../../app/interactors/commands/create_message.rb'

describe Commands::CreateMessage do
  include PavlovSupport

  before do
    stub_classes 'Message', 'User'
    stub_const 'Pavlov::ValidationError', Class.new(StandardError)
  end

  let(:long_message_string) { (0...5001).map{65.+(rand(26)).chr}.join }
  let(:content) {'bla'}

  describe '.validate' do
    it 'throws error on empty message' do
      user = double(id: 14)
      User.stub(find: user)
      conversation = double(repicient_ids: [14])

      expect_validating( sender_id: 14, content: '', conversation: conversation)
        .to fail_validation 'message_empty'
    end

    it 'throws error on message with just whitespace' do
      user = double(id: 14)
      User.stub(find: user)

      conversation = double(repicient_ids: [14])

      expect_validating(sender_id: 14, content: " \t\n", conversation: conversation)
        .to fail_validation 'message_empty'
    end

    it 'throws error on too long message' do
      command = described_class.new(sender_id: 'bla', content: long_message_string,
        conversation: '1')
      expect { command.call }.
        to raise_error(Pavlov::ValidationError, 'Message cannot be longer than 5000 characters.')
    end

    it 'it throws when initialized with a argument that is not a hexadecimal string' do
      user = double(id: 14)
      User.stub(find: user)
      conversation = double(id: 'g6', repicient_ids: [14])

      expect_validating(sender_id: 14, content: 'bla', conversation: conversation)
        .to fail_validation 'conversation_id should be an hexadecimal string.'
    end
  end

  describe '#call' do
    it 'creates and saves a message' do
      conversation = double(id: 1, recipient_ids: [14])

      sender = double(id: 14)

      pavlov_options = { current_user: sender }
      command = described_class.new sender_id: sender.id.to_s,
        content: content, conversation: conversation, pavlov_options: pavlov_options
      conversation.should_receive(:save)

      message = double
      message.should_receive("sender_id=").with(sender.id.to_s)
      message.should_receive('content=').with(content)
      message.should_receive('conversation_id=').with(conversation.id)

      Message.should_receive(:new).and_return(message)
      message.should_receive(:save)

      expect(command.call).to eq(message)
    end
  end

  describe '.authorized?' do
    it 'checks current_user' do
      conversation = double(id: 1, recipient_ids: [14])
      sender = double(id: 14)
      other_user = double(id: 15)

      pavlov_options = { current_user: other_user }
      command = described_class.new(sender_id: sender.id.to_s,
        content: content, conversation: conversation, pavlov_options: pavlov_options)
      expect { command.call }.
        to raise_error(Pavlov::AccessDenied)
    end

    it 'checks recipients' do
      conversation = double(id: 1, recipient_ids: [15])
      sender = double(id: 14)

      pavlov_options = { current_user: sender }
      command = described_class.new(sender_id: sender.id.to_s,
        content: content, conversation: conversation, pavlov_options: pavlov_options)

      expect { command.call }.
        to raise_error(Pavlov::AccessDenied)
    end

    it 'authorizes if there are no problems' do
      conversation = double(id: 1, recipient_ids: [14])
      sender = double(id: 14)

      pavlov_options = { current_user: sender }
      command = described_class.new(sender_id: sender.id.to_s,
        content: content, conversation: conversation, pavlov_options: pavlov_options )

      expect(command.authorized?).to eq(true)
    end
  end
end
