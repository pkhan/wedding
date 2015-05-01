class App.Views.RsvpModal extends Backbone.View
    el: '#rsvp-modal'
    events: 
        'click .close': 'fadeOut'
        'click' : 'outerClick'
        'click .modal-dialog': 'innerClick'

    clickedInside: false

    show: ->
        @$el.show()

    hide: ->
        @$el.hide()
        @afterClose()

    afterClose: ->
        @trigger('close')

    slideUp: ($againstEl, duration=1000) ->
        @$el.css(
            top: $againstEl.height()
        ).show().animate(
            { top: 0 },
            duration: duration
        )

    fadeOut: ->
        @$el.fadeOut()
        @afterClose()

    innerClick: ->
        @clickedInside = true

    outerClick: ->
        @fadeOut() unless @clickedInside
        @clickedInside = false
