(function() {
  var Exo, Node, StateMachine;

  Exo = this.Exo = {};

  Exo.VERSION = '0.1.2';

  if (typeof module !== "undefined" && module !== null) module.exports = Exo;

  StateMachine = (function() {

    StateMachine.E_DUPLICATE_STATE = "E_DUPLICATE_STATE: States must be distinct";

    StateMachine.E_DUPLICATE_TRANSITION = "E_DUPLICATE_TRANSITION: Transitions must be distinct";

    StateMachine.E_UNDEFINED_STATE = "E_UNDEFINED_STATE: All states used in transitions must be defined in the states array";

    function StateMachine(opts) {
      var currentState, currentTransition, initialState, states, transitions, validate;
      if (opts == null) opts = {};
      states = opts.states || [];
      transitions = opts.transitions || [];
      (validate = function() {
        var sCheck, tCheck, tStates, transition, unique;
        unique = function(a) {
          var key, output, value, _ref, _results;
          output = {};
          for (key = 0, _ref = a.length; 0 <= _ref ? key < _ref : key > _ref; 0 <= _ref ? key++ : key--) {
            output[a[key]] = a[key];
          }
          _results = [];
          for (key in output) {
            value = output[key];
            _results.push(value);
          }
          return _results;
        };
        if (states.length !== unique(states).length) {
          throw StateMachine.E_DUPLICATE_STATE;
        }
        tCheck = [];
        sCheck = [];
        for (transition in transitions) {
          tStates = transitions[transition];
          tCheck.push("" + tStates.from + "->" + tStates.to);
          sCheck.push(tStates.to);
          sCheck.push(tStates.from);
        }
        if (unique(sCheck).length > states.length) {
          throw StateMachine.E_UNDEFINED_STATE;
        }
        if (tCheck.length !== unique(tCheck).length) {
          throw StateMachine.E_DUPLICATE_TRANSITION;
        }
      })();
      currentState = initialState = opts.initialState || null;
      currentTransition = null;
      this.attemptTransition = function(transitionName) {
        if (!this.isTransitioning() && this.transitionIsPossible(transitionName)) {
          currentTransition = transitions[transitionName];
          this.performTransition(transitionName);
          return true;
        } else {
          return false;
        }
      };
      this.isTransitioning = function() {
        return currentTransition !== null;
      };
      this.transitionIsPossible = function(transitionName) {
        var transition;
        if (transition = transitions[transitionName]) {
          return currentState !== transition.to && currentState === transition.from;
        } else {
          return false;
        }
      };
      this.onTransitionComplete = function() {
        if (currentTransition) {
          currentState = currentTransition.to;
          currentTransition = null;
          return true;
        } else {
          return false;
        }
      };
      this.states = function() {
        return states;
      };
      this.transitions = function() {
        return transitions;
      };
      this.currentState = function() {
        return currentState;
      };
      this.initialState = function() {
        return initialState;
      };
    }

    StateMachine.prototype.performTransition = function(transitionName) {};

    return StateMachine;

  })();

  Exo.StateMachine = StateMachine;

  /* 
  Overview of a node
  
  The Class Methods are used internally by the framework.
  */

  Node = (function() {

    Node.__currentId = 0;

    Node.Transitions = {
      ACTIVATE: 'activate',
      DEACTIVATE: 'deactivate'
    };

    Node.States = {
      ACTIVATED: 'activated',
      DEACTIVATED: 'deactivated'
    };

    Node.Modes = {
      EXCLUSIVE: 'exclusive',
      MULTI: 'multi'
    };

    /* 
    Generate the next unique node ID string.
    */

    Node.nextId = function() {
      Node.__currentId = Node.__currentId + 1;
      return Node.__currentId;
    };

    /* 
    Attempt to activate a node instance.
    @param [Node] node
    */

    Node.activate = function(node) {
      var parent, sibling;
      if (this.lineageIsBusy(node) || node.isActivated()) return false;
      if (parent = node.parent()) {
        if (parent.isActivated()) {
          if (parent.mode() === Node.Modes.EXCLUSIVE) {
            if (sibling = parent.activatedChildren()[0]) {
              sibling.setOnDeactivatedAction({
                node: node,
                transition: Node.Transitions.ACTIVATE
              });
              return Node.deactivate(sibling);
            }
          }
        } else {
          if (!parent.childrenCanActivate()) return false;
          parent.setOnActivatedAction({
            node: node,
            transition: Node.Transitions.ACTIVATE
          });
          return Node.activate(parent);
        }
      }
      return node.attemptTransition(Node.Transitions.ACTIVATE);
    };

    /* 
    Attempt to deactivate a node instance.
    @param [Node] node
    */

    Node.deactivate = function(node) {
      var child, _i, _len, _ref;
      if (node.isActivated() && !this.lineageIsBusy(node)) {
        if (node.mode() === Node.Modes.EXCLUSIVE) {
          if (child = node.activatedChildren()[0]) {
            child.setOnDeactivatedAction({
              node: node,
              transition: Node.Transitions.DEACTIVATE
            });
            return Node.deactivate(child);
          }
        } else if (node.mode === Node.Modes.MULTI) {
          _ref = node.activatedChildren();
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            child = _ref[_i];
            Node.deactivate(child);
          }
        }
        node.attemptTransition(Node.Transitions.DEACTIVATE);
      }
      return false;
    };

    /* 
    Attempts to perform activation if the node is deactivated and vice versa.
    @param [Node] node
    */

    Node.toggle = function(node) {
      if (node.isActivated()) {
        return this.deactivate(node);
      } else {
        return this.activate(node);
      }
    };

    /* 
    Find out if the lineage of a node is busy. This will be true if a parent, sibling or child is currently transitioning.
    @param [Node] node
    */

    Node.lineageIsBusy = function(node) {
      var parent;
      if (parent = node.parent()) {
        if (parent.isBusy()) return true;
        while (parent = parent.parent()) {
          if (parent.isBusy()) return true;
        }
      }
      return false;
    };

    /* 
    Node instances call this function when done activating. If there is a pending action it will be executed.
    @param [Node] node
    */

    Node.onNodeActivated = function(node) {
      var action;
      if (node.parent()) node.parent().onChildActivated(node);
      if (action = node.onActivatedAction()) return this.processAction(action);
    };

    /* 
    Node instances call this function when done deactivating. If there is a pending action it will be executed.
    @param [Node] node
    */

    Node.onNodeDeactivated = function(node) {
      var action, _ref;
      if (node.parent()) node.parent().onChildDeactivated(node);
      if (action = node.onDeactivatedAction()) {
        return this.processAction(action);
      } else if ((_ref = node.parent()) != null ? _ref.defaultChild() : void 0) {
        return Node.activate(node.parent().defaultChild());
      }
    };

    /* 
    Process an action of activating or deactivating a node reference.
    @param [Object] action
    */

    Node.processAction = function(action) {
      if (action.transition === Node.Transitions.ACTIVATE) {
        return this.activate(action.node);
      } else if (action.transition === Node.Transitions.DEACTIVATE) {
        return this.deactivate(action.node);
      }
    };

    /* 
    Constructor
    @param [Object] options
    @option options [Array] children add children at instantiation.
    @option options [String] mode one of two possible operational modes: 'exclusive', 'multi'
    @option options [String] initialState 'deactivated' or 'activated' default is 'deactivated'.
    @option options [Boolean] childrenCanActivate If true, this node can be activated by it's children. Defaults to true.
    */

    function Node(opts) {
      var child, node, _i, _j, _len, _len2, _ref, _ref2;
      if (opts == null) opts = {};
      this._parent = null;
      this._childMap = {};
      this._defaultChild = null;
      this._nId = "exo#" + (Node.nextId());
      if (opts.children) {
        _ref = opts.children;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          node = _ref[_i];
          node.setParent(this);
          _ref2 = opts.children;
          for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
            child = _ref2[_j];
            this.addChild(child);
          }
        }
      }
      this._mode = opts.mode || (opts.mode = Node.Modes.EXCLUSIVE);
      this._initialState = opts.initialState || (opts.initialState = Node.States.DEACTIVATED);
      if (opts.childrenCanActivate === false) {
        this._childrenCanActivate = false;
      } else {
        this._childrenCanActivate = true;
      }
      this._onActivatedAction = null;
      this._onDeactivatedAction = null;
    }

    /* 
    Returns the id of the node. By default this is a generated unique String value.
    */

    Node.prototype.nodeId = function() {
      return this._nId;
    };

    /* 
    Manually set the node ID. Caution: If multiple children of a node are given the same ID only one instance will persist.
    */

    Node.prototype.setNodeId = function(nid) {
      var _ref;
      if ((_ref = this._parent) != null) {
        _ref.onChildIdUpdated(this._nId, nid, this);
      }
      return this._nId = nid;
    };

    /* 
    Returns the internal state-machine instance.
    */

    Node.prototype.sm = function() {
      var _this = this;
      if (this._smRef) return this._smRef;
      this._smRef = new Exo.StateMachine({
        states: [Node.States.DEACTIVATED, Node.States.ACTIVATED],
        initialState: this._initialState,
        transitions: {
          activate: {
            from: Node.States.DEACTIVATED,
            to: Node.States.ACTIVATED
          },
          deactivate: {
            from: Node.States.ACTIVATED,
            to: Node.States.DEACTIVATED
          }
        }
      });
      this._smRef.performTransition = function(t) {
        if (t === Node.Transitions.ACTIVATE) {
          _this.beforeActivate();
          return _this.doActivate();
        } else if (t === Node.Transitions.DEACTIVATE) {
          _this.beforeDeactivate();
          return _this.doDeactivate();
        }
      };
      return this._smRef;
    };

    /* 
    Children call this function on their parent when their node ID has been manually changed.
    */

    Node.prototype.onChildIdUpdated = function(oldId, newId, child) {
      delete this._childMap[oldId];
      return this._childMap[newId] = child;
    };

    /* 
    Used by the framework to chain sequences of Node activation. 
    For instance, when activating a sibling of an already activated node this function will be called on the parent
    with a reference to the sibling.
    */

    Node.prototype.setOnActivatedAction = function(action) {
      return this._onActivatedAction = action;
    };

    /* 
    A getter to read the onActivatedAction value.
    */

    Node.prototype.onActivatedAction = function() {
      return this._onActivatedAction;
    };

    /* 
    Used by the framework to chain sequences of Node deactivation.
    */

    Node.prototype.setOnDeactivatedAction = function(action) {
      return this._onDeactivatedAction = action;
    };

    /* 
    Get the onDeactivatedAction value.
    */

    Node.prototype.onDeactivatedAction = function() {
      return this._onDeactivatedAction;
    };

    /* 
    Get the childrenCanActivate setting.
    */

    Node.prototype.childrenCanActivate = function() {
      return this._childrenCanActivate;
    };

    /* 
    Set the mode.
    @param [String] mode
    */

    Node.prototype.setMode = function(m) {
      return this._mode = m;
    };

    /* 
    Get the mode.
    */

    Node.prototype.mode = function() {
      return this._mode;
    };

    /* 
    Set the parent Node. This is called automatically when using node.addChild
    @param [Node] node
    */

    Node.prototype.setParent = function(node) {
      return this._parent = node;
    };

    /* 
    Get the parent Node.
    */

    Node.prototype.parent = function() {
      return this._parent;
    };

    /* 
    Add a Node instance as a child.
    @param [Node] node
    */

    Node.prototype.addChild = function(node) {
      if (node === null || typeof node === 'undefined') {
        throw new Error("ExoReferenceError -> addChild: " + node + " is not a valid Exo.Node");
      }
      if (this.nodeId() === node.nodeId()) {
        throw new Error("ExoReferenceError -> An Exo.Node instance can't pass itself to addChild");
      }
      node.setParent(this);
      return this._childMap[node.nodeId()] = node;
    };

    /* 
    Remove a Node child from this instance.
    @param [Node] node
    */

    Node.prototype.removeChild = function(node) {
      return delete this._childMap[node.nodeId()];
    };

    /* 
    Set the default child node. This node will be automatically activated when this node has activated.
    It will also be activated when a sibling has deactivated, unless there's an onDeactivatedAction set.
    @param [Node] node
    */

    Node.prototype.setDefaultChild = function(node) {
      return this._defaultChild = node;
    };

    /* 
    Get the default child Node.
    */

    Node.prototype.defaultChild = function() {
      return this._defaultChild;
    };

    /* 
    An alias of childrenAsArray
    */

    Node.prototype.children = function() {
      return this.childrenAsArray();
    };

    /* 
    Get the children of this node as an Array.
    */

    Node.prototype.childrenAsArray = function(obj) {
      var arr, child, id, _ref;
      arr = [];
      _ref = this._childMap;
      for (id in _ref) {
        child = _ref[id];
        arr.push(child);
      }
      return arr;
    };

    /* 
    Get an Array of activated child nodes.
    */

    Node.prototype.activatedChildren = function() {
      return this.children().filter(function(n) {
        return n.isActivated();
      });
    };

    /* 
    Get a child by its String ID.
    @param [String] id
    */

    Node.prototype.childById = function(id) {
      return this._childMap[id];
    };

    /* 
    Get a descendant (child or deeper) by its String ID.
    @param [String] id
    */

    Node.prototype.descendantById = function(id) {
      var child, descendant, _i, _len, _ref;
      child = this.childById(id);
      if (child) return child;
      _ref = this.children();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        descendant = child.getDescendantById(id);
        if (descendant) return descendant;
      }
    };

    /* 
    Get an Array of Node instances that have the same parent as this instance.
    */

    Node.prototype.siblings = function() {
      var ownId;
      ownId = this.nodeId();
      if (this.parent()) {
        return this.parent().children().filter(function(n) {
          return n.nodeId() !== ownId;
        });
      }
      return [];
    };

    /* 
    Get a boolean stating if this Node instance is in the 'activated' state.
    */

    Node.prototype.isActivated = function() {
      return this.sm().currentState() === Node.States.ACTIVATED;
    };

    /* 
    Get a boolean stating if this Node instance is currently transitioning.
    */

    Node.prototype.isTransitioning = function() {
      return this.sm().isTransitioning();
    };

    /* 
    Get a boolean stating if this Node instance or any of its children are transitioning. 
    Note: Child transition status will only be included if mode == Node.Modes.Exclusive
    */

    Node.prototype.isBusy = function() {
      if (this.isTransitioning()) return true;
      if (this.mode() === Node.Modes.EXCLUSIVE) {
        if (this.children().filter(function(n) {
          return n.isBusy();
        }).length > 0) {
          return true;
        }
      }
      return false;
    };

    /* 
    Get a boolean stating if any of the children of this node are transitioning.
    */

    Node.prototype.haveBusyChildren = function() {
      return this.children().filter(function(n) {
        return n.isBusy();
      }).length > 0;
    };

    /* 
    Attempt to perform a transition to a new state.
    @param [String] transition
    */

    Node.prototype.attemptTransition = function(t) {
      return this.sm().attemptTransition(t);
    };

    /* 
    Attempt to activate this Node instance.
    */

    Node.prototype.activate = function() {
      return Node.activate(this);
    };

    /* 
    Attempt to deactivate this Node instance.
    */

    Node.prototype.deactivate = function() {
      return Node.deactivate(this);
    };

    /* 
    Attempt to toggle this Node instance.
    */

    Node.prototype.toggle = function() {
      return Node.toggle(this);
    };

    /* 
    Attempt to deactivate all children of this Node instance.
    */

    Node.prototype.deactivateChildren = function() {
      var child, _i, _len, _ref, _results;
      _ref = this.children();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        _results.push(child.deactivate());
      }
      return _results;
    };

    /* 
    Should be called when the activate transition is done. Can be overridden.
    */

    Node.prototype.onActivated = function() {
      this.sm().onTransitionComplete();
      Node.onNodeActivated(this);
      return this.setOnActivatedAction(null);
    };

    /* 
    Should be called when the deactivate transition is done. Can be overridden.
    */

    Node.prototype.onDeactivated = function() {
      this.sm().onTransitionComplete();
      Node.onNodeDeactivated(this);
      return this.setOnDeactivatedAction(null);
    };

    /* 
    Is called before doActivate. Can be overridden.
    */

    Node.prototype.beforeActivate = function() {};

    /* 
    Called when the activate transition should begin. Can be overridden.
    */

    Node.prototype.doActivate = function() {
      return this.onActivated();
    };

    /* 
    Is called before doDectivate. Can be overridden.
    */

    Node.prototype.beforeDeactivate = function() {};

    /* 
    Called when the deactivate transition should begin. Can be overridden.
    */

    Node.prototype.doDeactivate = function() {
      return this.onDeactivated();
    };

    /* 
    Called when a child Node of this instance has been activated.
    */

    Node.prototype.onChildActivated = function(child) {};

    /* 
    Called when a child Node of this instance has been deactivated.
    */

    Node.prototype.onChildDeactivated = function(child) {};

    return Node;

  })();

  Exo.Node = Node;

}).call(this);
