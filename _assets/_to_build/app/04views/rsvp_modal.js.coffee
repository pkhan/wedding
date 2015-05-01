class App.Views.RsvpModal extends Backbone.View
    el: '#rsvp-modal'
    events: 
        'click .close': 'close'

    show: ->
        @$el.show()

    slideUp: ($againstEl, duration=1000) ->
        @$el.css(
            top: $againstEl.height()
        ).show().animate(
            { top: 0 },
            duration: duration
        )
