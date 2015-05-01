
class App.Views.Home extends Backbone.View
    el: '#index-page'
    events:
        'click #rsvp' : 'rsvp'

    initialize: (showRsvp = false) ->
        @showRsvp() if showRsvp
        @rsvpModal = new App.Views.RsvpModal()
        @$blanket = $('.blanket')

    rsvp: (evt) ->
        evt.preventDefault()
        @showRsvp()

    showRsvp: ->
        @$blanket.fadeIn(=>
            @$blanket.animateHearts(3, 2000, 2, 40, 300)
            setTimeout( =>
                @rsvpModal.slideUp(@$blanket, 1000)
            , 600)
        )
