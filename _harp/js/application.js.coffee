
App = window.WeddingApp = {}

App.Views = {}
App.Models = {}
App.Templates = {}
App.Routers = {}
App.Collections = {}

App.stuff = "thinga"

drawHeart = (intersectPortion = 1/3.25) ->
    radius = 200
    draw = SVG($('.heart-box')[0])
    pi = Math.PI
    intersectAt = intersectPortion * pi
    overlap = .9

    if window.group?
        window.group.remove()

    window.group = draw.group()

    leftCircle = group.circle(radius * 2).fill(color: '#F00')
    rightCircle = group.circle(radius * 2).x(radius * 2 * overlap).fill(color:'#F00')
    polyPoints = []

    leftRad = pi + intersectAt
    leftX = (Math.cos(leftRad) * radius) + radius
    leftY = (Math.sin(leftRad) * radius * -1) + radius
    polyPoints.push [leftX, leftY]

    middleX = radius * overlap
    middleY = radius
    polyPoints.push [middleX, middleY]

    rightRad = (2 * pi) - intersectAt
    rightX = (Math.cos(rightRad) * radius) + radius + (radius * 2 * overlap)
    rightY = (Math.sin(rightRad) * radius * -1) + radius
    polyPoints.push [rightX, rightY]

    bottomX = radius * 2 * overlap
    bottomY = radius * 2 * 1.5
    polyPoints.push [bottomX, bottomY]

    polyString = polyPoints.map((point) ->
        point.join(',')
    ).join(' ')

    poly = group.polygon(polyString).fill(color: '#F00')

$(document).ready ->
    drawHeart()
# models
# collections
# VIEWS
# App = window.WeddingApp