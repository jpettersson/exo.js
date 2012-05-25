Spine ?= require('spine')

class ControllerHelper
	
	@activate: (c) ->
		unless @lineageIsBusy(c)
			if !c.isActive()
				return ControllerHelper.activateController(c)
	
	@deactivate: (c) ->
		unless @lineageIsBusy(c)
			if c.isActive()
				return ControllerHelper.deactivateController(c)
	
	@toggle: (c) ->
		if c.isActive()
			return @deactivate c
		else
			return @activate c
	
	@activateController: (c) ->
		parent = c.getParent()
		
		if parent
			if parent.isActive()
				siblings = parent.getChildren()
				#console.log "Siblings: #{siblings}"
				for sibling in siblings
					if sibling.isActive()
						sibling.setOnDeactivatedAction new ControllerAction(c, ControllerAction.TYPE_ACTIVATE)
						return ControllerHelper.deactivateController(sibling)
			else
				parent.setOnActivatedAction new ControllerAction(c, ControllerAction.TYPE_ACTIVATE)
				return ControllerHelper.activateController parent
		
		return c.toState Controller.STATE_ACTIVATED
	
	@deactivateController: (c)->
		children = c.getChildren()
		for child in children
			if child.isActive()
				child.setOnDeactivatedAction new ControllerAction(c, ControllerAction.TYPE_DEACTIVATE)
				return ControllerHelper.deactivateController(child)
		
		return c.toState Controller.STATE_DEACTIVATED

	@lineageIsBusy: (c)->
		parent = c.getParent()
		
		if parent
			return true if parent.isBusy()
			while parent = parent.getParent()
				return true if parent.isBusy()

		return false
		
	@onControllerActivated: (c)->
		action = c.getOnActivatedAction()
		
		if action
			if action.getType() == ControllerAction.TYPE_ACTIVATE
				ControllerHelper.activateController(action.getController())
	
	@onControllerDeactivated: (c)->
		action = c.getOnDeactivatedAction()
		
		if action
			if action.getType() == ControllerAction.TYPE_DEACTIVATE
				ControllerHelper.deactivateController(action.getController())
			else if action.getType() == ControllerAction.TYPE_ACTIVATE
				ControllerHelper.activateController(action.getController())
		
		
class ControllerAction
	@TYPE_ACTIVATE = "activate"
	@TYPE_DEACTIVATE = "deactivate"
	
	constructor: (controller, type) ->
		@controller = controller
		@type = type
	
	getType: ->
		@type
	
	getController: ->
		@controller
	
	
class StateMachine extends Spine.Module
	@include Spine.Events
	
	constructor: ->
		@states = []
		@currentState = null
		@nextState = null
		@initialState = null
		@enabled = true
		
	addState: (state, isInitialState=false)->
		@states.push state
		if isInitialState
			@currentState = @initialState = state
	
	activate: (state)->
		if state in @states
			if @enabled && @nextState == null && state != @currentState
				@nextState = state
				@trigger "on_transition", this, @currentState, @nextState
				return true
				
		return false
	
	onTransitionComplete: ->
		@currentState = @nextState
		@nextState = null
		
	getCurrentState: ->
		@currentState
	
	getNextState: ->
		@nextState
		
	enable: ->
		@enabled = true
		
	disable: ->
		@enabled = false
	
	reset: ->
		@nextState = null
		@currentState = @initialState
		

# 	TODO: 
# 	1. Optionally support multiple active children.
#	2. Add option to have STATE_ACTIVATED be default.

class Controller extends Spine.Controller
	
	@STATE_ACTIVATED = "activated"
	@STATE_DEACTIVATED = "deactivated"

	#
	# Options:
	# defaultChild		Controller
	#
	
	constructor: (options={}) ->
		@sm = new StateMachine
		
		defaultState = options.defaultState
		
		@sm.addState Controller.STATE_DEACTIVATED, defaultState == Controller.STATE_ACTIVATED ? false : true
		@sm.addState Controller.STATE_ACTIVATED, defaultState == Controller.STATE_ACTIVATED ? true : false
		
		@sm.bind "on_transition", @transition
		@children = []
		
		@onActivatedAction = null
		@onDeactivatedAction = null
		
		super options
		
		@prepare()
		
	prepare: ->
				
	addChild: (c, options={}) ->
		c.setParent(@)
		if options.default
			@setDefaultChild(c)	
		
		@children.push c
	
	removeChild: (c) ->
		@children = @children.filter (child) -> child isnt c
	
	toState: (state)->
		@sm.activate(state)
	
	beforeActivate: ->
		
	beforeDeactivate: ->
	
	activate: ->
		ControllerHelper.activate(@)

	deactivate: ->
		ControllerHelper.deactivate(@)
	
	deactivateChildren: ->
		@getActiveChild().deactivate() if @getActiveChild()
	
	reset: ->
		@sm.reset()
	
	toggle: ->
		ControllerHelper.toggle(@)
	
	doActivate: ->
		# Override in subclass
			
	doDeactivate: ->
		# Override in subclass
		
	onActivated: ->
		@sm.onTransitionComplete()
		ControllerHelper.onControllerActivated(@)
		@onActivatedAction = null
		@trigger "onActivated", @

	onDeactivated: ->
		@sm.onTransitionComplete()
		ControllerHelper.onControllerDeactivated(@)
		@onDeactivatedAction = null
		@trigger "onDeactivated", @
	
	# TODO: Make sure it's the correct SM
	transition: (sm, from, to)=>
		if to == Controller.STATE_ACTIVATED
			@beforeActivate()
			@trigger "activating", @
			@doActivate()
		else if to == Controller.STATE_DEACTIVATED
			@beforeDeactivate()
			@trigger "deactivating", @
			@doDeactivate()
	
	isActive: ->
		@sm.getCurrentState() == Controller.STATE_ACTIVATED
		# Removing this for now, it's better to check both isActive and isTransitioning separately.
		# && @sm.getNextState() == null
	
	isTransitioning: ->
		@sm.getNextState() != null
		
	isBusy: ->
		return true if @isTransitioning() or @onActivatedAction or @onDeactivatedAction
		
		for child in @children
			return true if child.isBusy()
		
		return false
	
	getId: ->
		@id
	
	getChildren: ->
		@children
	
	getChildById: (id) ->
		for child in @children
			return child if child.getId() == id	
	
	getDescendantById: (id) ->
		child = @getChildById(id)
		if child 
			return child
		
		for child in @children
			descendant = child.getDescendantById(id)
			if descendant
				return descendant
				
	getActiveChild: ->
		for child in @children
			return child if child.isActive()
	
	getParent: ->
		#console.log "Controller.getParent #{@parent}"
		@parent
		
	setOnDeactivatedAction: (action) ->
		@onDeactivatedAction = action
	
	getOnDeactivatedAction: ->
		@onDeactivatedAction
		
	setOnActivatedAction: (action) ->
		@onActivatedAction = action
	
	getOnActivatedAction: ->
		@onActivatedAction
	
	setDefaultChild: (child) ->
		@defaultChild = child
		
	setParent: (parent) ->
		#console.log "Controller.setParent #{parent}"
		@parent = parent
		

module.exports = Controller