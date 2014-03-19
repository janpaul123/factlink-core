window.ReactSubComments = React.createBackboneClass
  displayName: 'ReactSubComments'
  propTypes:
    fact_opinionators: React.PropTypes.instanceOf(Opinionators).isRequired
    model: React.PropTypes.instanceOf(SubComments).isRequired

  componentWillMount: ->
    @model().fetch()

  render: ->
    _div [],
      _div ['loading-indicator-centered'],
        ReactLoadingIndicator
          model: @model()
      @model().map (sub_comment) =>
        ReactSubComment
          model: sub_comment
          key: sub_comment.get('id') || sub_comment.cid
          fact_opinionators: @props.fact_opinionators
      ReactSubCommentsAdd
        model: @model()
        fact_opinionators: @props.fact_opinionators

ReactSubCommentsAdd = React.createBackboneClass
  displayName: 'ReactSubCommentsAdd'

  getInitialState: ->
    text: ''
    opened: false

  _subComment: ->
    new SubComment
      content: $.trim(@state.text)
      created_by: currentUser.toJSON()

  _submit: ->
    sub_comment = @_subComment()
    return unless sub_comment.isValid()

    @model().add(sub_comment)
    sub_comment.saveWithState()

    @refs.textarea.updateText ''
    @setState opened: false

  _onTextareaChange: (text) ->
    @setState(text: text)
    @setState(opened: true) if text.length > 0

  render: ->
    _div ['sub-comment-add', 'spec-sub-comments-form'],
      _div ['sub-comment-avatar-wrapper'],
        ReactOpinionatedAvatar
          user: currentUser
          model: @props.fact_opinionators
          size: 28
      _div ['sub-comment-textarea-wrapper'],
        ReactTextArea
          ref: 'textarea'
          placeholder: 'Leave a reply'
          storageKey: "add_subcomment_to_comment_#{@model().parentModel.id}"
          onChange: @_onTextareaChange
          onSubmit: => @refs.signinPopover.submit(=> @_submit())
        if @state.opened
          _button ["button-confirm button-small spec-submit",
            disabled: !@_subComment().isValid()
            onClick: => @refs.signinPopover.submit(=> @_submit())
          ],
            Factlink.Global.t.post_subcomment
            ReactSigninPopover
              ref: 'signinPopover'

