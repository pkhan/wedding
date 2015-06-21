var App, animateLayer, makeLayer, personSection,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

makeLayer = function(heartHeight) {
  var el;
  el = $("<div></div>").addClass("heart-bg").css({
    "background-size": "" + heartHeight + "px " + heartHeight + "px"
  });
  return {
    $el: el,
    heartHeight: heartHeight
  };
};

animateLayer = function(layer, delay) {
  var duration;
  duration = 2000 - delay;
  return setTimeout(function() {
    return layer.$el.animate({
      "top": "-" + layer.height + "px"
    }, {
      duration: duration,
      easing: 'linear',
      complete: (function(_this) {
        return function() {
          return layer.$el.remove();
        };
      })(this)
    });
  }, delay);
};

$.fn.animateHearts = function(numLayers, totalDuration, heightScale, scale, delayIncrease) {
  var delay, height, i, innerHeight, layer, layerHeight, layers, _i, _len, _results;
  if (numLayers == null) {
    numLayers = 3;
  }
  if (totalDuration == null) {
    totalDuration = 2000;
  }
  if (heightScale == null) {
    heightScale = 2;
  }
  if (scale == null) {
    scale = 20;
  }
  if (delayIncrease == null) {
    delayIncrease = 300;
  }
  height = this.height();
  innerHeight = height * heightScale;
  layers = (function() {
    var _i, _results;
    _results = [];
    for (i = _i = 1; 1 <= numLayers ? _i <= numLayers : _i >= numLayers; i = 1 <= numLayers ? ++_i : --_i) {
      _results.push(makeLayer(scale * i));
    }
    return _results;
  })();
  delay = 0;
  _results = [];
  for (_i = 0, _len = layers.length; _i < _len; _i++) {
    layer = layers[_i];
    layerHeight = Math.round(innerHeight / layer.heartHeight) * layer.heartHeight;
    layer.$el.css({
      top: height,
      height: layerHeight
    });
    layer.height = layerHeight;
    this.append(layer.$el);
    animateLayer(layer, delay);
    _results.push(delay += delayIncrease);
  }
  return _results;
};

App = window.WeddingApp = {};

App.Views = {};

App.Models = {};

App.Templates = {};

App.Routers = {};

App.Collections = {};

$(document).ready(function() {
  App.appView = new Backbone.View({
    el: 'body'
  });
  return Backbone.history.start({
    pushState: true,
    hashChange: false
  });
});

App.Router = (function(_super) {
  __extends(Router, _super);

  function Router() {
    return Router.__super__.constructor.apply(this, arguments);
  }

  Router.prototype.routes = {
    '': 'home',
    '/': 'home',
    'rsvp': 'rsvp',
    'story': 'story',
    'where': 'where',
    'registry': 'registry'
  };

  Router.prototype.home = function() {
    var homeView;
    return homeView = new App.Views.Home();
  };

  Router.prototype.rsvp = function() {
    var homeView;
    return homeView = new App.Views.Home(true);
  };

  Router.prototype.where = function() {
    var whereView;
    return whereView = new App.Views.Where();
  };

  return Router;

})(Backbone.Router);

App.router = new App.Router;

App = window.WeddingApp;

