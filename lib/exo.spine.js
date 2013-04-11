(function() {
  var CSSTransitioner, Controller, DOMInflator, DOMOrganizer, List, Model, Spine, _base, _base2, _base3, _base4, _base5, _base6,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Spine = this.Spine || require('spine');

  Controller = (function(_super) {

    __extends(Controller, _super);

    function Controller(opts) {
      var _this = this;
      if (opts == null) opts = {};
      this._nodeOpts = opts;
      this._node = null;
      this.filters = this.constructor.filters || {};
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
      this.node().onChildActivated = function(node) {
        _this.trigger('onChildActivated', node.controller);
        return typeof _this.onChildActivated === "function" ? _this.onChildActivated(node.controller) : void 0;
      };
      this.node().onChildDeactivated = function(node) {
        _this.trigger('onChildDeactivated', node.controller);
        return typeof _this.onChildDeactivated === "function" ? _this.onChildDeactivated(node.controller) : void 0;
      };
      if (opts.initialState) delete opts.initialState;
      if (opts.mode) delete opts.mode;
      if (opts.children) delete opts.children;
      Controller.__super__.constructor.call(this, opts);
      this.callWithFilters('prepare');
    }

    Controller.prototype.callWithFilters = function() {
      var args, methName;
      methName = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      this.callFilter("before_" + methName);
      this[methName].apply(this, args);
      return this.callFilter("after_" + methName);
    };

    Controller.prototype.callFilter = function(methName) {
      var funcName, _i, _len, _ref, _results;
      if (!this.filters[methName]) return;
      _ref = this.filters[methName];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        funcName = _ref[_i];
        _results.push(this[funcName].call(this));
      }
      return _results;
    };

    Controller.prototype.node = function() {
      if (!this._node) {
        this._node = new Exo.Node(this._nodeOpts);
        this._node.controller = this;
      }
      return this._node;
    };

    Controller.prototype.nodeId = function() {
      return this.node().nodeId();
    };

    Controller.prototype.setNodeId = function(id) {
      return this.node().setNodeId(id);
    };

    Controller.prototype.setMode = function(mode) {
      return this.node().setMode(mode);
    };

    Controller.prototype.activate = function() {
      return this.node().activate();
    };

    Controller.prototype.deactivate = function() {
      return this.node().deactivate();
    };

    Controller.prototype.toggle = function() {
      return this.node().toggle();
    };

    Controller.prototype.deactivateChildren = function() {
      return this.node().deactivateChildren();
    };

    Controller.prototype.addChild = function(controller) {
      return this.node().addChild(controller != null ? controller.node() : void 0);
    };

    Controller.prototype.children = function() {
      return this.node().children().map(function(node) {
        return node.controller;
      });
    };

    Controller.prototype.parent = function() {
      var _ref;
      return (_ref = this.node().parent()) != null ? _ref.controller : void 0;
    };

    Controller.prototype.childById = function(id) {
      var _ref;
      return (_ref = this.node().childById(id)) != null ? _ref.controller : void 0;
    };

    Controller.prototype.descendantById = function(id) {
      var _ref;
      return (_ref = this.node().descendantById(id)) != null ? _ref.controller : void 0;
    };

    Controller.prototype.siblings = function() {
      return this.node().siblings().map(function(node) {
        return node.controller;
      });
    };

    Controller.prototype.activatedChildren = function() {
      return this.node().activatedChildren();
    };

    Controller.prototype.removeChild = function(controller) {
      return this.node().removeChild(controller.node());
    };

    Controller.prototype.setDefaultChild = function(controller) {
      return this.node().setDefaultChild(controller.node());
    };

    Controller.prototype.defaultChild = function() {
      return this.node().defaultChild();
    };

    Controller.prototype.isActivated = function() {
      return this.node().isActivated();
    };

    Controller.prototype.isTransitioning = function() {
      return this.node().isTransitioning();
    };

    Controller.prototype.isBusy = function() {
      return this.node().isBusy();
    };

    Controller.prototype.haveBusyChildren = function() {
      return this.node().haveBusyChildren();
    };

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

    List.prototype.render = function(collection, opts) {
      if (opts == null) opts = {};
      this.collection = collection;
      if (this.template || this.templates) {
        return this.renderTemplates(collection);
      } else if (this.controller || this.controllers) {
        return this.renderControllers(collection, opts);
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

    List.prototype.renderControllers = function(collection, opts) {
      var child, controllers, i, item, _len;
      controllers = this.controllers || {
        "default": this.controller
      };
      this.deactivateAndKillOrphans(this.children(), collection);
      for (i = 0, _len = collection.length; i < _len; i++) {
        item = collection[i];
        child = this.getOrCreateChild(item, controllers[item.constructor.className] || controllers["default"], opts);
        child.listIndex = i;
        if (child.moveTo) child.moveTo(i);
        child.activate();
      }
      return this.trigger('afterRender', this);
    };

    List.prototype.getOrCreateChild = function(item, controller, opts) {
      var child;
      child = this.childById(item.constructor.className + item.cid);
      if (!child) {
        child = new controller(opts);
        this.addChild(child);
        child.setNodeId(item.constructor.className + item.cid);
        child.prepareWithModel(item);
        this.append(child);
        $(child.el).data('item', item);
      }
      return child;
    };

    List.prototype.deactivateAndKillOrphans = function(children, collection) {
      var orphan, orphans, _i, _len, _results,
        _this = this;
      orphans = children.filter(function(child) {
        var _ref;
        return _ref = child.nodeId(), __indexOf.call(collection.map(function(item) {
          return item.constructor.className + item.cid;
        }), _ref) < 0;
      });
      _results = [];
      for (_i = 0, _len = orphans.length; _i < _len; _i++) {
        orphan = orphans[_i];
        if (orphan.isActivated() && !orphan.isBusy()) {
          orphan.bind('onDeactivated', function(controller) {
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

  CSSTransitioner = {
    cssTransitionEndEvents: 'transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd',
    cssActivateClass: 'active',
    cssDeactivateClass: void 0,
    cssTransitionDelay: 10,
    doActivate: function() {
      if (this.cssDeactivateClass) this.el.removeClass(this.cssDeactivateClass);
      return this.cssStartTransition('addClass', this.cssActivateClass, this.onActivated);
    },
    doDeactivate: function() {
      if (this.cssDeactivateClass) {
        return this.cssStartTransition('addClass', this.cssDeactivateClass, this.onDeactivated);
      } else {
        return this.cssStartTransition('removeClass', this.cssActivateClass, this.onDeactivated);
      }
    },
    cssListen: function(callback, className) {
      var _this = this;
      return $(this.el).bind(this.cssTransitionEndEvents, function() {
        callback.call(_this);
        return _this.el.off(_this.cssTransitionEndEvents);
      });
    },
    cssStartTransition: function(mutatorFunc, className, callback) {
      var _this = this;
      this.cssListen(callback, className);
      return this.delay(function() {
        return _this.el[mutatorFunc].call(_this.el, className);
      }, this.cssTransitionDelay);
    }
  };

  if (typeof Exo !== "undefined" && Exo !== null) Exo.Spine || (Exo.Spine = {});

  if (typeof Exo !== "undefined" && Exo !== null) {
    (_base = Exo.Spine).Modules || (_base.Modules = {});
  }

  if (typeof Exo !== "undefined" && Exo !== null) {
    (_base2 = Exo.Spine.Modules).CSSTransitioner || (_base2.CSSTransitioner = CSSTransitioner);
  }

  if (typeof module !== "undefined" && module !== null) {
    module.exports = CSSTransitioner;
  }

  DOMInflator = {
    included: function() {
      var _base3;
      return ((_base3 = (this.filters || (this.filters = {})))['before_prepare'] || (_base3['before_prepare'] = [])).push('inflateFromDOM');
    },
    inflateFromDOM: function() {
      var classNames, collection, dashifiedClassNames, elements, selectors,
        _this = this;
      console.log('inflateFromDOM!');
      if (typeof this['deactivateAndKillOrphans'] !== 'function') return;
      classNames = [];
      if (this.modelClass) {
        classNames = [this.modelClass.className];
      } else if (this.modelClasses) {
        classNames = this.modelClasses.map(function(modelClass) {
          return modelClass.className;
        });
      }
      if (!(classNames.length > 0)) throw "No Model Classes specified!";
      dashifiedClassNames = classNames.map(function(className) {
        return _this.dashify(className);
      });
      selectors = dashifiedClassNames.map(function(className) {
        return "[data-" + className + "-id]";
      });
      elements = this.el.find.call(this.el, selectors.join(', ')).filter(function(i) {
        var className, _i, _len;
        for (_i = 0, _len = dashifiedClassNames.length; _i < _len; _i++) {
          className = dashifiedClassNames[_i];
          if ($(this).data("" + className + "-id")) return true;
        }
      });
      collection = elements.map(function(index, el) {
        var className, downcaseName, id, _i, _len;
        id = void 0;
        for (_i = 0, _len = classNames.length; _i < _len; _i++) {
          className = classNames[_i];
          downcaseName = className[0].toLowerCase() + className.slice(1);
          if (id = $(el).data("" + downcaseName + "Id")) break;
        }
        if (!id) throw "Invalid DOM";
        return _this.inflateModel($(el), className);
      });
      if (this.template || this.templates) {
        return this.tagElements(collection);
      } else if (this.controller || this.controllers) {
        return this.createControllers(collection);
      }
    },
    /*
      Tag existing DOM elements that should be represented by 
      rendered templates.
    */
    tagElements: function(collection) {
      var el, model, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = collection.length; _i < _len; _i++) {
        model = collection[_i];
        el = this.el.find("[data-" + (this.dashify(model.constructor.className)) + "-id]");
        _results.push(this.tagElement(el, model));
      }
      return _results;
    },
    /*
      Create controllers for existing DOM elements and add them 
      to the Exo hierarchy, tag them with corresponding models.
    */
    createControllers: function(collection) {
      var child, controllerClass, controllers, el, model, _i, _len, _results;
      if (!(this.controller || this.controllers)) {
        throw 'No controllers specified!';
      }
      controllers = this.controllers || {
        "default": this.controller
      };
      _results = [];
      for (_i = 0, _len = collection.length; _i < _len; _i++) {
        model = collection[_i];
        controllerClass = controllers['default'] || controllers[model.constructor.className];
        el = this.el.find("[data-" + (this.dashify(model.constructor.className)) + "-id]");
        this.tagElement(el, model);
        child = new controllerClass({
          el: el,
          model: model,
          initialState: Exo.Node.States.ACTIVATED
        });
        _results.push(this.addChild(child));
      }
      return _results;
    },
    tagElement: function(el, model) {
      return $(el).data('item', model);
    },
    inflateModel: function(el, modelClassName) {
      var attr, attributes, className, id, model, modelClass, targetEl, _i, _len, _ref;
      if (this.modelClass) {
        modelClass = this.modelClass;
      } else if (this.modelClasses) {
        modelClass = this.modelClasses.filter(function(item) {
          return item.className === modelClassName;
        })[0];
      } else {
        throw "No Model Class specified!";
      }
      if (!modelClass) return;
      className = this.dashify(modelClass.className);
      id = el.attr("data-" + className + "-id");
      attributes = {
        id: id
      };
      _ref = modelClass.attributes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attr = _ref[_i];
        if (targetEl = el.find("[data-" + className + "-attribute='" + attr + "']")[0]) {
          attributes[attr] = $(targetEl).text();
        }
      }
      model = new modelClass(attributes);
      model.constructor.records[model.id] = model;
      return model;
    },
    /*
      Take a CamelCase model class-name and return
      a dashified version: camel-case.
      @param [String] string
    */
    dashify: function(name) {
      var first;
      first = true;
      return name.replace(/[A-Z]/g, function(match) {
        if (!first) {
          return "-" + (match.toLowerCase());
        } else {
          first = false;
          return match.toLowerCase();
        }
      });
    }
  };

  if (typeof Exo !== "undefined" && Exo !== null) Exo.Spine || (Exo.Spine = {});

  if (typeof Exo !== "undefined" && Exo !== null) {
    (_base3 = Exo.Spine).Modules || (_base3.Modules = {});
  }

  if (typeof Exo !== "undefined" && Exo !== null) {
    (_base4 = Exo.Spine.Modules).DOMInflator || (_base4.DOMInflator = DOMInflator);
  }

  if (typeof module !== "undefined" && module !== null) {
    module.exports = DOMInflator;
  }

  DOMOrganizer = {
    reorganizeDOM: function() {
      var child, el, getElAt, index, prev, _len, _ref, _results,
        _this = this;
      if (this.children().filter(function(child) {
        return child.isDeactivating();
      }).length !== 0) {
        return;
      }
      getElAt = function(index) {
        var child, model;
        model = _this.collection[index];
        child = _this.childById("" + model.constructor.className + model.cid);
        return child.el;
      };
      _ref = this.collection;
      _results = [];
      for (index = 0, _len = _ref.length; index < _len; index++) {
        child = _ref[index];
        if (el = getElAt(index)) {
          if (index === 0) {
            _results.push($(this.el).prepend(el));
          } else {
            prev = getElAt(index - 1);
            _results.push(el.insertAfter(prev));
          }
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    }
  };

  if (typeof Exo !== "undefined" && Exo !== null) Exo.Spine || (Exo.Spine = {});

  if (typeof Exo !== "undefined" && Exo !== null) {
    (_base5 = Exo.Spine).Modules || (_base5.Modules = {});
  }

  if (typeof Exo !== "undefined" && Exo !== null) {
    (_base6 = Exo.Spine.Modules).DOMOrganizer || (_base6.DOMOrganizer = DOMOrganizer);
  }

  if (typeof module !== "undefined" && module !== null) {
    module.exports = DOMOrganizer;
  }

}).call(this);
