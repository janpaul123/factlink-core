class Admin::GlobalFeatureTogglesController < AdminController

  layout "admin"

  def show
    @enabled_features = old_interactor :'global_features/all'
  end

  def update
    @enabled_features = params[:features].andand.keys || []
    old_interactor :'global_features/set', @enabled_features
    render :show
  end

  helper_method :dead_features
  def dead_features
    @enabled_features.select {|f| !Ability::FEATURES.include? f }
  end
end