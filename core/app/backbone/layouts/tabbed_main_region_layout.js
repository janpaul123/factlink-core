window.TabbedMainRegionLayout = Backbone.Marionette.Layout.extend({
  template: 'layouts/tabbed_main_region',

  regions: {
    titleRegion:   'h1',
    contentRegion: '.content'
  }
});