App.Models.Rsvp = (function(_super) {
  __extends(Rsvp, _super);

  function Rsvp() {
    return Rsvp.__super__.constructor.apply(this, arguments);
  }

  Rsvp.prototype.urlRoot = "https://docs.google.com/forms/d/1gQH7_e0hBzf6bHLyXt04qCsdCmLB1FlhrXfusFXwUIM/formResponse";

  Rsvp.prototype.initialize = function() {
    return this.mapAndSet(_.extend(this.toJSON(), {
      domain: window.location.host
    }));
  };

  Rsvp.prototype.mappings = {
    groupName: 'entry.183949306',
    groupSize: 'entry.1718135727',
    guestName: 'entry.1671140108',
    guestAttendance: 'entry.83143551',
    guestMeal: 'entry.763928453',
    groupSong: 'entry.2036395429',
    groupEmail: 'entry.1033845525',
    domain: 'entry.739322273',
    serializedForm: 'entry.1547193837'
  };

  Rsvp.prototype.mapAndSet = function(obj) {
    var key, newKey, result, val;
    result = {};
    for (key in obj) {
      val = obj[key];
      newKey = this.mappings[key];
      result[newKey] = val;
    }
    return this.set(result);
  };

  Rsvp.prototype.save = function() {
    var $form, $iframe, $input, deferred, key, val, _ref;
    deferred = $.Deferred();
    $iframe = $('<iframe></iframe>');
    $iframe.addClass('hidden');
    $iframe.attr({
      id: this.cid,
      name: this.cid
    });
    $('body').append($iframe);
    $form = $('<form></form>');
    $form.attr({
      action: this.urlRoot,
      method: "POST",
      target: this.cid
    });
    _ref = this.toJSON();
    for (key in _ref) {
      val = _ref[key];
      $input = $("<input></input>");
      $input.attr({
        type: "hidden",
        value: val,
        name: key
      });
      $form.append($input);
    }
    $('body').append($form);
    $iframe.on('load', function() {
      return deferred.resolve();
    });
    $form.submit();
    $form.remove();
    return deferred;
  };

  return Rsvp;

})(Backbone.Model);

App.Views.Home = (function(_super) {
  __extends(Home, _super);

  function Home() {
    return Home.__super__.constructor.apply(this, arguments);
  }

  Home.prototype.el = '#index-page';

  Home.prototype.events = {
    'click #rsvp': 'rsvp',
    'click .blanket': 'close'
  };

  Home.prototype.initialize = function(showRsvp) {
    if (showRsvp == null) {
      showRsvp = false;
    }
    this.rsvpModal = new App.Views.RsvpModal();
    this.listenTo(this.rsvpModal, 'close', function() {
      return this.close();
    });
    this.$blanket = this.$('.blanket');
    if (showRsvp) {
      this.disableScroll();
      return this.rsvpModal.$('input').first().focus();
    }
  };

  Home.prototype.rsvp = function(evt) {
    evt.preventDefault();
    return this.showRsvp();
  };

  Home.prototype.showRsvp = function() {
    this.$blanket.fadeIn((function(_this) {
      return function() {
        _this.$blanket.animateHearts(3, 2000, 2, 40, 300);
        return setTimeout(function() {
          return _this.rsvpModal.slideUp(_this.$blanket, 1000);
        }, 600);
      };
    })(this));
    return this.disableScroll();
  };

  Home.prototype.close = function() {
    this.$blanket.fadeOut();
    return this.enableScroll();
  };

  Home.prototype.enableScroll = function() {
    return $('body').removeClass('no-scroll');
  };

  Home.prototype.disableScroll = function() {
    return $('body').addClass('no-scroll');
  };

  return Home;

})(Backbone.View);

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

personSection = _.template("<div class=\"guest-group\">\n    <h3>Guest #<%= num %></h3>\n    <div class=\"form-group form-group-lg has-feedback\">\n        <label for=\"person-name-<%= num %>\">Guest Name</label>\n        <input type=\"text\" class=\"form-control person-name\" id=\"person-name-<%= num %>\" required=\"required\" minlength=1 name=\"guestName-<%= num %>\">\n        <span class=\"glyphicon glyphicon-ok form-control-feedback\"> </span> \n        <span class=\"glyphicon glyphicon-remove form-control-feedback\"> </span> \n    </div>\n    <div class=\"form-group attendance-group\">\n        <div class=\"radio input-lg\">\n            <label>\n                <input type=\"radio\" class=\"attendance attendance-yes\" name=\"guestAttendance-<%= num %>\" value=\"yes\" required=\"required\">\n                <span>Will be attending</span>\n            </label>\n        </div>\n        <div class=\"radio input-lg\">\n            <label>\n                <input type=\"radio\" class=\"attendance attendance-no\" name=\"guestAttendance-<%= num %>\" value=\"no\" required=\"required\">\n                <span>Will not be attending</span>\n            </label>\n        </div>\n        <div class=\"form-group form-group-lg meal-group\">\n            <label for=\"entree-<%= num %>\">Entree</label>\n            <select id=\"entree-<%= num %>\" name=\"guestMeal-<%= num %>\" class=\"form-control\">\n                <option value=\"beef\">Beef short rib</option>\n                <option value=\"chicken\">Chicken piccata</option>\n                <option value=\"veggie\">Vegetarian</option>\n            </select>\n        </div>\n    </div>\n</div>");

