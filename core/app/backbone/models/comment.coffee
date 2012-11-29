class window.Comment extends Backbone.Model

  templateHelpers: =>
    creator: @creator

  creator: -> new User(@get('created_by'))

  can_destroy: -> @creator().get('id') == currentUser.get('id')

  believe: -> @save
    opinion: 'believes'
    positive_active: ' active'
    negative_active: ''

  disbelieve: -> @save
    opinion: 'disbelieves'
    positive_active: ''
    negative_active: ' active'
