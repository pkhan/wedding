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
