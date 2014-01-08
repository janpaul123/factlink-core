class window.SubComment extends Backbone.Model
  creator: -> new User(@get('created_by'))

  can_destroy: -> FactlinkApp.isCurrentUser @creator()

  validate: (attributes) ->
    'Content should not be empty' unless /\S/.test(attributes.content)

  toJSON: ->
    json = super

    _.extend {formatted_comment_content: json.content}, json
