### 
Overview of a node

The Class Methods are used internally by the framework.
###
class Node

  @__currentId = 0

  @Transitions:
    ACTIVATE: 'activate'
    DEACTIVATE: 'deactivate'

  @States:
    ACTIVATED: 'activated'
    DEACTIVATED: 'deactivated'

  @Modes:
    EXCLUSIVE: 'exclusive'
    MULTI: 'multi'

  ### 
  Generate the next unique node ID string.
  ###
  @nextId: ->
    Node.__currentId = Node.__currentId + 1

    return Node.__currentId

  ### 
  Attempt to activate a node instance.
  @param [Node] node
  ###
  @activate: (node) ->
    return false if @lineageIsBusy(node) or node.isActivated()

    if parent = node.parent()
      if parent.isActivated()
        if parent.mode() == Node.Modes.EXCLUSIVE
          if sibling = parent.activatedChildren()[0]
            sibling.setOnDeactivatedAction
              node: node
              transition: Node.Transitions.ACTIVATE
            return Node.deactivate sibling
      else
        return false unless parent.childrenCanActivate()
        parent.setOnActivatedAction
          node: node
          transition: Node.Transitions.ACTIVATE
        return Node.activate parent

    node.attemptTransition Node.Transitions.ACTIVATE

  ### 
  Attempt to deactivate a node instance.
  @param [Node] node
  ###
  @deactivate: (node) ->
    if node.isActivated() and not @lineageIsBusy(node)
      if node.mode() == Node.Modes.EXCLUSIVE
        if child = node.activatedChildren()[0]
          child.setOnDeactivatedAction
            node: node
            transition: Node.Transitions.DEACTIVATE
          return Node.deactivate(child)

      else if node.mode == Node.Modes.MULTI
        for child in node.activatedChildren()
          Node.deactivate(child)

      node.attemptTransition Node.Transitions.DEACTIVATE

    false

  ### 
  Attempts to perform activation if the node is deactivated and vice versa.
  @param [Node] node
  ###
  @toggle: (node) ->
    if node.isActivated()
      return @deactivate node
    else
      return @activate node

  ### 
  Find out if the lineage of a node is busy. This will be true if a parent, sibling or child is currently transitioning.
  @param [Node] node
  ###
  @lineageIsBusy: (node)->
    if parent = node.parent()
      return true if parent.isBusy()
      while parent = parent.parent()
        return true if parent.isBusy()
    false

  ### 
  Node instances call this function when done activating. If there is a pending action it will be executed.
  @param [Node] node
  ###
  @onNodeActivated: (node)->
    node.parent().onChildActivated(node) if node.parent()
    if action = node.onActivatedAction()
      @processAction action

  ### 
  Node instances call this function when done deactivating. If there is a pending action it will be executed.
  @param [Node] node
  ###
  @onNodeDeactivated: (node)->
    node.parent().onChildDeactivated(node) if node.parent()
    if action = node.onDeactivatedAction()
      @processAction action
    else if node.parent()?.defaultChild()
      Node.activate node.parent().defaultChild()

  ### 
  Process an action of activating or deactivating a node reference.
  @param [Object] action
  ###
  @processAction: (action) ->
    if action.transition == Node.Transitions.ACTIVATE
        @activate(action.node)
      else if action.transition == Node.Transitions.DEACTIVATE
        @deactivate(action.node)

  ### 
  Constructor
  @param [Object] options
  @option options [Array] children add children at instantiation.
  @option options [String] mode one of two possible operational modes: 'exclusive', 'multi'
  @option options [String] initialState 'deactivated' or 'activated' default is 'deactivated'.
  @option options [Boolean] childrenCanActivate If true, this node can be activated by it's children. Defaults to true.
  ###
  constructor: (opts={})->
    @_parent = null
    @_childMap = {}
    @_defaultChild = null
    @_nId = "exo##{Node.nextId()}"

    if opts.children
      for node in opts.children
        node.setParent @
        for child in opts.children
          @addChild child

    @_mode = opts.mode ||= Node.Modes.EXCLUSIVE
    @_initialState = opts.initialState ||= Node.States.DEACTIVATED

    # By default children automatically activate their parents
    # if they are not activated.
    if opts.childrenCanActivate == false
      @_childrenCanActivate = false
    else
      @_childrenCanActivate = true

    @_onActivatedAction = null
    @_onDeactivatedAction = null

  ### 
  Returns the id of the node. By default this is a generated unique String value.
  ###
  nodeId: ->
    @_nId

  ### 
  Manually set the node ID. Caution: If multiple children of a node are given the same ID only one instance will persist.
  ###
  setNodeId: (nid)->
    @_parent?.onChildIdUpdated @_nId, nid, @
    @_nId = nid

  ### 
  Returns the internal state-machine instance.
  ###
  sm: ->
    return @_smRef if @_smRef

    @_smRef = new Exo.StateMachine
      states: [Node.States.DEACTIVATED, Node.States.ACTIVATED]
      initialState: @_initialState
      transitions:
        activate:
          from: Node.States.DEACTIVATED
          to: Node.States.ACTIVATED
        deactivate:
          from: Node.States.ACTIVATED
          to: Node.States.DEACTIVATED

    @_smRef.performTransition = (t) =>
      if t == Node.Transitions.ACTIVATE
        @beforeActivate()
        @doActivate()
      else if t == Node.Transitions.DEACTIVATE
        @beforeDeactivate()
        @doDeactivate()

    return @_smRef

  ### 
  Children call this function on their parent when their node ID has been manually changed.  
  ###
  onChildIdUpdated: (oldId, newId, child)->
    delete @_childMap[oldId]
    @_childMap[newId] = child

  ### 
  Used by the framework to chain sequences of Node activation. 
  For instance, when activating a sibling of an already activated node this function will be called on the parent
  with a reference to the sibling.
  ###
  setOnActivatedAction: (action) ->
    @_onActivatedAction = action

  ### 
  A getter to read the onActivatedAction value.
  ###
  onActivatedAction: ->
    @_onActivatedAction

  ### 
  Used by the framework to chain sequences of Node deactivation.
  ###
  setOnDeactivatedAction: (action) ->
    @_onDeactivatedAction = action

  ### 
  Get the onDeactivatedAction value.
  ###
  onDeactivatedAction: ->
    @_onDeactivatedAction

  ### 
  Get the childrenCanActivate setting.
  ###
  childrenCanActivate: ->
    @_childrenCanActivate

  ### 
  Set the mode.
  @param [String] mode
  ###
  setMode: (m) ->
    @_mode = m

  ### 
  Get the mode.
  ###
  mode: () ->
    @_mode

  ### 
  Set the parent Node. This is called automatically when using node.addChild
  @param [Node] node
  ###
  setParent: (node) ->
    @_parent = node

  ### 
  Get the parent Node.
  ###
  parent: ->
    @_parent

  ### 
  Add a Node instance as a child.
  @param [Node] node
  ###
  addChild: (node) ->

    throw new Error(
      "ExoReferenceError -> addChild: #{node} is not a valid Exo.Node"
    ) if node == null or typeof node == 'undefined'

    throw new Error(
      "ExoReferenceError -> An Exo.Node instance can't pass itself to addChild"
    ) if @nodeId() == node.nodeId()

    node.setParent(@)
    @_childMap[node.nodeId()] = node

  ### 
  Remove a Node child from this instance.
  @param [Node] node
  ###
  removeChild: (node) ->
    delete @_childMap[node.nodeId()]
  
  ### 
  Set the default child node. This node will be automatically activated when this node has activated.
  It will also be activated when a sibling has deactivated, unless there's an onDeactivatedAction set.
  @param [Node] node
  ###
  setDefaultChild: (node) ->
    @_defaultChild = node

  ### 
  Get the default child Node.
  ###
  defaultChild: ->
    @_defaultChild

  ### 
  An alias of childrenAsArray
  ###
  children: ->
    @childrenAsArray()

  ### 
  Get the children of this node as an Array.
  ###
  childrenAsArray: (obj) ->
    arr = []
    for id, child of @_childMap
      arr.push child
    return arr

  ### 
  Get an Array of activated child nodes.
  ###
  activatedChildren: ->
    @children().filter (n) -> n.isActivated()

  ### 
  Get a child by its String ID.
  @param [String] id
  ###
  childById: (id) ->
    @_childMap[id]

  ### 
  Get a descendant (child or deeper) by its String ID.
  @param [String] id
  ###
  descendantById: (id) ->
    child = @childById(id)
    if child
      return child

    for child in @children()
      descendant = child.getDescendantById(id)
      if descendant
        return descendant

  ### 
  Get an Array of Node instances that have the same parent as this instance.
  ###
  siblings: ->
    ownId = @nodeId()

    if @parent()
      return @parent().children().filter (n)-> n.nodeId() isnt ownId

    return []

  ### 
  Get a boolean stating if this Node instance is in the 'activated' state.
  ###
  isActivated: ->
    @sm().currentState() == Node.States.ACTIVATED

  ### 
  Get a boolean stating if this Node instance is currently transitioning.
  ###
  isTransitioning: ->
    @sm().isTransitioning()

  ### 
  Get a boolean stating if this Node instance or any of its children are transitioning. 
  Note: Child transition status will only be included if mode == Node.Modes.Exclusive
  ###
  isBusy: ->
    return true if @isTransitioning()

    if @mode() == Node.Modes.EXCLUSIVE
      # Why was this in here? It didn't work.. check old implementation!
      # return true if @onActivatedAction() != null or @onDeactivatedAction() != null
      return true if @children().filter((n) -> n.isBusy()).length > 0

    return false

  ### 
  Get a boolean stating if any of the children of this node are transitioning.
  ###
  haveBusyChildren: ->
    @children().filter((n) -> n.isBusy()).length > 0

  ### 
  Attempt to perform a transition to a new state.
  @param [String] transition
  ###
  attemptTransition: (t) ->
    @sm().attemptTransition t

  ### 
  Attempt to activate this Node instance.
  ###
  activate: -> Node.activate @
  
  ### 
  Attempt to deactivate this Node instance.
  ###
  deactivate: -> Node.deactivate @

  ### 
  Attempt to toggle this Node instance.
  ###
  toggle: -> Node.toggle @

  ### 
  Attempt to deactivate all children of this Node instance.
  ###
  deactivateChildren: ->
    for child in @children()
      child.deactivate()

  ### 
  Should be called when the activate transition is done. Can be overridden.
  ###
  onActivated: ->
    @sm().onTransitionComplete()
    Node.onNodeActivated @
    @setOnActivatedAction null

  ### 
  Should be called when the deactivate transition is done. Can be overridden.
  ###
  onDeactivated: ->
    @sm().onTransitionComplete()
    Node.onNodeDeactivated @
    @setOnDeactivatedAction null

  ### 
  Is called before doActivate. Can be overridden.
  ###
  beforeActivate: ->

  ### 
  Called when the activate transition should begin. Can be overridden.
  ###
  doActivate: -> @onActivated()

  ### 
  Is called before doDectivate. Can be overridden.
  ###
  beforeDeactivate: ->

  ### 
  Called when the deactivate transition should begin. Can be overridden.
  ###
  doDeactivate: -> @onDeactivated()

  ### 
  Called when a child Node of this instance has been activated.
  ###
  onChildActivated: (child) ->
  
  ### 
  Called when a child Node of this instance has been deactivated.
  ###
  onChildDeactivated: (child) ->

Exo.Node = Node