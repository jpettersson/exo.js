Spine = @Spine or require('spine')

class Controller extends Spine.Controller

  constructor: (opts={})->
    super

    _node = null
    @node = ->
      unless _node
        _node = new Exo.Node opts

        # Store a reference of this to substitute
        # in outgoing events/function calls.
        _node.controller = @
      _node

    @nodeId = -> @node().id
    @setId = (id)-> @node.setId(id)
    @setMode = (mode)-> @node().setMode(mode)

    @activate = -> 
      @node().activate()
    
    @deactivate = -> 
      @node().deactivate()
    
    @toggle = -> 
      @node().toggle()

    # Delegate the transitions to this object.
    @node().doActivate = =>
      @doActivate()

    @node().doDectivate = =>
      @doDectivate()

    # TODO: Make sure the node function exists and throw an Exo.Incompatible 
    # object error if not.
    @addChild = (controller)-> @node().addChild controller.node()
    
    @children = ->
      @node().children().map (node)-> node.controller

    @parent = ->
      @node().parent()?.controller

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
    @trigger 'onActivated', @

Exo.Spine ||= {}
Exo.Spine.Controller = Controller