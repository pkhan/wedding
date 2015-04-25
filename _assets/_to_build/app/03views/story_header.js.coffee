# VIEWS
# App = window.WeddingApp

class App.Views.StoryHeader extends Backbone.View
    el: '#story-page .top-part'

    backgroundImages: [
        '/images/shadow_1_wide.jpg'
    ]

    height: 300

    initialize: ->
        @$layers = @$('.heart-bg')

    changeBG: ->
        newImage = @backgroundImages.pop()

        @$el.css({ "background-image" : "url(#{newImage})"})

    animateHearts: ->
        return if @animating
        @animating = true
        delay = 0
        count = @$layers.length
        for layer in @$layers
            $layer = $(layer)
            @animateLayer $layer, delay
            delay += 100

    animateLayer: ($layer, delay)->
        height = @height + 100
        duration = 2000 - (delay * 2)
        console.log duration
        console.log "hey"
        setTimeout( =>
            $layer.animate(
                { "top" : "-#{height}%" },
                duration: duration,
                easing: 'linear',
                complete: =>
                    $layer.css("top": "100%")
                    if index = length - 1
                        @animating = false
            )
        , delay)
