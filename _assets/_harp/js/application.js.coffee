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

# models

App = window.WeddingApp

class App.Models.Rsvp extends Backbone.Model
    urlRoot: "https://docs.google.com/forms/d/1gQH7_e0hBzf6bHLyXt04qCsdCmLB1FlhrXfusFXwUIM/formResponse"

    initialize: ->
        @mapAndSet _.extend(@toJSON(), domain: window.location.host)

    mappings: 
        groupName: 'entry.183949306'
        groupSize: 'entry.1718135727'
        guestName: 'entry.1671140108'
        guestAttendance: 'entry.83143551'
        guestMeal: 'entry.763928453'
        groupSong: 'entry.2036395429'
        groupEmail: 'entry.1033845525'
        domain:     'entry.739322273'
        serializedForm: 'entry.1547193837'

    mapAndSet: (obj) ->
        result = {}
        for key, val of obj
            newKey = @mappings[key]
            result[newKey] = val
        @set(result)

    save: ->
        deferred = $.Deferred()
        $iframe = $('<iframe></iframe>')
        $iframe.addClass 'hidden'
        $iframe.attr(
            id: @cid,
            name: @cid
        )
        $('body').append($iframe)

        $form = $('<form></form>')
        $form.attr(
            action: @urlRoot
            method: "POST"
            target: @cid
        )
        for key, val of @toJSON()
            $input = $("<input></input>")
            $input.attr(
                type: "hidden"
                value: val
                name: key
            )
            $form.append($input)
        $('body').append($form)
        $iframe.on('load', ->
            deferred.resolve()
        )
        $form.submit()
        $form.remove()
        deferred

# collections

class App.Views.Home extends Backbone.View
    el: '#index-page'
    events:
        'click #rsvp' : 'rsvp'
        'click .blanket': 'close'

    initialize: (showRsvp = false) ->
        @rsvpModal = new App.Views.RsvpModal()
        @listenTo(@rsvpModal, 'close', ->
            @close()
        )
        @$blanket = @$('.blanket')
        if showRsvp
            @disableScroll()
            @rsvpModal.$('input').first().focus()

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
        <div class="form-group form-group-lg has-feedback">
            <label for="person-name-<%= num %>">Guest Name</label>
            <input type="text" class="form-control person-name" id="person-name-<%= num %>" required="required" minlength=1 name="guestName-<%= num %>">
            <span class="glyphicon glyphicon-ok form-control-feedback"> </span> 
            <span class="glyphicon glyphicon-remove form-control-feedback"> </span> 
        </div>
        <div class="form-group attendance-group">
            <div class="radio input-lg">
                <label>
                    <input type="radio" class="attendance attendance-yes" name="guestAttendance-<%= num %>" value="yes" required>
                    <span>Will be attending</span>
                </label>
            </div>
            <div class="radio input-lg">
                <label>
                    <input type="radio" class="attendance attendance-no" name="guestAttendance-<%= num %>" value="no">
                    <span>Will not be attending</span>
                </label>
            </div>
            <div class="form-group form-group-lg meal-group">
                <label for="entree-<%= num %>">Entree</label>
                <select id="entree-<%= num %>" name="guestMeal-<%= num %>" class="form-control">
                    <option value="beef">Beef short rib</option>
                    <option value="chicken">Chicken piccata</option>
                    <option value="veggie">Vegetarian</option>
                    <option value="vegan">Vegan</option>
                    <option value="child">Children's Meal</option>
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
        'input .person-name': 'updateName'
        'change #party-size': 'updateGuests'
        'change .attendance': 'handleAttendance'
        'submit .rsvp-form': 'handleSubmit'

    clickedInside: false
    showingGuests: false
    saving: false

    initialize: ->
        window.modal = @
        @$guestSection = @$('.guest-section')
        @$form = @$('.rsvp-form')
        _this = @
        @$form.validate
            errorPlacement: () ->
            submitHandler: (form) =>
                @ajaxSubmit()
            showErrors: (errorMap, errorList) ->
                @defaultShowErrors()
                _this.floatErrors()
                _this.enableIfReady(errorList)

    floatErrors: () ->
        $inputs = @$('.form-group')
        $inputs.removeClass('has-success').removeClass('has-error')
        $inputs.has('.error').addClass('has-error')
        $inputs.has('.valid').addClass('has-success')

    enableIfReady: (errorList) ->
        if @showingGuests and errorList.length == 0
            @$('#rsvp-submit').removeAttr('disabled')
        else
            @$('#rsvp-submit').attr('disabled', 'disabled')

    show: ->
        @$el.show()
        @afterShow()

    hide: ->
        @$el.hide()
        @afterClose()

    afterShow: ->
        mixpanel.track("RSVP show")

    afterClose: ->
        @saving = false
        @trigger('close')

    slideUp: ($againstEl, duration=1000) ->
        @$('.success-message').hide()
        @$('.saving-message').hide()
        @$('.rsvp-form').show()
        @$el.css(
            top: $againstEl.height()
        ).show().animate(
            { top: 0 },
            duration: duration
            complete: () =>
                @$('input').first().focus()
        )
        @afterShow()

    fadeOut: ->
        @$el.fadeOut()
        @afterClose()

    innerClick: ->
        @clickedInside = true

    outerClick: ->
        @fadeOut() unless @clickedInside
        @clickedInside = false
        true

    handleAttendance: (evt) ->
        $target = $(evt.target)
        $group = $target.parentsUntil('.guest-section').last()
        if $group.find('.attendance-no').prop('checked')
            $group.find('.meal-group').slideUp()
        else
            $group.find('.meal-group').slideDown()

    handleSubmit: (evt) ->
        evt.preventDefault()

    ajaxSubmit: (form) ->
        formData = @$form.serializeArray()
        allData = {}
        groupData = {}
        guestData = {}
        models = []
        for input in formData
            key = input.name
            val = input.value
            allData[key] = val
            
            keyParts = key.split '-'
            name = keyParts[0]
            num = keyParts[1]
            if num
                # is a guest input
                guestData[num] ||= {}
                guestData[num][name] = val
            else
                groupData[key] = val

        mixpanel.track("RSVP Submit", allData)
        if JSON? and JSON.stringify?
            groupData.serializedForm = JSON.stringify(allData)
        else
            groupData.serializedForm = @$form.serialize()

        deferreds = for num, guest of guestData
            model = new App.Models.Rsvp()
            model.mapAndSet(_.extend(guest, groupData))
            model.save()

        minimumWait = $.Deferred()

        window.setTimeout( ->
            minimumWait.resolve()
        , 2000)

        deferreds.push minimumWait

        $.when.apply($, deferreds).done(=>
            @showSuccess()
        )
        @showSaving()
        @animateSaving()

    updateGuests: ->
        @$guestSection.css
            opacity: 0
            display: 'none'
        numGuests = Number(@$el.find('#party-size').val())
        if numGuests == NaN or numGuests < 1
            return

        guestsHtml = ""

        startingNum = 1

        for guestNum in [startingNum..numGuests]
            guestsHtml += personSection(num: guestNum)

        @$guestSection
            .html(guestsHtml)
            .slideDown(1000)
            .animate(
                { opacity: 1 },
                complete: =>
                    @showingGuests = true
                    @$('.modal-content').animate
                        scrollTop: "#{(@$guestSection.position().top)}px"
            )

    updateName: (evt)->
        $target = $(evt.target)
        $group = $target.parentsUntil('.guest-section').last()
        name = $target.val()
        $group.find('h3').text(name)

    animateSaving: ->
        hearts = @$('.save-heart')
        index = -1
        @savingInterval = window.setInterval( =>
            $(hearts[index]).removeClass('active') if index >= 0
            index += 1
            index = 0 if index > (hearts.length - 1)
            $(hearts[index]).addClass 'active'
            unless @saving
                window.clearInterval @savingInterval
        , 250)

    showSaving: ->
        @$form.slideUp()
        @$('.saving-message').show()
        @saving = true
        @animateSaving()

    showSuccess: ->
        @$form.slideUp()
        @saving = false
        @$('.saving-message').hide()
        @$('.success-message').show()

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


