class window.User extends Backbone.Model
  initialize: ->
    @channels = []
    @followers = new Followers([], user: @)
    @following = new Following([], user: @)
    @favourite_topics = new FavouriteTopics([], user: @)

    @following.on 'all', => @trigger 'follow_action'

  setChannels: (channels) -> @channels = channels

  url: ->
    # We do this because we cannot (yet) set the idAttribute to "username"
    if @collection?
      @collection.url() + '/' + @get('username')
    else
      '/' + @get('username')

  is_current_user: ->
    currentUser?.get('username') == @get('username')

  avatar_url: (size)->
    md5d_email = @get('gravatar_hash')
    "https://secure.gravatar.com/avatar/#{md5d_email}?size=#{size}&rating=PG&default=retro"

  stream:        -> @channel_with_id 'all_channel_id'
  created_facts: -> @channel_with_id 'created_facts_channel_id'

  channel_with_id: (id) ->
    new Channel
      id: @get(id)
      created_by:
        username: @get('username')

  link: -> '/' + @get('username')

  toJSON: ->
    username = @get('username')
    _.extend super(),
      is_current_user: @is_current_user(),
      edit_path: "/#{username}/edit",
      change_password_path: "/#{username}/password/edit"
      notifications_settings_path: "/#{username}/notification-settings"
      link: "/#{username}"
      avatar_url_20: @avatar_url(20)
      avatar_url_24: @avatar_url(24)
      avatar_url_32: @avatar_url(32)
      avatar_url_42: @avatar_url(42)
      avatar_url_48: @avatar_url(48)
      avatar_url_80: @avatar_url(80)
      avatar_url_160: @avatar_url(160)
      stream_path: "/#{username}/channels/#{@get('all_channel_id')}/activities"
      profile_path: @link()
      user_topics: @user_topics().toJSON()

  is_following_users: ->
    !@following.isEmpty()

  follow: ->
    currentUser.following.create @,
      error: =>
        currentUser.following.remove @
        @followers.remove currentUser

    @followers.add currentUser.clone()
    @trigger 'followed'

  unfollow: ->
    self = currentUser.following.get(@id)
    return unless self

    self.destroy
      error: =>
        currentUser.following.add @
        @followers.add currentUser.clone()

    @followers.remove currentUser

  followed_by_me: ->
    currentUser.following.some (model) =>
      model.get('username') == @get('username')

  user_topics: ->
    new UserTopics @get('user_topics')
