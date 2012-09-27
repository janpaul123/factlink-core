#TODO: check if this hide-input class thingy has some importance

# TODO: remove this, use triggers instead
updateWindowHeight = ->  window.updateHeight() if window.updateHeight

class window.AutoCompletedAddToChannelView extends Backbone.Marionette.Layout
  tagName: "div"
  className: "add-to-channel"
  events:
    "keydown input.typeahead": "parseKeyDown"
    "keyup input.typeahead": "autoComplete"
    "click div.fake-input": "focusInput"
    "click div.auto_complete": "addCurrentlySelectedChannel"
    "click div.fake-input a": "addCurrentlySelectedChannel"
    "click .show-input-button": "showInput"

  regions:
    'added_channels': 'div.added_channels_container'
    'auto_completes': 'div.auto_complete_container'

  activeChannelKey: -> @_auto_completes_view.activeChannelKey()

  setActiveChannelKey: (value) -> @_auto_completes_view.setActiveChannelKey(value)

  template: "channels/_auto_completed_add_to_channel"

  initialize: ->
    @vent = new Backbone.Marionette.EventAggregator()
    @collection = new OwnChannelCollection()
    @_added_channels_view = new AutoCompletedAddedChannelsView(
      collection: @collection
      mainView: this
    )
    @_auto_completes_view = new AutoCompletesView(
      mainView: this
      alreadyAdded: @collection
    )
    @_auto_completes_view.on 'heightChanged', -> updateWindowHeight()


  onRender: ->
    @$(".auto_complete ul").preventScrollPropagation()

    @added_channels.show(@_added_channels_view)
    @auto_completes.show(@_auto_completes_view)

    updateWindowHeight()

  parseKeyDown: (e) ->
    @_proceed = false
    switch e.keyCode
      when 13 then @addCurrentlySelectedChannel()
      when 40 then @_auto_completes_view.moveSelectionDown()
      when 38 then @_auto_completes_view.moveSelectionUp()
      when 27 then @completelyDisappear()
      else @_proceed = true

    unless @_proceed
      e.preventDefault()
      e.stopPropagation()


  showInput: -> @$el.removeClass("hide-input").find(".fake-input input").focus()

  focusInput: -> @$("input.typeahead").focus()

  userChannelForTopic: (title)-> currentUser.channels.getByTitle(title)

  #TODO: readd enable/disable in some way

  addCurrentlySelectedChannel: ->
    if activeTopic = @_auto_completes_view.currentActiveModel()
      @$("input.typeahead").val activeTopic.get("title")

    title = $.trim @$("input.typeahead").val()

    if ch = @userChannelForTopic(title)
      @addNewChannel ch
      return

    $.ajax(
      url: "/" + currentUser.get("username") + "/channels"
      data:
        title: title

      type: "POST"
    ).done (data)=>
      channel = new Channel(data)
      currentUser.channels.add channel
      @addNewChannel(channel)

  addNewChannel: (channel) ->
    @vent.trigger "addChannel", channel
    @collection.add channel

  disable: ->
    @$el.addClass("disabled").find("input.typeahead").prop "disabled", true
    @$(".btn").addClass "disabled"

  enable: ->
    @$el.removeClass("disabled").find("input.typeahead").prop "disabled", false
    @$(".btn").removeClass "disabled"


  autoComplete: ->
    searchValue = @$("input.typeahead").val()
    @_auto_completes_view.search_collection.searchFor searchValue