class App.Views.Where extends Backbone.View
    el: '#where-page'
    apiKey: 'AIzaSyA4kjM9Ys7Yott7dO_ESqewl04gppkUlm8'
    mode: 'driving'

    events:
        'change .direction-choices' : 'directionChange'
        'click .direction-mode button' : 'modeChange'

    initialize: ->
        @$from = @$('#from-picker')
        @$to = @$('#to-picker')
        @$iframe = @$('#map-embed')
        @$link = @$('#map-link')
        @$modeButtons = @$('.direction-mode .btn')
        @$("button[data-mode='#{@mode}']").addClass('active')

        @$to.find("option[value='Garden+Court+Hotel,+Cowper+Street,+Palo+Alto,+CA,+United+States']").attr("selected", true)
        @$from.find("option[value='Church+of+the+Nativity,+Oak+Grove+Avenue,+Menlo+Park,+CA,+United+States']").attr("selected", true)

    modeChange: (evt)->
        $target = $(evt.target)
        @$modeButtons.removeClass('active')
        $target.addClass('active')
        unless @mode == $target.data('mode')
            @mode = $target.data('mode')
            @directionChange()

    directionChange: ->
        @$iframe.attr('src', @embedUrl())
        @$link.attr('href', @linkUrl())

    getDirections: ->
        origin: @$from.val()
        destination: @$to.val()

    embedUrl: ->
        params = $.extend(@getDirections(), 
            mode: @mode
            key: @apiKey
        )
        
        "https://www.google.com/maps/embed/v1/directions?#{@paramString(params)}"

    linkUrl: ->
        directions = @getDirections()
        "https://www.google.com/maps/dir/#{directions.origin}/#{directions.destination}"

    paramString: (params)->
        paramArr = for key, val of params
            "#{key}=#{val}"
        paramArr.join("&")
