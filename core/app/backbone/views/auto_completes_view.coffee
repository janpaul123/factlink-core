class window.AutoCompletesView extends Backbone.Marionette.CompositeView
  template: "channels/_auto_completes"

  itemViewContainer: 'ul'
  itemView: AutoCompletedChannelView

  className: 'auto_complete'

  itemViewOptions: =>
    return {
      query: @options.mainView._lastKnownSearchValue,
      parent: @options.mainView
    }


  initialize: ->
    this.list = [];
    @search_collection = new TopicSearchResults()
    @collection = collectionDifference(TopicSearchResults,
      'slug_title', @search_collection, @options.alreadyAdded)

  closeList: ->
    view.close() for view in @list
    @list = [];

  onClose: -> @closeList()

  activeChannelKey: -> @options.mainView._activeChannelKey
  setActiveChannelKey: (value)->
    @options.mainView._activeChannelKey = value

  deActivateCurrent: () ->
    if ( @list[@activeChannelKey()] )
      @list[@activeChannelKey()].trigger('deactivate');

  fixKeyModulo: (key)->
    if (@options.mainView.isAddNewVisible())
      maxval = @list.length;
    else
      maxval = @list.length - 1;


    key = 0 if (key > maxval)
    key = maxval if (key < 0)

    return key

  setActiveAutoComplete:  (key, scroll)->
    this.options.mainView.deActivateCurrent()
    key = this.fixKeyModulo(key)

    if 0 <= key < @list.length
      @list[key].trigger('activate');

      if ( typeof scroll == "boolean")
        list = @$("ul")[0];
        if (list.scrollHeight > list.clientHeight)
          @list[key].el.scrollIntoView(scroll)


    else
      @options.mainView.activateAddNew()

    @setActiveChannelKey(key)

  moveSelectionUp: (e)->
    prevKey = if @activeChannelKey()? then @activeChannelKey() - 1 else -1
    this.setActiveAutoComplete(prevKey, false)
    e.preventDefault()

  moveSelectionDown: (e)->
    nextKey = if @activeChannelKey()? then this.activeChannelKey() + 1 else 0
    this.setActiveAutoComplete(nextKey, false)
    e.preventDefault()

  onItemAdded: (view)->
    @options.mainView.$('.auto_complete').removeClass('empty')
    @options.mainView.showAutoComplete()
    @list.push(view)
    @hideAddNewIfNotNeeded(view.model)

  hideAddNewIfNotNeeded: (channel)->
    if ( channel.get('user_channel') )
      lowerCaseTitle = channel.get('user_channel').title.toLowerCase();
      lowerCaseSearch = @options.mainView._lastKnownSearchValue.toLowerCase();

      console.info("("+lowerCaseTitle+","+lowerCaseSearch+")", lowerCaseSearch == lowerCaseTitle);

      @options.mainView.hideAddNew() if lowerCaseSearch == lowerCaseTitle
