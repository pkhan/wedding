
class App.Views.Home extends Backbone.View
    el: '#index-page'
    events:
        'click #rsvp' : 'rsvp'
        'click .blanket': 'close'

    initialize: (showRsvp = false) ->
        @disableScroll() if showRsvp
        @rsvpModal = new App.Views.RsvpModal()
        @listenTo(@rsvpModal, 'close', ->
            @close()
        )
        @$blanket = @$('.blanket')

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
        @disableScroll()

    close: ->
        @$blanket.fadeOut()
        @enableScroll()

    enableScroll: ->
        $('body').removeClass('no-scroll')

    disableScroll: -> 
        $('body').addClass('no-scroll')
