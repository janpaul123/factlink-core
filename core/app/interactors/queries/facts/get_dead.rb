module Queries
  module Facts
    class GetDead
      include Pavlov::Query

      arguments :id

      private

      def execute
        DeadFact.new fact.id,
                     site_url,
                     fact.data.displaystring,
                     fact.data.created_at,
                     fact.data.title,
                     votes,
                     fact.deletable?
      end

      def fact
        @fact ||= Fact[id]
      end

      def site_url
        return nil unless fact.has_site?

        fact.site.url
      end

      def votes
        query(:'believable/votes', believable: fact.believable)
      end

      def validate
        validate_integer_string :id, id
      end
    end
  end
end
