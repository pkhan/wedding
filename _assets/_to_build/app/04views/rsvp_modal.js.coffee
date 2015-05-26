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
                    <input type="radio" class="attendance attendance-yes" name="guestAttendance-<%= num %>" value="yes" required="required">
                    <span>Will be attending</span>
                </label>
            </div>
            <div class="radio input-lg">
                <label>
                    <input type="radio" class="attendance attendance-no" name="guestAttendance-<%= num %>" value="no" required="required">
                    <span>Will not be attending</span>
                </label>
            </div>
            <div class="form-group form-group-lg meal-group">
                <label for="entree-<%= num %>">Entree</label>
                <select id="entree-<%= num %>" name="guestMeal-<%= num %>" class="form-control">
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

    hide: ->
        @$el.hide()
        @afterClose()

    afterClose: ->
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
        groupData = {}
        guestData = {} 
        models = []
        for input in formData
            key = input.name
            val = input.value
            keyParts = key.split '-'
            name = keyParts[0]
            num = keyParts[1]

            if num
                # is a guest input
                guestData[num] ||= {}
                guestData[num][name] = val
            else
                groupData[key] = val

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
            console.log "biggen"
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
