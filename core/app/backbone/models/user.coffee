class window.User extends Backbone.Model
  _.extend @prototype, Backbone.Factlink.ModelJustCreatedMixin

  initialize: ->
    @following = new Following([], user: @)

  usernameChanged: ->
    @get('original_username') != @get('username')

  url: ->
    # We do this because we cannot (yet) set the idAttribute to "username"
    if @collection?
      @collection.url() + '/' + (@get('original_username') || @get('username'))
    else
      '/api/beta/users/' + (@get('original_username') || @get('username'))

  avatar_url: (size) ->
    if(window.test_counter)
      'about:blank'
    else
      md5d_email = @get('gravatar_hash')
      "https://secure.gravatar.com/avatar/#{md5d_email}?size=#{size}&rating=PG&default=retro"

  link: -> "/#{@get('username')}"

  feed_activities: ->
    @_feed_activities ?= new UserActivities null, user: @

  is_following_users: ->
    !@following.isEmpty()

  follow: ->
    session.user().following.create @,
      error: =>
        session.user().following.remove @
        @set 'statistics_follower_count', @get('statistics_follower_count')-1

    @set 'statistics_follower_count', @get('statistics_follower_count')+1
    mp_track 'User: Followed'

  unfollow: ->
    self = session.user().following.get(@id)
    return unless self

    self.destroy
      error: =>
        session.user().following.add @
        @set 'statistics_follower_count', @get('statistics_follower_count')+1

    @set 'statistics_follower_count', @get('statistics_follower_count')-1
    mp_track 'User: Unfollowed'

  followed_by_me: ->
    session.user().following.some (model) =>
      model.get('username') == @get('username')

  password: -> @_password ?= new UserPassword {}, user: this

  delete: (options) ->
    # Sending data with DELETE request is not supported
    # Most browsers support it anyway, except PhantomJS
    default_options =
      type: 'POST'
      url: @url() + '/delete'
      data: {password: options.password}

    Backbone.ajax _.extend default_options, options
