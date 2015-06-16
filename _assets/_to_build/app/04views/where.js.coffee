
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
