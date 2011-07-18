require 'redis'
require 'redis/objects'
Redis::Objects.redis = Redis.new

class Fact < Basefact
  include Redis::Objects

  set :supporting_facts
  set :weakening_facts
  
  def fact_relation_ids
    supporting_facts | weakening_facts
  end
  
  def fact_relations
    FactRelation.where(:_id.in => fact_relation_ids)
  end
  
  def sorted_fact_relations
    res = self.fact_relations.sort { |a, b| a.percentage <=> b.percentage }
    res.reverse
  end
  
  def evidence(type)
    case type
    when :supporting
      supporting_facts
    when :weakening
      weakening_facts
    end
  end
  
  def add_evidence(type, evidence, user)
    fact_relation = FactRelation.get_or_create(evidence, type, self, user)
    evidence(type) << fact_relation.id.to_s
    fact_relation
  end
  
  # Count helpers
  def supporting_evidence_count
    evidence(:supporting).length
  end

  def weakening_evidence_count
    evidence(:weakening).length
  end

  def evidence_count
    fact_relation_ids.count
  end
  
  # Used for sorting
  def self.column_names
    self.fields.collect { |field| field[0] }
  end

  def evidence_opinion
    opinions = []
    [:supporting, :weakening].each do |type|
      factlinks = FactRelation.where(:_id.in => evidence(type).members)
      factlinks.each do |factlink|
        opinions << factlink.get_influencing_opinion
      end
    end
    Opinion.combine(opinions)
  end

  def get_opinion
    user_opinion = super
    user_opinion + evidence_opinion
  end

end