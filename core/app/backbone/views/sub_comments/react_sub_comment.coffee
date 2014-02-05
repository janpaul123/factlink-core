window.ReactAvatar = React.createBackboneClass
  displayName: 'ReactAvatar'

  render: ->
    _a [href: @props.user.link()],
      _img [ "avatar-image",
          src: @props.user.avatar_url(@props.size)
        ]

window.ReactSubComment = React.createBackboneClass
  displayName: 'ReactSubComment'

  _save: ->
    @model().saveWithState()

  _content_tag: ->
    if @model().get('formatted_content')
      _span ["subcomment-content spec-subcomment-content",
        dangerouslySetInnerHTML: {__html: @model().get('formatted_content')}]
    else
      _span ["subcomment-content spec-subcomment-content"],
        @model().get('content')

  render: ->
    creator = @model().creator()
    R.div className: "sub-comment",
      R.span className: "sub-comment-avatar",
        ReactAvatar user: creator, size: 28
      R.div "",
        R.a className: "sub-comment-creator", href: creator.link(),
          creator.get("name")

        if @model().get('time_ago')
          R.span className: "sub-comment-time",
            @model().get('time_ago'),
            ' '
            Factlink.Global.t.ago


      @_content_tag()

      if @model().get('save_failed') == true
        _a ['button', 'button-danger', onClick: @_save, style: {float: 'right'} ],
          'Save failed - Retry'
      if @model().can_destroy()
        window.ReactDeleteButton
          model: @model()
          onDelete: -> @model.destroy wait: true
