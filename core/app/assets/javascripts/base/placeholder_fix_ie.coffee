# This only affects the inputs/textareas that aren't loaded through Backbone Views
$ ->
  resetPlaceholders()

resetPlaceholders = ->
  $('.placeholder')
    .not(':password')
    .trigger('blur.placeholder')

  $(':password')
    .show()
    .removeData(['placeholder-enabled', 'placeholder-textinput'])
    .off('focus.placeholder blur.placeholder')
    .prev('.placeholder')
    .remove()

  $('input, textarea')
    .placeholder()
