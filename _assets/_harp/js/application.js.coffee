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



App = window.WeddingApp = {}

App.Views = {}
App.Models = {}
App.Templates = {}
App.Routers = {}
App.Collections = {}

$(document).ready ->
    App.appView = new Backbone.View
        el: 'body'
    Backbone.history.start(pushState: true)

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

App.router = new App.Router

# models
# collections

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


personSection = _.template("""
    <div class="guest-group">
        <h3>Guest #<%= num %></h3>
        <div class="form-group form-group-lg">
            <label for="person-name-<%= num %>">Guest Name</label>
            <input type="text" class="form-control person-name" id="person-name-<%= num %>">
        </div>
        <div class="form-group">
            <div class="radio input-lg">
                <label>
                    <input type="radio" name="attendance-<%= num %>" value="yes">
                    <span>Will be attending</span>
                </label>
            </div>
            <div class="radio input-lg">
                <label>
                    <input type="radio" name="attendance-<%= num %>" value="no">
                    <span>Will not be attending</span>
                </label>
            </div>
            <div class="form-group form-group-lg">
                <label for="entree-<%= num %>">Entree</label>
                <select id="entree-<%= num %>" name="entree" class="form-control">
                    <option value="beef">Beef short rib</option>
                    <option value="chicken">Chicken piccata</option>
                    <option value="veggie">Vegetarian</option>
                </select>
            </div>
        </div>
    </div>
""")

class App.Views.RsvpModal extends Backbone.View
    el: '#rsvp-modal'
    events: 
        'click .close': 'fadeOut'
        'click' : 'outerClick'
        'click .modal-dialog': 'innerClick'
        'click #update-guest': 'updateGuests'
        'input .person-name': 'updateName'

    clickedInside: false

    initialize: ->
        @$guestSection = @$('.guest-section')

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
        true

    updateGuests: ->
        @$guestSection.css
            opacity: 0
            display: 'none'
        numGuests = Number(@$el.find('#party-size').val())
        if numGuests == NaN or numGuests < 1
            return

        guestsHtml = ""

        for guestNum in [1..numGuests]
            guestsHtml += personSection(num: guestNum)

        @$guestSection
            .html(guestsHtml)
            .slideDown(1000)
            .animate(
                { opacity: 1 },
                complete: =>
                    @$('.modal-content').animate
                        scrollTop: "#{(@$guestSection.position().top)}px"
            )

    updateName: (evt)->
        $target = $(evt.target)
        $group = $target.parentsUntil('.guest-section').last()
        name = $target.val()
        $group.find('h3').text(name)

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
