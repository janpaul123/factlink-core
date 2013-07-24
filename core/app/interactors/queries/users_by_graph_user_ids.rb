require 'pavlov'
require_relative '../kill_object'
require_relative 'users_by_ids'

module Queries
  class UsersByGraphUserIds
    include Pavlov::Query

    arguments :graph_user_ids, :pavlov_options

    private

    def validate
      graph_user_ids.each do |id|
        raise "id should be a positive integer." unless id.to_i > 0
      end
    end

    def execute
      old_query :users_by_ids, user_ids
    end

    def user_ids
      graph_user_ids.map do |graph_user_id|
        GraphUser[graph_user_id].user_id
      end
    end
  end
end
