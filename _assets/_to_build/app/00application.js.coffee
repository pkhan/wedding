
App = window.WeddingApp = {}

App.Views = {}
App.Models = {}
App.Templates = {}
App.Routers = {}
App.Collections = {}

$(document).ready ->
    App.appView = new Backbone.View
        el: '.body'
    Backbone.history.start(pushState: true)

class App.Router extends Backbone.Router
    routes:
        ''         : 'home'
        '/'        : 'home'
        'rsvp'     : 'home'
        'story'    : 'story'
        'where'    : 'where'
        'registry' : 'registry'
    home: ->
        homeView = new App.Views.Home()

App.router = new App.Router
