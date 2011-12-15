window.AppView = Backbone.View.extend({
  el: $('#container'),
  
  initialize: function() {
    this.channelCollectionView = new ChannelCollectionView({
      collection: Channels
    }).render();
    
    this.relatedUsersView = new RelatedUsersView();
    
    this.activitiesView = new ActivitiesView();
    
    this.setupChannelReloading();
    
    if ( typeof currentChannel !== "undefined" ) {
      this.changeUser(currentChannel.user);
    } else {
      this.changeUser(currentUser);
    }
  },
  
  // TODO: This function needs to wait for loading (Of channel contents in main column)
  setupChannelReloading: function(){
    var args = arguments;
    setTimeout(function(){
      Channels.fetch({
        success: args.callee
      });
    }, 7000);
  },
  
  openChannel: function(channel) {
    var self = this;
    var oldChannel = currentChannel;
    
    window.currentChannel = channel;
    
    if ( channel ) {
      if ( channel.user.id !== oldChannel.user.id ) {
        this.changeUser(channel.user);
        
        this.channelCollectionView.reload(currentChannel.id);
      }
      
      if ( this.channelView ) {
        this.channelView.close();
      }
      
      this.channelView = new ChannelView({model: channel}).render();
      
      this.relatedUsersView
            .setChannel(channel)
            .render();
      
      this.activitiesView
            .setChannel(channel)
            .render();
    }
    
    return this;
  },
  
  render: function() {
    $('#main-wrapper').html( this.channelView.el );
  },
  
  changeUser: function(user) {
    if ( this.userView ) {
      this.userView.close();
    }
    
    this.userView = new UserView({model: user}).render();
  }
});
