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

  nodeId: ->
    @_nId

  setNodeId: (nid)->
    @_parent?.onChildIdUpdated @_nId, nid, @
    @_nId = nid

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

  onChildIdUpdated: (oldId, newId, child)->
    delete @_childMap[oldId]
    @_childMap[newId] = child

  setOnActivatedAction: (action) ->
    @_onActivatedAction = action

  onActivatedAction: ->
    @_onActivatedAction

  setOnDeactivatedAction: (action) ->
    @_onDeactivatedAction = action

  onDeactivatedAction: ->
    @_onDeactivatedAction

  # Refactor the options into a common getter?
  childrenCanActivate: ->
    @_childrenCanActivate

  setMode: (m) ->
    @_mode = m

  mode: () ->
    @_mode

  setParent: (node) ->
    @_parent = node

  parent: ->
    @_parent

  childrenAsArray: (obj) ->
    arr = []
    for id, child of @_childMap
      arr.push child
    return arr

  addChild: (node) ->

    throw new Error(
      "ExoReferenceError -> addChild: #{node} is not a valid Exo.Node"
    ) if node == null or typeof node == 'undefined'

    throw new Error(
      "ExoReferenceError -> An Exo.Node instance can't pass itself to addChild"
    ) if @nodeId() == node.nodeId()

    node.setParent(@)
    @_childMap[node.nodeId()] = node

  removeChild: (node) ->
    delete @_childMap[node.nodeId()]

  setDefaultChild: (node) ->
    @_defaultChild = node

  defaultChild: ->
    @_defaultChild

  children: ->
    @childrenAsArray()

  activatedChildren: ->
    @children().filter (n) -> n.isActivated()

  childById: (id) ->
    @_childMap[id]

  descendantById: (id) ->
    child = @childById(id)
    if child
      return child

    for child in @children()
      descendant = child.getDescendantById(id)
      if descendant
        return descendant

  siblings: ->
    ownId = @nodeId()

    if @parent()
      return @parent().children().filter (n)-> n.nodeId() isnt ownId

    return []

  isActivated: ->
    @sm().currentState() == Node.States.ACTIVATED

  isTransitioning: ->
    @sm().isTransitioning()

  isBusy: ->
    return true if @isTransitioning()

    if @mode() == Node.Modes.EXCLUSIVE
      # Why was this in here? It didn't work.. check old implementation!
      # return true if @onActivatedAction() != null or @onDeactivatedAction() != null
      return true if @children().filter((n) -> n.isBusy()).length > 0

    return false

  haveBusyChildren: ->
    @children().filter((n) -> n.isBusy()).length > 0

  attemptTransition: (t) ->
    @sm().attemptTransition t

  activate: -> Node.activate @
  deactivate: -> Node.deactivate @
  toggle: -> Node.toggle @

  # TODO
  deactivateChildren: ->
    for child in @children()
      child.deactivate()

  onActivated: ->
    @sm().onTransitionComplete()
    Node.onNodeActivated @
    @setOnActivatedAction null

  onDeactivated: ->
    @sm().onTransitionComplete()
    Node.onNodeDeactivated @
    @setOnDeactivatedAction null

  # "Public functions"

  beforeActivate: ->
  doActivate: -> @onActivated()

  beforeDeactivate: ->
  doDeactivate: -> @onDeactivated()

  onChildActivated: (child) ->

  onChildDeactivated: (child) ->

Exo.Node = Node