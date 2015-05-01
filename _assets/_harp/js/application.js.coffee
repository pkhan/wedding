
App = window.WeddingApp = {}

App.Views = {}
App.Models = {}
App.Templates = {}
App.Routers = {}
App.Collections = {}

$(document).ready ->
    if $('#story-page').length > 0
        App.headerView = new App.Views.StoryHeader

# Simple jQuery function to make hearts suddenly fly up and across an el

makeLayer = (heartHeight) ->
    el = $("<div></div>")
        .addClass("heart-bg")
        .css("background-size" : "#{heartHeight}px #{heartHeight}px")
    {
        $el: el
        heartHeight: heartHeight
    }

animateLayer = (layer, delay) ->
    duration = 2000 - (delay)
    console.log duration
    setTimeout( ->
        layer.$el.animate(
            { "top" : "-#{layer.height}px" },
            duration: duration,
            easing: 'linear',
            complete: =>
                layer.$el.remove()
        )
    , delay)


$.fn.animateHearts = (numLayers=3, totalDuration=2000, heightScale=2, scale=20, delayIncrease=300) ->
    height = this.height()
    innerHeight = height * heightScale
    layers = (makeLayer(scale * i) for i in [1..numLayers])
    delay = 0
    for layer in layers
        layerHeight = Math.round( innerHeight / layer.heartHeight) * layer.heartHeight    
        layer.$el.css(
            top: height
            height: layerHeight
        )
        layer.height = layerHeight

        this.append(layer.$el)
        animateLayer(layer, delay)
        delay += delayIncrease


# models
# collections
# VIEWS
# App = window.WeddingApp

App.Views.HeartBox = Backbone.View.extend
    el: '.modal-outer'
    initialize: ->
        @$heartBox = @$('.heart-box')
        @draw = SVG(@$heartBox[0])
        @$formInner = @$('.modal-inner')
        @group = @draw.group()
        @poly = @group.polygon().fill(color: '#F00')
        @leftCircle = @group.circle().fill(color: '#F00')
        @rightCircle = @group.circle().fill(color: '#F00')
    maxWidth: ->
        @$el.width()
    formWidth: ->
        @$formInner.width()
    maxHeight: ->
        @$el.height()
    formHeight: ->
        @$formInner.height()
    render: ->
        @drawHeart()
    drawHeart: (intersectPortion = 1/5) ->
        formWidth = @formWidth()
        maxWidth = @maxWidth()
        heartWidth = formWidth + 300

        overlap = .9

        radius = heartWidth / 4
        heartWidth = radius + radius * 2 * overlap + radius
        heartWidth = maxWidth if heartWidth > maxWidth
        @draw.size(heartWidth, @maxHeight())

        pi = Math.PI
        intersectAt = intersectPortion * pi

        @leftCircle.x(radius).y(radius).radius(radius)
        @rightCircle.x(radius + (radius * 2 * overlap)).y(radius).radius(radius)
        polyPoints = []

        leftRad = pi + intersectAt
        leftX = (Math.cos(leftRad) * radius) + radius
        leftY = (Math.sin(leftRad) * radius * -1) + radius
        polyPoints.push [leftX, leftY]

        middleX = radius * 2 * overlap
        middleY = radius
        polyPoints.push [middleX, middleY]

        rightRad = (2 * pi) - intersectAt
        rightX = (Math.cos(rightRad) * radius) + radius + (radius * 2 * overlap)
        rightY = (Math.sin(rightRad) * radius * -1) + radius
        polyPoints.push [rightX, rightY]

        bottomX = radius * 2 * overlap
        bottomY = radius * 2 * 2
        polyPoints.push [bottomX, bottomY]

        polyString = polyPoints.map((point) ->
            point.join(',')
        ).join(' ')

        @poly.plot(polyString)


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
            delay += 300

    animateLayer: ($layer, delay)->
        height = @height + 100
        duration = 2000 - (delay)
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
