require 'pavlov'

class CreateSearchIndexForTopics

  @queue = :mmm_search_index_operations

  def self.perform(topic_id)
    topic = Topic.find(topic_id)

    if topic
      Pavlov.command :'text_search/index_topic', topic: topic
    else
      fail "Failed adding index for topic with topic_id: #{topic_id}"
    end
  end
end
