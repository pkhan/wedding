var App;

App = window.WeddingApp = {};

App.Views = {};

App.Models = {};

App.Templates = {};

App.Routers = {};

App.Collections = {};

App.stuff = "thinga";

$(document).ready(function() {
  return window.modal = new App.Views.HeartBox();
});

App.Views.HeartBox = Backbone.View.extend({
  el: '.modal-outer',
  initialize: function() {
    this.$heartBox = this.$('.heart-box');
    this.draw = SVG(this.$heartBox[0]);
    this.$formInner = this.$('.modal-inner');
    this.group = this.draw.group();
    this.poly = this.group.polygon().fill({
      color: '#F00'
    });
    this.leftCircle = this.group.circle().fill({
      color: '#F00'
    });
    return this.rightCircle = this.group.circle().fill({
      color: '#F00'
    });
  },
  maxWidth: function() {
    return this.$el.width();
  },
  formWidth: function() {
    return this.$formInner.width();
  },
  maxHeight: function() {
    return this.$el.height();
  },
  formHeight: function() {
    return this.$formInner.height();
  },
  render: function() {
    return this.drawHeart();
  },
  drawHeart: function(intersectPortion) {
    var bottomX, bottomY, formWidth, heartWidth, intersectAt, leftRad, leftX, leftY, maxWidth, middleX, middleY, overlap, pi, polyPoints, polyString, radius, rightRad, rightX, rightY;
    if (intersectPortion == null) {
      intersectPortion = 1 / 5;
    }
    formWidth = this.formWidth();
    maxWidth = this.maxWidth();
    heartWidth = formWidth + 300;
    overlap = .9;
    radius = heartWidth / 4;
    heartWidth = radius + radius * 2 * overlap + radius;
    if (heartWidth > maxWidth) {
      heartWidth = maxWidth;
    }
    this.draw.size(heartWidth, this.maxHeight());
    pi = Math.PI;
    intersectAt = intersectPortion * pi;
    this.leftCircle.x(radius).y(radius).radius(radius);
    this.rightCircle.x(radius + (radius * 2 * overlap)).y(radius).radius(radius);
    polyPoints = [];
    leftRad = pi + intersectAt;
    leftX = (Math.cos(leftRad) * radius) + radius;
    leftY = (Math.sin(leftRad) * radius * -1) + radius;
    polyPoints.push([leftX, leftY]);
    middleX = radius * 2 * overlap;
    middleY = radius;
    polyPoints.push([middleX, middleY]);
    rightRad = (2 * pi) - intersectAt;
    rightX = (Math.cos(rightRad) * radius) + radius + (radius * 2 * overlap);
    rightY = (Math.sin(rightRad) * radius * -1) + radius;
    polyPoints.push([rightX, rightY]);
    bottomX = radius * 2 * overlap;
    bottomY = radius * 2 * 2;
    polyPoints.push([bottomX, bottomY]);
    polyString = polyPoints.map(function(point) {
      return point.join(',');
    }).join(' ');
    return this.poly.plot(polyString);
  }
});