App.Views.RsvpModal = (function(_super) {
  __extends(RsvpModal, _super);

  function RsvpModal() {
    return RsvpModal.__super__.constructor.apply(this, arguments);
  }

  RsvpModal.prototype.el = '#rsvp-modal';

  RsvpModal.prototype.events = {
    'click .close': 'fadeOut',
    'click': 'outerClick',
    'click .modal-dialog': 'innerClick',
    'click #update-guest': 'updateGuests',
    'input .person-name': 'updateName',
    'change .attendance': 'handleAttendance',
    'submit .rsvp-form': 'handleSubmit'
  };

  RsvpModal.prototype.clickedInside = false;

  RsvpModal.prototype.showingGuests = false;

  RsvpModal.prototype.saving = false;

  RsvpModal.prototype.initialize = function() {
    var _this;
    window.modal = this;
    this.$guestSection = this.$('.guest-section');
    this.$form = this.$('.rsvp-form');
    _this = this;
    return this.$form.validate({
      errorPlacement: function() {},
      submitHandler: (function(_this) {
        return function(form) {
          return _this.ajaxSubmit();
        };
      })(this),
      showErrors: function(errorMap, errorList) {
        this.defaultShowErrors();
        _this.floatErrors();
        return _this.enableIfReady(errorList);
      }
    });
  };

  RsvpModal.prototype.floatErrors = function() {
    var $inputs;
    $inputs = this.$('.form-group');
    $inputs.removeClass('has-success').removeClass('has-error');
    $inputs.has('.error').addClass('has-error');
    return $inputs.has('.valid').addClass('has-success');
  };

  RsvpModal.prototype.enableIfReady = function(errorList) {
    if (this.showingGuests && errorList.length === 0) {
      return this.$('#rsvp-submit').removeAttr('disabled');
    } else {
      return this.$('#rsvp-submit').attr('disabled', 'disabled');
    }
  };

  RsvpModal.prototype.show = function() {
    return this.$el.show();
  };

  RsvpModal.prototype.hide = function() {
    this.$el.hide();
    return this.afterClose();
  };

  RsvpModal.prototype.afterClose = function() {
    this.saving = false;
    return this.trigger('close');
  };

  RsvpModal.prototype.slideUp = function($againstEl, duration) {
    if (duration == null) {
      duration = 1000;
    }
    this.$('.success-message').hide();
    this.$('.saving-message').hide();
    this.$('.rsvp-form').show();
    return this.$el.css({
      top: $againstEl.height()
    }).show().animate({
      top: 0
    }, {
      duration: duration,
      complete: (function(_this) {
        return function() {
          return _this.$('input').first().focus();
        };
      })(this)
    });
  };

  RsvpModal.prototype.fadeOut = function() {
    this.$el.fadeOut();
    return this.afterClose();
  };

  RsvpModal.prototype.innerClick = function() {
    return this.clickedInside = true;
  };

  RsvpModal.prototype.outerClick = function() {
    if (!this.clickedInside) {
      this.fadeOut();
    }
    this.clickedInside = false;
    return true;
  };

  RsvpModal.prototype.handleAttendance = function(evt) {
    var $group, $target;
    $target = $(evt.target);
    $group = $target.parentsUntil('.guest-section').last();
    if ($group.find('.attendance-no').prop('checked')) {
      return $group.find('.meal-group').slideUp();
    } else {
      return $group.find('.meal-group').slideDown();
    }
  };

  RsvpModal.prototype.handleSubmit = function(evt) {
    return evt.preventDefault();
  };

  RsvpModal.prototype.ajaxSubmit = function(form) {
    var deferreds, formData, groupData, guest, guestData, input, key, keyParts, minimumWait, model, models, name, num, val, _i, _len;
    formData = this.$form.serializeArray();
    groupData = {
      serializedForm: this.$form.serialize()
    };
    guestData = {};
    models = [];
    for (_i = 0, _len = formData.length; _i < _len; _i++) {
      input = formData[_i];
      key = input.name;
      val = input.value;
      keyParts = key.split('-');
      name = keyParts[0];
      num = keyParts[1];
      if (num) {
        guestData[num] || (guestData[num] = {});
        guestData[num][name] = val;
      } else {
        groupData[key] = val;
      }
    }
    deferreds = (function() {
      var _results;
      _results = [];
      for (num in guestData) {
        guest = guestData[num];
        model = new App.Models.Rsvp();
        model.mapAndSet(_.extend(guest, groupData));
        _results.push(model.save());
      }
      return _results;
    })();
    minimumWait = $.Deferred();
    window.setTimeout(function() {
      return minimumWait.resolve();
    }, 2000);
    deferreds.push(minimumWait);
    $.when.apply($, deferreds).done((function(_this) {
      return function() {
        return _this.showSuccess();
      };
    })(this));
    this.showSaving();
    return this.animateSaving();
  };

  RsvpModal.prototype.updateGuests = function() {
    var guestNum, guestsHtml, numGuests, startingNum, _i;
    this.$guestSection.css({
      opacity: 0,
      display: 'none'
    });
    numGuests = Number(this.$el.find('#party-size').val());
    if (numGuests === NaN || numGuests < 1) {
      return;
    }
    guestsHtml = "";
    startingNum = 1;
    for (guestNum = _i = startingNum; startingNum <= numGuests ? _i <= numGuests : _i >= numGuests; guestNum = startingNum <= numGuests ? ++_i : --_i) {
      guestsHtml += personSection({
        num: guestNum
      });
    }
    return this.$guestSection.html(guestsHtml).slideDown(1000).animate({
      opacity: 1
    }, {
      complete: (function(_this) {
        return function() {
          _this.showingGuests = true;
          return _this.$('.modal-content').animate({
            scrollTop: "" + (_this.$guestSection.position().top) + "px"
          });
        };
      })(this)
    });
  };

  RsvpModal.prototype.updateName = function(evt) {
    var $group, $target, name;
    $target = $(evt.target);
    $group = $target.parentsUntil('.guest-section').last();
    name = $target.val();
    return $group.find('h3').text(name);
  };

  RsvpModal.prototype.animateSaving = function() {
    var hearts, index;
    hearts = this.$('.save-heart');
    index = -1;
    return this.savingInterval = window.setInterval((function(_this) {
      return function() {
        if (index >= 0) {
          $(hearts[index]).removeClass('active');
        }
        index += 1;
        if (index > (hearts.length - 1)) {
          index = 0;
        }
        $(hearts[index]).addClass('active');
        if (!_this.saving) {
          return window.clearInterval(_this.savingInterval);
        }
      };
    })(this), 250);
  };

  RsvpModal.prototype.showSaving = function() {
    this.$form.slideUp();
    this.$('.saving-message').show();
    this.saving = true;
    return this.animateSaving();
  };

  RsvpModal.prototype.showSuccess = function() {
    this.$form.slideUp();
    this.saving = false;
    this.$('.saving-message').hide();
    return this.$('.success-message').show();
  };

  return RsvpModal;

})(Backbone.View);

