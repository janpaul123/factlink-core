unless user.respond_to?(:statistics) && user.respond_to?(:top_user_topics) then
  user = Queries::UsersByIds.new(user_ids: [user.id]).call.first
end

json.id                            user.id.to_s
json.name                          user.name
json.username                      user.username
json.gravatar_hash                 user.gravatar_hash
json.statistics_created_fact_count user.statistics[:created_fact_count]
json.statistics_follower_count     user.statistics[:follower_count]
json.statistics_following_count    user.statistics[:following_count]

json.deleted true if user.deleted

json.user_topics user.top_user_topics do |user_topic|
  json.title      user_topic.title
  json.slug_title user_topic.slug_title
  json.authority  user_topic.formatted_authority
end
