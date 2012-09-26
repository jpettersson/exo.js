StateMachine = require 'state_machine'

# Exo.Node can be used to build an arbitrarily large directed graph
# of ui components that will be controlled hierarchical from the top down.

class Node extends Spine.Module
	@include Spine.Events

	@Transitions:
		ACTIVATE: 'activate'
		DEACTIVATE: 'deactivate'

	@States:
		ACTIVATED: 'activated'
		DEACTIVATED: 'deactivated'

	@Modes:
		EXCLUSIVE: 'exclusive'
		MULTI: 'multi'

	@activate: (node) ->
		unless @lineageIsBusy node
			if !node.isActive()
				parent = node.getParent()
				
				if parent
					if parent.isActive()
						# We only care about sibling states if the parent is in exlusive mode. 
						# Multi mode is usful in implementations like lists, where it's desired 
						# to mange the transitions of many concurrent children.
						if parent.mode == Node.Modes.EXCLUSIVE
							siblings = parent.getChildren()
							for sibling in siblings
								if sibling.isActive()
									sibling.onDeactivatedAction = @createAction sibling, 'activate'
									return ControllerHelper.deactivate(sibling)
					
					else
						parent.setOnActivatedAction new ControllerAction(c, ControllerAction.TYPE_ACTIVATE)
						return ControllerHelper.activate parent

				node.attemptTransition Node.Transitions.ACTIVATE

	@deactivate: (node) ->
		unless @lineageIsBusy(c)
			if node.isActive()
				children = c.getChildren()
				for child in children
					if child.isActive()
						child.setOnDeactivatedAction new ControllerAction(c, ControllerAction.TYPE_DEACTIVATE)
						return ControllerHelper.deactivate(child)
				
				node.attemptTransition Node.Transitions.DEACTIVATE

	@toggle: (node) ->
		if node.isActive()
			return @deactivate node
		else
			return @activate node

	@lineageIsBusy: (node)->
		parent = node.getParent()
		
		if parent
			return true if parent.isBusy()
			while parent = parent.getParent()
				return true if parent.isBusy()
		

	@onNodeActivated: (node)->
		action = node.getOnActivatedAction()
		
		if action
			if action.getType() == ControllerAction.TYPE_ACTIVATE
				ControllerHelper.activateController(action.getController())
	
	@onNodeDeactivated: (node)->
		action = node.getOnDeactivatedAction()
		
		if action
			if action.getType() == ControllerAction.TYPE_DEACTIVATE
				ControllerHelper.deactivateController(action.getController())
			else if action.getType() == ControllerAction.TYPE_ACTIVATE
				ControllerHelper.activateController(action.getController())


	# instance

	parent: null
	children: []

	constructor: (opts={})->

		@mode = options.mode ||= Node.Modes.EXCLUSIVE
		@initialState = options.initialState ||= Node.States.DEACTIVATED

		@sm().performTransition = (transition) =>
			if transition == Node.Transitions.ACTIVATE
				@beforeActivate()
				@trigger 'activating', @
				@doActivate()
			else if transition == Node.Transitions.DEACTIVATE
				@beforeDeactivate()
				@trigger 'deactivating', @
				@doDeactivate()

		super opts

		@prepare()

	# Create and return the state machine instance
	sm: ->
		@smRef ||= new StateMachine
			transitions:
				activate:
					from: Node.States.DEACTIVATED
					to: Node.States.ACTIVATED
				deactivate: 
					from: Node.States.ACTIVATED
					to: Node.States.DEACTIVATED

			initialState: @initialState

	prepare: ->


	addChild: (node) ->
		node.parent = @

		node.bind 'onActivated', =>
			@onChildActivated node
		node.bind 'onDeactivated', =>
			@onChildDeactivated node

		@children.push node

	removeChild: (node) ->
		@children = @children.filter (a) -> node isnt a
	
	siblings: () ->
		# @edges.filter((edge) -> edge.type == Node.Predecessor).map((edge)-> node) #flatten?

	attemptTransition: (transition) ->
		@sm().attemptTransition transition


	beforeActivate: ->

	activate: ->
		Node.activate @
		
	doActivate: ->
		# Should be defined in the extending class

	onActivated: ->
		@sm().onTransitionComplete()
		@onNodeActivated @
		#@onActivatedAction = null
		@trigger 'onActivated', @

	beforeDeactivate: ->

	deactivate: ->
		Node.deactivate @

	doDeactivate: ->
		# Should be defined in the extending class

	onDeactivated: ->
		@sm().onTransitionComplete()
		@onNodeDeactivated @
		#onDeactivatedAction = null
		@trigger 'onDeactivated', @

	deactivateChildren: ->
		@activeChild().deactivate() if @activeChild()

	onChildActivated: (child) ->

	onChildDeactivated: (child) ->

	activatedChildren: () ->
		@children.filter (node) -> node.isActivated()


module.exports = Node

