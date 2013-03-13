(function() {
  var Controller, List, Model, Spine,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __slice = Array.prototype.slice;

  Spine = this.Spine || require('spine');

  Controller = (function(_super) {

    __extends(Controller, _super);

    function Controller(opts) {
      var _node,
        _this = this;
      if (opts == null) opts = {};
      Controller.__super__.constructor.apply(this, arguments);
      _node = null;
      this.node = function() {
        if (!_node) {
          _node = new Exo.Node(opts);
          _node.controller = this;
        }
        return _node;
      };
      this.nodeId = function() {
        return this.node().nodeId();
      };
      this.setId = function(id) {
        return this.node.setId(id);
      };
      this.setMode = function(mode) {
        return this.node().setMode(mode);
      };
      this.activate = function() {
        return this.node().activate();
      };
      this.deactivate = function() {
        return this.node().deactivate();
      };
      this.toggle = function() {
        return this.node().toggle();
      };
      this.node().beforeActivate = function() {
        var _ref;
        _this.trigger('beforeActivate', _this);
        return (_ref = _this.beforeActivate) != null ? _ref.call(_this) : void 0;
      };
      this.node().doActivate = function() {
        return _this.doActivate();
      };
      this.node().beforeDeactivate = function() {
        var _ref;
        _this.trigger('beforeDeactivate', _this);
        return (_ref = _this.beforeDeactivate) != null ? _ref.call(_this) : void 0;
      };
      this.node().doDeactivate = function() {
        return _this.doDeactivate();
      };
      this.addChild = function(controller) {
        return this.node().addChild(controller.node());
      };
      this.children = function() {
        return this.node().children().map(function(node) {
          return node.controller;
        });
      };
      this.parent = function() {
        var _ref;
        return (_ref = this.node().parent()) != null ? _ref.controller : void 0;
      };
      this.siblings = function() {
        return this.node().siblings().map(function(node) {
          return node.controller;
        });
      };
      this.activatedChildren = function() {
        return this.node().activatedChildren();
      };
      this.removeChild = function(controller) {
        return this.node().removeChild(controller.node());
      };
      this.isActivated = function() {
        return this.node().isActivated();
      };
      this.isTransitioning = function() {
        return this.node().isTransitioning();
      };
      this.isBusy = function() {
        return this.node().isBusy();
      };
    }

    Controller.prototype.prepare = function() {};

    Controller.prototype.doActivate = function() {
      return this.onActivated();
    };

    Controller.prototype.onActivated = function() {
      this.node().onActivated();
      return this.trigger('onActivated', this);
    };

    Controller.prototype.doDeactivate = function() {
      return this.onDeactivated();
    };

    Controller.prototype.onDeactivated = function() {
      this.node().onDeactivated();
      return this.trigger('onDeactivated', this);
    };

    return Controller;

  })(Spine.Controller);

  Exo.Spine || (Exo.Spine = {});

  Exo.Spine.Controller = Controller;

  List = (function(_super) {

    __extends(List, _super);

    function List(opts) {
      if (opts == null) opts = {};
      opts.initialState || (opts.initialState = Exo.Node.States.ACTIVATED);
      opts.mode || (opts.mode = Exo.Node.Modes.MULTI);
      List.__super__.constructor.call(this, opts);
    }

    List.prototype.templateFor = function(templates, item) {
      return templates[item.className];
    };

    List.prototype.controllerFor = function(controllers, item) {
      return controllers[item.className];
    };

    List.prototype.render = function(collection) {
      this.collection = collection;
      if (this.template || this.templates) {
        return this.renderTemplates(collection);
      } else if (this.controller || this.controllers) {
        return this.renderControllers(collection);
      }
    };

    List.prototype.renderTemplates = function(collection) {
      var el, html, item, templates, _i, _len, _results;
      templates = this.templates || {
        "default": this.template
      };
      _results = [];
      for (_i = 0, _len = collection.length; _i < _len; _i++) {
        item = collection[_i];
        html = (templates["default"] || templates[item.constructor.className]).call(this, item);
        el = $(html).appendTo(this.el);
        _results.push($(el).data('item', item));
      }
      return _results;
    };

    List.prototype.renderControllers = function(collection) {
      var child, controllers, i, item, _len;
      controllers = this.controllers || {
        "default": this.controller
      };
      this.deactivateAndKillOrphans(this.children(), collection);
      for (i = 0, _len = collection.length; i < _len; i++) {
        item = collection[i];
        child = this.getOrCreateChild(item, controllers[item.constructor.className] || controllers["default"]);
        child.listIndex = i;
        if (child.moveTo) child.moveTo(i);
        child.activate();
      }
      this.trigger('afterRender', this);
      if (this.debug) {
        return console.log("children before deactivate: " + (this.children().length));
      }
    };

    List.prototype.getOrCreateChild = function(item, controller) {
      var child;
      child = this.childById(item.constructor.className + item.id);
      if (!child) {
        child = new controller;
        child.id = item.constructor.className + item.id;
        this.addChild(child);
        child.prepareWithModel(item);
        this.append(child);
        $(child.el).data('item', item);
        if (this.debug) console.log("child was created: " + child.id);
      } else {
        if (this.debug) console.log("child was found: " + child.id);
      }
      return child;
    };

    List.prototype.deactivateAndKillOrphans = function(children, collection) {
      var orphan, orphans, _i, _len, _results,
        _this = this;
      orphans = children.filter(function(child) {
        var _ref;
        return _ref = child.id, __indexOf.call(collection.map(function(item) {
          return item.constructor.className + item.id;
        }), _ref) < 0;
      });
      _results = [];
      for (_i = 0, _len = orphans.length; _i < _len; _i++) {
        orphan = orphans[_i];
        if (this.debug) console.log("Deactivate: " + orphan.id);
        if (orphan.isActivated() && !orphan.isBusy()) {
          orphan.bind('onDeactivated', function(controller) {
            if (_this.debug) console.log("Remove child: " + controller.id);
            _this.removeChild(controller);
            return controller.release();
          });
        }
        _results.push(orphan.deactivate());
      }
      return _results;
    };

    List.prototype.click = function(e) {
      var item;
      if ($(e.currentTarget).item) {
        item = $(e.currentTarget).item();
      } else {
        item = $(e.currentTarget).data('item');
      }
      this.trigger('select', item, $(e.currentTarget));
      return true;
    };

    return List;

  })(Exo.Spine.Controller);

  if (typeof Exo !== "undefined" && Exo !== null) Exo.Spine || (Exo.Spine = {});

  if (typeof Exo !== "undefined" && Exo !== null) Exo.Spine.List = List;

  if (typeof module !== "undefined" && module !== null) module.exports = List;

  Spine = this.Spine || require('spine');

  Model = (function(_super) {

    __extends(Model, _super);

    function Model() {
      Model.__super__.constructor.apply(this, arguments);
    }

    Model.defaults = function(atts) {
      return this.defaultValues = atts;
    };

    Model.configure = function() {
      var attributes, name;
      name = arguments[0], attributes = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      attributes = attributes.concat(['created_at', 'updated_at']);
      return Model.__super__.constructor.configure.apply(this, [name].concat(__slice.call(attributes)));
    };

    Model.create = function(atts, options) {
      var attribute, _i, _len, _ref;
      if (atts == null) atts = {};
      if (options == null) options = {};
      if (this.defaultValues) {
        _ref = this.attributes;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          attribute = _ref[_i];
          if (!atts[attribute]) {
            if (this.defaultValues[attribute.toString()] || this.defaultValues[attribute.toString()] === 0) {
              atts[attribute.toString()] = this.defaultValues[attribute.toString()];
            }
          }
        }
      }
      return Model.__super__.constructor.create.call(this, atts, options);
    };

    Model.prototype.getClassName = function() {
      return this.constructor.className;
    };

    return Model;

  })(Spine.Model);

  if (typeof Exo !== "undefined" && Exo !== null) Exo.Spine || (Exo.Spine = {});

  if (typeof Exo !== "undefined" && Exo !== null) Exo.Spine.Model = Model;

  if (typeof module !== "undefined" && module !== null) module.exports = Model;

}).call(this);
