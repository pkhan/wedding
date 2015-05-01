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

