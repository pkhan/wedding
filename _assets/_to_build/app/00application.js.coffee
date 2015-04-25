
App = window.WeddingApp = {}

App.Views = {}
App.Models = {}
App.Templates = {}
App.Routers = {}
App.Collections = {}

$(document).ready ->
    if $('#story-page').length > 0
        App.headerView = new App.Views.StoryHeader
