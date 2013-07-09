class window.InteractiveWheelView extends BaseFactWheelView
  clickOpinionType: (opinion_type) ->
    if @model.isUserOpinion(opinion_type)
      @model.unsetActiveOpinionType opinion_type,
        error: ->
          FactlinkApp.NotificationCenter.error "Something went wrong while removing your opinion on the Factlink, please try again."
    else
      @model.setActiveOpinionType opinion_type,
        error: ->
          FactlinkApp.NotificationCenter.error "Something went wrong while setting your opinion on the Factlink, please try again."