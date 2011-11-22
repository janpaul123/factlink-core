var Workspace = Backbone.Router.extend({
  initialize: function(channel_dump) {
    this.route(/([^\/]+)\/channels\/([0-9]+|all)\/?$/, "getChannelFacts", this.getChannelFacts);
    
    this.view = new AppView();
  },
  
  getChannelFacts: function(username, channel_id) {
    this.view.openChannel(username, channel_id);
  },
  
  getUsername: function() {
    return location.pathname.split("/")[1];
  }

});