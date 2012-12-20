class window.EvidenceCollection extends Backbone.Collection

  parse: (data) ->
    results = []
    _.each data, (item) =>
      switch item.evidence_type
        when 'FactRelation'
          results.push new FactRelation(item)
        when 'Comment'
          results.push new Comment(item)
        else
          console.info "Evidence type not supported: #{item.evidence_type}"
    results

  initialize: (models, opts) ->
    @type = opts.type
    @fact = opts.fact

  url: -> "/facts/#{@fact.id}/#{@type}_evidence/combined"
