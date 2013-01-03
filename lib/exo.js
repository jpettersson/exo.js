(function() {
  var Exo;

  Exo = this.Exo = {};

}).call(this);
(function() {
  var StateMachine;

  StateMachine = (function() {

    StateMachine.E_DUPLICATE_STATE = "E_DUPLICATE_STATE: States must be distinct";

    StateMachine.E_DUPLICATE_TRANSITION = "E_DUPLICATE_TRANSITION: Transitions must be distinct";

    StateMachine.E_UNDEFINED_STATE = "E_UNDEFINED_STATE: All states used in transitions must be defined in the states array";

    function StateMachine(opts) {
      var currentState, currentTransition, initialState, states, transitions, validate;
      if (opts == null) {
        opts = {};
      }
      states = opts.states || [];
      transitions = opts.transitions || [];
      (validate = function() {
        var sCheck, tCheck, tStates, transition, unique;
        unique = function(a) {
          var key, output, value, _i, _ref, _results;
          output = {};
          for (key = _i = 0, _ref = a.length; 0 <= _ref ? _i < _ref : _i > _ref; key = 0 <= _ref ? ++_i : --_i) {
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

}).call(this);
(function() {
  var Node;

  Node = (function() {

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

    Node.activate = function(node) {
      var parent, sibling;
      if (this.lineageIsBusy(node) || node.isActivated()) {
        return false;
      }
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
          parent.setOnActivatedAction({
            node: node,
            transition: Node.Transitions.ACTIVATE
          });
          return Node.activate(parent);
        }
      }
      return node.attemptTransition(Node.Transitions.ACTIVATE);
    };

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

    Node.toggle = function(node) {
      if (node.isActivated()) {
        return this.deactivate(node);
      } else {
        return this.activate(node);
      }
    };

    Node.lineageIsBusy = function(node) {
      var parent;
      if (parent = node.parent()) {
        if (parent.isBusy()) {
          return true;
        }
        while (parent = parent.parent()) {
          if (parent.isBusy()) {
            return true;
          }
        }
      }
      return false;
    };

    Node.onNodeActivated = function(node) {
      var action;
      if (node.parent()) {
        node.parent().onChildActivated(node);
      }
      if (action = node.onActivatedAction()) {
        return this.processAction(action);
      }
    };

    Node.onNodeDeactivated = function(node) {
      var action;
      if (node.parent()) {
        node.parent().onChildDeactivated(node);
      }
      if (action = node.onDeactivatedAction()) {
        return this.processAction(action);
      }
    };

    Node.processAction = function(action) {
      if (action.transition === Node.Transitions.ACTIVATE) {
        return this.activate(action.node);
      } else if (action.transition === Node.Transitions.DEACTIVATE) {
        return this.deactivate(action.node);
      }
    };

    function Node(opts) {
      var children, id, initialState, mode, node, onActivatedAction, onDeactivatedAction, parent, smRef, _i, _len, _ref,
        _this = this;
      if (opts == null) {
        opts = {};
      }
      parent = null;
      children = [];
      if (opts.children) {
        _ref = opts.children;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          node = _ref[_i];
          node.setParent(this);
        }
        children = opts.children;
      }
      id = opts.id;
      mode = opts.mode || (opts.mode = Node.Modes.EXCLUSIVE);
      initialState = opts.initialState || (opts.initialState = Node.States.DEACTIVATED);
      onActivatedAction = null;
      onDeactivatedAction = null;
      smRef = null;
      this.sm = function() {
        return smRef || (smRef = new Exo.StateMachine({
          states: [Node.States.DEACTIVATED, Node.States.ACTIVATED],
          initialState: initialState,
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
        }));
      };
      this.sm().performTransition = function(t) {
        if (t === Node.Transitions.ACTIVATE) {
          _this.beforeActivate();
          return _this.doActivate();
        } else if (t === Node.Transitions.DEACTIVATE) {
          _this.beforeDeactivate();
          return _this.doDeactivate();
        }
      };
      this.setOnActivatedAction = function(action) {
        return onActivatedAction = action;
      };
      this.onActivatedAction = function() {
        return onActivatedAction;
      };
      this.setOnDeactivatedAction = function(action) {
        return onDeactivatedAction = action;
      };
      this.onDeactivatedAction = function() {
        return onDeactivatedAction;
      };
      this.setMode = function(m) {
        return mode = m;
      };
      this.mode = function() {
        return mode;
      };
      this.setParent = function(node) {
        return parent = node;
      };
      this.parent = function() {
        return parent;
      };
      this.addChild = function(node) {
        node.setParent(this);
        return children.push(node);
      };
      this.removeChild = function(node) {
        return children = children.filter(function(a) {
          return a !== node;
        });
      };
      this.children = function() {
        return children;
      };
      this.activatedChildren = function() {
        return children.filter(function(n) {
          return n.isActivated();
        });
      };
      this.childById = function(id) {
        return children.filter(function(n) {
          return n.id === id;
        })[0];
      };
      this.descendantById = function(id) {
        var child, descendant, _j, _len1;
        child = childById(id);
        if (child) {
          return child;
        }
        for (_j = 0, _len1 = children.length; _j < _len1; _j++) {
          child = children[_j];
          descendant = child.getDescendantById(id);
          if (descendant) {
            return descendant;
          }
        }
      };
      this.siblings = function() {
        if (parent) {
          return parent.children().filter(function(n) {
            return n !== this;
          });
        }
        return [];
      };
      this.isActivated = function() {
        return this.sm().currentState() === Node.States.ACTIVATED;
      };
      this.isTransitioning = function() {
        return this.sm().isTransitioning();
      };
      this.isBusy = function() {
        if (this.isTransitioning()) {
          return true;
        }
        if (this.mode() === Node.Modes.EXCLUSIVE) {
          if (children.filter(function(n) {
            return n.isBusy();
          }).length > 0) {
            return true;
          }
        }
        return false;
      };
      this.attemptTransition = function(t) {
        return this.sm().attemptTransition(t);
      };
      this.activate = function() {
        return Node.activate(this);
      };
      this.deactivate = function() {
        return Node.deactivate(this);
      };
      this.toggle = function() {
        return Node.toggle(this);
      };
      this.deactivateChildren = function() {
        var child, _j, _len1, _ref1, _results;
        _ref1 = this.children();
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          child = _ref1[_j];
          _results.push(child.deactivate());
        }
        return _results;
      };
      this.onActivated = function() {
        this.sm().onTransitionComplete();
        Node.onNodeActivated(this);
        return this.setOnActivatedAction(null);
      };
      this.onDeactivated = function() {
        this.sm().onTransitionComplete();
        Node.onNodeDeactivated(this);
        return this.setOnDeactivatedAction(null);
      };
    }

    Node.prototype.beforeActivate = function() {};

    Node.prototype.doActivate = function() {
      return this.onActivated();
    };

    Node.prototype.beforeDeactivate = function() {};

    Node.prototype.doDeactivate = function() {
      return this.onDeactivated();
    };

    Node.prototype.onChildActivated = function(child) {};

    Node.prototype.onChildDeactivated = function(child) {};

    return Node;

  })();

  Exo.Node = Node;

}).call(this);
