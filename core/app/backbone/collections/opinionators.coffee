class window.Opinionators extends Backbone.Factlink.Collection
  model: Vote

  initialize: (models, options) ->
    @fact = options.fact

  url: ->
    "/facts/#{@fact.id}/opinionators"

  opinion_for_current_user:  ->
    return 'no_vote' unless FactlinkApp.signedIn()
    vote = @vote_for(window.currentUser.get('username'))
    if vote
      vote.get('type')
    else
      'no_vote'

  vote_for: (username) ->
    @find (vote) -> vote.get('username') == username

  clickCurrentUserOpinion: (type) ->
    return unless FactlinkApp.signedIn()

    @_createFactIfNecessary =>
      current_vote = @vote_for(currentUser.get('username'))
      if current_vote
        if current_vote.get('type') == type
          current_vote.destroy()
        else
          current_vote.set type: type
          current_vote.save()
      else
        @create
          username: currentUser.get('username')
          user: currentUser.attributes
          type: type

  _createFactIfNecessary: (callback) ->
    return callback() unless @fact.isNew()

    @fact.save {},
      success: callback

