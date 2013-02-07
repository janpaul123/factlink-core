class window.EvidenceBottomView extends Backbone.Marionette.ItemView
  className: 'evidence-bottom bottom-base'

  template: 'facts/bottom_base'

  triggers:
    'click .js-sub-comments-link': 'toggleSubCommentsList'

  events:
    'click .js-open-proxy-link': 'openEvidenceProxyLink'

  initialize: ->
    @bindTo @model, 'change', @render, @

  templateHelpers: ->
    showTime: false
    showRepost: false
    showShare: false
    showSubComments: true
    showDiscussion: ->
      @fact_base?
    showFactInfo: ->
      @fact_base?.proxy_scroll_url?
    fact_url_host: ->
      if @fact_base?.fact_url?
        new Backbone.Factlink.Url(@fact_base?.fact_url).host()

  onRender: ->
    @bindTo @model, 'change:sub_comments_count', @updateSubCommentsLink, @
    @updateSubCommentsLink()

  updateSubCommentsLink: ->
    count = @model.get('sub_comments_count')

    count_str = if count then " (#{count})" else ""

    @$(".js-sub-comments-link").text "Comments#{count_str}"

  openEvidenceProxyLink: (e) ->
    mp_track "Evidence: Open proxy link",
      site_url: @model.get("fact_base").fact_url
