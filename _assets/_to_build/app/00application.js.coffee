
App = window.WeddingApp = {}

App.Views = {}
App.Models = {}
App.Templates = {}
App.Routers = {}
App.Collections = {}

$(document).ready ->
    App.appView = new Backbone.View
        el: 'body'
    Backbone.history.start(pushState: true, hashChange: false)

class App.Router extends Backbone.Router
    routes:
        ''         : 'home'
        '/'        : 'home'
        'rsvp'     : 'rsvp'
        'story'    : 'story'
        'where'    : 'where'
        'registry' : 'registry'
    home: ->
        homeView = new App.Views.Home()
    rsvp: ->
        homeView = new App.Views.Home(true)
    where: ->
        whereView = new App.Views.Where()

App.router = new App.Router
