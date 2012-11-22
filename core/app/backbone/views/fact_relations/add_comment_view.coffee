class window.AddCommentView extends Backbone.Marionette.ItemView
  className: 'add-comment'
  events:
    'click .submit': 'submit'
    'click .js-switch': 'switchCheckboxClicked'

  template: 'comments/add_comment'

  initialize: (opts) ->
    @comments = opts.comments
    @type = opts.type

  templateHelpers: =>
    type_of_action_text: @type_of_action_text()

  type_of_action_text: ->
    if @type == 'supporting'
      'Agreeing'
    else
      'Disagreeing'

  clearForm: -> @$('.content').val('')

  setFormContent: (content) -> @$('.content').val(content)

  showErrorMessage: -> @$('.js-comment-error-message').show()

  submit: ->
    content = @$('.content').val()
    comment = new Comment(content: content, created_by: currentUser)

    @comments.add comment
    comment.save {},
      success: =>
        @clearForm()
      error: =>
        @comments.remove comment
        @showErrorMessage()

  switchCheckboxClicked: (e)->
    @trigger 'switch_to_fact_relation_view', @$('.content').val()
    e.preventDefault()
    e.stopPropagation()
