# Object which holds the methods that can be called from the factlink core iframe

modalOpen = false

FactlinkJailRoot.annotatedSiteReceiver =
  modalFrameReady: (featureToggles) ->
    FactlinkJailRoot.can_haz = featureToggles
    window.FACTLINK_ON_CORE_LOAD?()

  openModalOverlay: ->
    if modalOpen
      console.error 'trying to open an already open modal: bug?'
      return
    FactlinkJailRoot.$modalFrame.addClass 'factlink-control-visible'
    modalOpen = true
    FactlinkJailRoot.trigger 'modalOpened'

  highlightNewFactlink: (displaystring, id) ->
    FactlinkJailRoot.highlightFact(displaystring, id)
    FactlinkJailRoot.trigger 'factlinkAdded'

  deleteFactlink: (id) ->
    for fact in FactlinkJailRoot.highlightsByFactIds[id]
      fact.destroy()
    delete FactlinkJailRoot.highlightsByFactIds[id]

  closeModal: ->
    FactlinkJailRoot.$modalFrame.removeClass 'factlink-control-visible'
    setTimeout( ->
      if !modalOpen
        console.error 'trying to close an already closed modal: bug?'
        return
      modalOpen = false
      FactlinkJailRoot.trigger 'modalClosed'
    , 300)

  # For compatibility, please remove the next time you see this
  closeModal_noAction: ->
    @closeModal()

  # For compatibility, please remove the next time you see this
  closeModal_highlightNewFactlink: (displaystring, id) ->
    @highlightNewFactlink(displaystring, id)
    @closeModal()

  # For compatibility, please remove the next time you see this
  closeModal_deleteFactlink: (id) ->
    @deleteFactlink(id)