App.Views.StoryHeader = (function(_super) {
  __extends(StoryHeader, _super);

  function StoryHeader() {
    return StoryHeader.__super__.constructor.apply(this, arguments);
  }

  StoryHeader.prototype.el = '#story-page .top-part';

  StoryHeader.prototype.backgroundImages = ['/images/shadow_1_wide.jpg'];

  StoryHeader.prototype.height = 300;

  StoryHeader.prototype.initialize = function() {
    return this.$layers = this.$('.heart-bg');
  };

  StoryHeader.prototype.changeBG = function() {
    var newImage;
    newImage = this.backgroundImages.pop();
    return this.$el.css({
      "background-image": "url(" + newImage + ")"
    });
  };

  StoryHeader.prototype.animateHearts = function() {
    var $layer, count, delay, layer, _i, _len, _ref, _results;
    if (this.animating) {
      return;
    }
    this.animating = true;
    delay = 0;
    count = this.$layers.length;
    _ref = this.$layers;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      layer = _ref[_i];
      $layer = $(layer);
      this.animateLayer($layer, delay);
      _results.push(delay += 300);
    }
    return _results;
  };

  StoryHeader.prototype.animateLayer = function($layer, delay) {
    var duration, height;
    height = this.height + 100;
    duration = 2000 - delay;
    return setTimeout((function(_this) {
      return function() {
        return $layer.animate({
          "top": "-" + height + "%"
        }, {
          duration: duration,
          easing: 'linear',
          complete: function() {
            var index;
            $layer.css({
              "top": "100%"
            });
            if (index = length - 1) {
              return _this.animating = false;
            }
          }
        });
      };
    })(this), delay);
  };

  return StoryHeader;

})(Backbone.View);

