Spine = @Spine or require('spine')

class Controller extends Spine.Controller

  constructor: (opts={})->
    nodeOpts = opts

    _node = null
    @node = ->
      unless _node
        _node = new Exo.Node nodeOpts

        # Store a reference of this to substitute
        # in outgoing events/function calls.
        _node.controller = @
      _node

    @nodeId = -> @node().nodeId()
    @setNodeId = (id)-> @node().setNodeId(id)
    @setMode = (mode)-> @node().setMode(mode)

    @activate = -> 
      @node().activate()
    
    @deactivate = -> 
      @node().deactivate()
    
    @toggle = -> 
      @node().toggle()

    # Delegate the transitions to this object.
    @node().beforeActivate = =>
      @trigger 'beforeActivate', @
      @beforeActivate?.call @

    @node().doActivate = =>
      @doActivate()

    @node().beforeDeactivate = =>
      @trigger 'beforeDeactivate', @
      @beforeDeactivate?.call @

    @node().doDeactivate = =>
      @doDeactivate()

    @node().onChildActivated = (node)=>
      @trigger 'onChildActivated', node.controller
      @onChildActivated? node.controller

    @node().onChildDeactivated = (node)=>
      @trigger 'onChildDeactivated', node.controller
      @onChildDeactivated? node.controller

    # TODO: Make sure the node function exists and throw an Exo.Incompatible 
    # object error if not.
    @addChild = (controller)-> @node().addChild controller?.node()
    
    @children = ->
      @node().children().map (node)-> node.controller

    @parent = ->
      @node().parent()?.controller

    @childById = (id)->
      @node().childById(id)?.controller

    @descendantById = (id)->
      @node().descendantById(id)?.controller

    @siblings = ->
      @node().siblings().map (node)-> node.controller

    @activatedChildren = ->
      @node().activatedChildren()

    # TODO: Make sure the .node function exists and throw an Exo.Incompatible 
    # object error if not.
    @removeChild = (controller)-> 
      @node().removeChild controller.node()

    @isActivated = -> 
      @node().isActivated()
    
    @isTransitioning = -> 
      @node().isTransitioning()

    @isBusy = ->
      @node().isBusy()

    @haveBusyChildren = ->
      @node().haveBusyChildren()

    # Clean up options before we send them to 
    # Spine.
    delete opts.initialState if opts.initialState
    delete opts.mode if opts.mode
    delete opts.children if opts.children

    super opts
    @prepare()

  prepare: ->

  doActivate: ->
    @onActivated()

  # Todo: Only dispatch event if the call to the node was successful
  onActivated: ->
    @node().onActivated()
    @trigger 'onActivated', @

  doDeactivate: ->
    @onDeactivated()

  # Todo: Only dispatch event if the call to the node was successful
  onDeactivated: ->
    @node().onDeactivated()
    @trigger 'onDeactivated', @

Exo.Spine ||= {}
Exo.Spine.Controller = Controller