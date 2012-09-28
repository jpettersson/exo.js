# Exo.Node can be used to build an arbitrarily large directed graph
# of ui components that will be controlled hierarchical from the top down.

StateMachine = require './state_machine'

class Node

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
		return false if @lineageIsBusy(node) or node.isActivated()

		if parent = node.parent()
			if parent.isActivated()
				if parent.mode == Node.Modes.EXCLUSIVE
					if sibling = parent.activatedChildren()[0]
						sibling.onDeactivatedAction =
							node: node
							transition: Node.Transitions.ACTIVATE
						return Node.deactivate sibling
			else
				parent.onActivatedAction = 
					node: node
					transition: Node.Transitions.ACTIVATE
				return Node.activate parent

		node.attemptTransition Node.Transitions.ACTIVATE

	@deactivate: (node) ->
		if node.isActivated() and not @lineageIsBusy(node)
			if node.mode == Node.Modes.EXCLUSIVE
				if child = node.activatedChildren()[0]
					child.onDeactivatedAction =
						node: node
						transition: Node.Transitions.DEACTIVATE
					return ControllerHelper.deactivate(child)

			else if node.mode == Node.Modes.MULTI
				for child in node.activatedChildren()
					ControllerHelper.deactivate(child)

			node.attemptTransition Node.Transitions.DEACTIVATE

		false

	@toggle: (node) ->
		if node.isActivated()
			return @deactivate node
		else
			return @activate node

	@lineageIsBusy: (node)->
		if parent = node.parent()
			return true if parent.isBusy()
			while parent = parent.parent()
				return true if parent.isBusy()
		false

	@onNodeActivated: (node)->
		node.parent().onChildActivated(node) if node.parent()
		if action = node.onActivatedAction
			@processAction action

	@onNodeDeactivated: (node)->
		node.parent().onChildDeactivated(node) if node.parent()
		if action = node.onDeactivatedAction
			@processAction action

	@processAction: (action) ->
		if action.transition == Node.Transitions.ACTIVATE
				@activate(action.node)
			else if action.transition == Node.Transitions.DEACTIVATE
				@deactivate(action.node)

	# # # instance
	
	constructor: (opts={})->
		parent = null
		children = opts.children || []

		@mode = Node.Modes.EXCLUSIVE

		id = opts.id
		mode = opts.mode ||= Node.Modes.EXCLUSIVE
		initialState = opts.initialState ||= Node.States.DEACTIVATED

		onActivatedAction = null
		onDeactivatedAction = null

		smRef = null
		# Create and return the state machine instance
		@sm = ->
			smRef ||= new StateMachine
				states: [Node.States.DEACTIVATED, Node.States.ACTIVATED]
				initialState: initialState
				transitions:
					activate:
						from: Node.States.DEACTIVATED
						to: Node.States.ACTIVATED
					deactivate: 
						from: Node.States.ACTIVATED
						to: Node.States.DEACTIVATED

		@sm().performTransition = (t) =>
			if t == Node.Transitions.ACTIVATE
				@beforeActivate()
				#@trigger 'activating', @
				@doActivate()
			else if t == Node.Transitions.DEACTIVATE
				@beforeDeactivate()
				#@trigger 'deactivating', @
				@doDeactivate()

		@prepare()
		
		@setParent = (node)->
			parent = node

		@parent = ->
			parent

		@addChild = (node) ->
			node.setParent(@)

			# node.bind 'onActivated', =>
			# 	@onChildActivated node
			# node.bind 'onDeactivated', =>
			# 	@onChildDeactivated node

			children.push node

		@removeChild = (node) ->
			children = children.filter (a) -> a isnt node
		
		@children = ->
			children

		@activatedChildren = ->
			children.filter (n) -> n.isActivated()
		
		@childById = (id) ->
			children.filter((n) -> n.id == id)[0]

		@descendantById = (id) ->
			child = childById(id)
			if child 
				return child

			for child in children
				descendant = child.getDescendantById(id)
				if descendant
					return descendant

		@siblings = () ->
			if parent
				return parent.children.filter (n)-> n isnt @

			return []

		@isActivated = ->
			@sm().currentState() == Node.States.ACTIVATED
		
		@isTransitioning = ->
			@sm().isTransitioning()
			
		@isBusy = ->
			return true if @isTransitioning()
	
			if mode == 'exclusive'
				return true if onActivatedAction or onDeactivatedAction
				return true if children.filter((n) -> n.isBusy()).length > 0

			return false

		@attemptTransition = (t) ->
			@sm().attemptTransition t

		@activate = -> Node.activate @
		@deactivate = -> Node.deactivate @
		
		# TODO
		#deactivateChildren: ->
		
		@onActivated = ->
			@sm().onTransitionComplete()
			Node.onNodeActivated @
			onActivatedAction = null

		@onDeactivated = ->
			@sm().onTransitionComplete()
			Node.onNodeDeactivated @
			onDeactivatedAction = null

	# Public
	prepare: ->

	beforeActivate: ->
	doActivate: -> @onActivated()

	beforeDeactivate: ->
	doDeactivate: -> @onDeactivated()

	onChildActivated: (child) ->

	onChildDeactivated: (child) ->

module.exports = Node