App.Views.Where = (function(_super) {
  __extends(Where, _super);

  function Where() {
    return Where.__super__.constructor.apply(this, arguments);
  }

  Where.prototype.el = '#where-page';

  Where.prototype.apiKey = 'AIzaSyA4kjM9Ys7Yott7dO_ESqewl04gppkUlm8';

  Where.prototype.mode = 'driving';

  Where.prototype.events = {
    'change .direction-choices': 'directionChange',
    'click .direction-mode button': 'modeChange'
  };

  Where.prototype.initialize = function() {
    this.$from = this.$('#from-picker');
    this.$to = this.$('#to-picker');
    this.$iframe = this.$('#map-embed');
    this.$link = this.$('#map-link');
    this.$modeButtons = this.$('.direction-mode .btn');
    this.$("button[data-mode='" + this.mode + "']").addClass('active');
    this.$to.find("option[value='Garden+Court+Hotel,+Cowper+Street,+Palo+Alto,+CA,+United+States']").attr("selected", true);
    return this.$from.find("option[value='Church+of+the+Nativity,+Oak+Grove+Avenue,+Menlo+Park,+CA,+United+States']").attr("selected", true);
  };

  Where.prototype.modeChange = function(evt) {
    var $target;
    $target = $(evt.target);
    this.$modeButtons.removeClass('active');
    $target.addClass('active');
    if (this.mode !== $target.data('mode')) {
      this.mode = $target.data('mode');
      return this.directionChange();
    }
  };

  Where.prototype.directionChange = function() {
    this.$iframe.attr('src', this.embedUrl());
    return this.$link.attr('href', this.linkUrl());
  };

  Where.prototype.getDirections = function() {
    return {
      origin: this.$from.val(),
      destination: this.$to.val()
    };
  };

  Where.prototype.embedUrl = function() {
    var params;
    params = $.extend(this.getDirections(), {
      mode: this.mode,
      key: this.apiKey
    });
    return "https://www.google.com/maps/embed/v1/directions?" + (this.paramString(params));
  };

  Where.prototype.linkUrl = function() {
    var directions;
    directions = this.getDirections();
    return "https://www.google.com/maps/dir/" + directions.origin + "/" + directions.destination;
  };

  Where.prototype.paramString = function(params) {
    var key, paramArr, val;
    paramArr = (function() {
      var _results;
      _results = [];
      for (key in params) {
        val = params[key];
        _results.push("" + key + "=" + val);
      }
      return _results;
    })();
    return paramArr.join("&");
  };

  return Where;

})(Backbone.View);
