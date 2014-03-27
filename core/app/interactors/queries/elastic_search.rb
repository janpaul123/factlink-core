# TODO the tests should be refactored so they test this class directly
# It is now inderectly integration tested via the other specs

require_relative '../../classes/elastic_search'

module Queries
  class ElasticSearch
    include Pavlov::Query

    arguments :keywords, :page, :row_count, :types

    def execute
      records = ::ElasticSearch::Search.search keywords: keywords, page: page,
                                               row_count: row_count, types: types

      records.map do |record|
        get_object(record['_id'], record['_type'])
      end
    end

    private

    def get_object id, type
      case type
      when'factdata'
        fd = FactData.find(id)
        Backend::Facts.get(fact_id: fd.fact_id)
      when 'user'
        Backend::Users.by_ids(user_ids: [id]).first
      when 'test_class'
        TestClass.new(id)
      else
        fail 'Object type unknown.'
      end
    end
  end
end
