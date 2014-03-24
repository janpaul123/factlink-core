window.FactlinkAppMode ?= {}
window.FactlinkAppMode.coreInSite = (app) ->
  app.onClientApp = false
  app.startSiteRegions()
  window.FactlinkApp.NotificationCenter = new NotificationCenter('.js-notification-center-alerts')
  app.automaticLogoutInitializer()
  declareSiteRoutes()

declareSiteRoutes = ->
  new ProfileRouter #first, as then it doesn't match index pages such as "/m" using "/:username"
  new SearchRouter
  new FeedsController
