class window.FactRelation extends Evidence

  defaults:
    evidence_type: 'FactRelation'
    sub_comments_count: 0

  setOpinion: (type) ->
    @previous_user_opinion = @get('current_user_opinion')
    @set 'current_user_opinion', type

    Backbone.ajax
      url: @url() + "/opinion/" + type
      success: (data) =>
        mp_track "Evidence: Opinionate",
          opinion: type
          evidence_id: @id

        @set data
      error: =>
        @set 'current_user_opinion', @previous_user_opinion

      type: "post"

  removeOpinion: ->
    Backbone.ajax
      url: "#{@url()}/opinion"
      type: "delete"
      success: (data) =>
        @set data

  undoOpinion: ->
    if @previous_user_opinion?
      @setOpinion @previous_user_opinion
    else
      @removeOpinion()

  getFact: ->
    return @_fact if @_fact?

    @_fact = new Fact(@get('from_fact'))
    @on 'change:from_fact', =>
      @_fact.set @get('from_fact')
    @_fact

  believe: -> @setOpinion "believes"
  disbelieve: -> @setOpinion "disbelieves"

  isBelieving: -> @get('current_user_opinion') == 'believes'
  isDisBelieving: -> @get('current_user_opinion') == 'disbelieves'

  current_opinion: -> @get('current_user_opinion')

  creator: -> new User(@get('created_by'))

  can_destroy: -> @get 'can_destroy?'

  urlRoot: -> @collection.factRelationsUrl()

  validate: (attributes) ->
    unless attributes.evidence_id? or /^.*\S.*$/.test(attributes.displaystring)
      'Should have either an evidence_id or a displaystring'
