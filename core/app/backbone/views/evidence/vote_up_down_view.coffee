class window.EvidenceVoteView extends Backbone.Marionette.ItemView
  _.extend @prototype, Backbone.Factlink.PopoverMixin

  className: 'evidence-impact-vote'
  template: 'evidence/evidence_vote'

  events:
    "click .js-up":   "_on_up_vote"
    "click .js-down": "_on_down_vote"

  ui:
    upButton: '.js-up'
    downButton: '.js-down'

  initialize: ->
    @listenTo @model, "change", @_updateButtons

  onRender: ->
    @_updateButtons()
    @_setPopoverHoverIntent()

  _updateButtons: ->
    @ui.upButton.toggleClass 'active', @model.get('current_user_opinion') == 'believes'
    @ui.downButton.toggleClass 'active', @model.get('current_user_opinion') == 'disbelieves'

  _on_up_vote: ->
    mp_track "Factlink: Upvote evidence click"
    if @model.isBelieving()
      @model.removeOpinion()
      @_closePopups()
    else
      @_openVoteUpPopup()
      @model.believe()

  _on_down_vote: ->
    mp_track "Factlink: Downvote evidence click"
    if @model.isDisBelieving()
      @model.removeOpinion()
      @_closePopups()
    else
      @_openVoteDownPopup()
      @model.disbelieve()

  _open_vote_popup: (selector, view_klass) ->
    return if @popoverOpened selector

    @popoverResetAll()
    @popoverAdd selector,
      side: @_side()
      align: 'top'
      fadeTime: 200
      contentView: new view_klass model: @model

  _side: ->
    if @model.get('type') == 'believes'
      'left'
    else
      'right'

  _openVoteUpPopup: ->
    return unless @_canShowPopover()

    @_open_vote_popup '.js-up', FactRelationVoteUpView

  _openVoteDownPopup: ->
    return unless @_canShowPopover()

    @_open_vote_popup '.js-down', FactRelationVoteDownView

  _canShowPopover: ->
    @model instanceof FactRelation && Factlink.Global.can_haz['vote_up_down_popup']

  _closePopups: ->
    @popoverRemove '.js-up'
    @popoverRemove '.js-down'

  _setPopoverHoverIntent: ->
    return unless @_canShowPopover()

    @ui.upButton.hoverIntent
      timeout: 100
      over: => @_openVoteUpPopup() if @model.isBelieving()
      out: ->

    @ui.downButton.hoverIntent
      timeout: 100
      over: => @_openVoteDownPopup() if @model.isDisBelieving()
      out: ->

    @$el.hoverIntent
      timeout: 500
      over: ->
      out: => @_closePopups()

