
App = window.WeddingApp = {}

App.Views = {}
App.Models = {}
App.Templates = {}
App.Routers = {}
App.Collections = {}

App.stuff = "thinga"

$(document).ready ->
    window.modal = new App.Views.HeartBox()
    # modal.render()

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

