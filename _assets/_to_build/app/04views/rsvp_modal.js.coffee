personSection = _.template("""
    <div class="guest-group">
        <h3>Guest #<%= num %></h3>
        <div class="form-group form-group-lg">
            <label for="person-name-<%= num %>">Guest Name</label>
            <input type="text" class="form-control person-name" id="person-name-<%= num %>">
        </div>
        <div class="form-group attendance-group">
            <div class="radio input-lg">
                <label>
                    <input type="radio" class="attendance attendance-yes" name="attendance-<%= num %>" value="yes">
                    <span>Will be attending</span>
                </label>
            </div>
            <div class="radio input-lg">
                <label>
                    <input type="radio" class="attendance attendance-no" name="attendance-<%= num %>" value="no">
                    <span>Will not be attending</span>
                </label>
            </div>
            <div class="form-group form-group-lg meal-group">
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
        'change .attendance': 'handleAttendance'

    clickedInside: false

    initialize: ->
        @$guestSection = @$('.guest-section')
        @$form = @$('.rsvp-form')
        _this = @
        @$form.validate
            errorPlacement: () ->
            showErrors: () ->
                @defaultShowErrors()
                _this.floatErrors()

    floatErrors: () ->
        $inputs = @$('.form-group')
        $inputs.removeClass('has-success').removeClass('has-error')
        $inputs.has('.error').addClass('has-error')
        $inputs.has('.valid').addClass('has-success')

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
