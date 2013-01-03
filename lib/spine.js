(function() {

  Exo.Spine = {};

}).call(this);
(function() {
  var Controller,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  Controller = (function(_super) {

    __extends(Controller, _super);

    Controller.Events = {
      ON_ACTIVATED: 'onActivated',
      ON_DEACTIVATED: 'onDeactivated',
      BEFORE_ACTIVATE: 'beforeActivate',
      BEFORE_DEACTIVATE: 'beforeDeactivate'
    };

    Controller.NodeClassFuncs = ['activate', 'deactivate', 'toggle', 'lineageIsBusy', 'onNodeActivated', 'onNodeDeactivated', 'processAction'];

    Controller.NodePrivilegedFuncs = ['sm', 'setParent', 'parent', 'removeChild', 'children', 'activatedChildren', 'childById', 'descendantById', 'siblings', 'isActivated', 'isTransitioning', 'isBusy', 'attemptTransition', 'activate', 'deactivate', 'toggle', 'setMode', 'mode', 'setOnActivatedAction', 'onActivatedAction', 'setOnDeactivatedAction', 'onDeactivatedAction', 'deactivateChildren'];

    Controller.NodePublicFuncs = ['beforeActivate', 'doActivate', 'beforeDeactivate', 'doDeactivate', 'onChildActivated', 'onChildDeactivated'];

    function Controller(opts) {
      var a, func, node, that, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
      if (opts == null) {
        opts = {};
      }
      node = new Exo.Node(opts);
      that = this;
      this.node = function() {
        return node;
      };
      _ref = Controller.NodeClassFuncs;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        func = _ref[_i];
        a = function(fn) {
          return Controller[fn] = function() {
            var modParams, params;
            params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
            if (params) {
              modParams = params.map(function(p) {
                if (p === node) {
                  return that;
                } else {
                  return p;
                }
              });
              return Exo.Node[fn].apply(Exo.Node, modParams);
            } else {
              return Exo.Node[fn]();
            }
          };
        };
        a(func);
      }
      _ref1 = Controller.NodePrivilegedFuncs;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        func = _ref1[_j];
        a = function(fn) {
          return that[fn] = function() {
            var params;
            params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
            return node[fn].apply(node, params);
          };
        };
        a(func);
      }
      _ref2 = Controller.NodePublicFuncs;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        func = _ref2[_k];
        a = function(fn) {
          return node[fn] = function() {
            var params;
            params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
            return that[fn].apply(that, params);
          };
        };
        a(func);
      }
      this.addChild = function(node) {
        node.setParent(this);
        this.children().push(node);
        return this.onChildAdded(node);
      };
      if (opts.initialState) {
        delete opts.initialState;
      }
      if (opts.mode) {
        delete opts.mode;
      }
      if (opts.children) {
        delete opts.children;
      }
      Controller.__super__.constructor.call(this, opts);
      this.prepare();
    }

    Controller.prototype.prepare = function() {};

    Controller.prototype.proxyBeforeActivate = function() {
      this.trigger(Controller.Events.BEFORE_ACTIVATE, this);
      return this.beforeActivate();
    };

    Controller.prototype.beforeActivate = function() {};

    Controller.prototype.doActivate = function() {};

    Controller.prototype.onActivated = function() {
      this.node().onActivated();
      return this.trigger(Controller.Events.ON_ACTIVATED, this);
    };

    Controller.prototype.proxyBeforeDeactivate = function() {
      this.trigger(Controller.Events.BEFORE_DEACTIVATE, this);
      return this.beforeDeactivate();
    };

    Controller.prototype.beforeDeactivate = function() {};

    Controller.prototype.doDeactivate = function() {};

    Controller.prototype.onDeactivated = function() {
      this.node().onDeactivated();
      return this.trigger(Controller.Events.ON_DEACTIVATED, this);
    };

    Controller.prototype.onChildAdded = function(child) {};

    Controller.prototype.onChildActivated = function(child) {};

    Controller.prototype.onChildDeactivated = function(child) {};

    return Controller;

  })(Spine.Controller);

  Exo.Spine.Controller = Controller;

}).call(this);
(function() {
  var List,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  List = (function(_super) {

    __extends(List, _super);

    /*
    		
    		TODO: 
    		* Add option to auto select any item on render.
    		* Allow the items to be Exo.Controller instances
    			* Allow each item to have it's own in/out transitions.
    			* Allow the entire list to have a single in/out transition.
    		* Allow the items to be simple rendered views.
    */


    function List(opts) {
      if (opts == null) {
        opts = {};
      }
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
      var child, controllers, i, item, _i, _len;
      controllers = this.controllers || {
        "default": this.controller
      };
      this.deactivateAndKillOrphans(this.children(), collection);
      for (i = _i = 0, _len = collection.length; _i < _len; i = ++_i) {
        item = collection[i];
        child = this.getOrCreateChild(item, controllers[item.constructor.className] || controllers["default"]);
        child.listIndex = i;
        if (child.moveTo) {
          child.moveTo(i);
        }
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
        if (this.debug) {
          console.log("child was created: " + child.id);
        }
      } else {
        if (this.debug) {
          console.log("child was found: " + child.id);
        }
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
        if (this.debug) {
          console.log("Deactivate: " + orphan.id);
        }
        if (orphan.isActivated() && !orphan.isBusy()) {
          orphan.bind('onDeactivated', function(controller) {
            if (_this.debug) {
              console.log("Remove child: " + controller.id);
            }
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

  Exo.Spine.List = List;

}).call(this);
(function() {
  var Model,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  Model = (function(_super) {

    __extends(Model, _super);

    function Model() {
      return Model.__super__.constructor.apply(this, arguments);
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
      _ref = this.attributes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attribute = _ref[_i];
        if (!atts[attribute]) {
          if (this.defaultValues[attribute.toString()] || this.defaultValues[attribute.toString()] === 0) {
            atts[attribute.toString()] = this.defaultValues[attribute.toString()];
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

  Exo.Spine.Model = Model;

}).call(this);
