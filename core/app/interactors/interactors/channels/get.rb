require_relative './all_by_id.rb'
module Interactors
  module Channels
    class Get
      include Pavlov::Interactor

      arguments :id, :pavlov_options

      def execute
        channels = old_interactor :'channels/all_by_id', @id
        channels[0]
      end

      def authorized?
        pavlov_options[:current_user]
      end
    end
  end
end
