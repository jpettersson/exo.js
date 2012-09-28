# Exo.Node can be used to build an arbitrarily large directed graph
# of ui components that will be controlled hierarchical from the top down.

StateMachine = require './state_machine'

class Node #extends Spine.Module

	#@include Spine.Events

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
		return if @lineageIsBusy(node) or node.isActivated()

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

	@onNodeActivated: (node)->
		if action = node.onActivatedAction
			@processAction action

	@onNodeDeactivated: (node)->
		if action = node.getOnDeactivatedAction()
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

		@addChild = (node) ->
			node.setParent(@)

			# node.bind 'onActivated', =>
			# 	@onChildActivated node
			# node.bind 'onDeactivated', =>
			# 	@onChildDeactivated node

			children.push node

		@removeChild = (node) ->
			children = children.filter (a) -> a isnt node
		
		@activatedChildren = ->
			children().filter (n) -> n.isActivated()
		
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
			sm().currentState == Node.States.ACTIVATED
		
		@isTransitioning = ->
			sm().nextState != null
			
		@isBusy = ->
			return true if isTransitioning()
	
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
			sm().onTransitionComplete()
			Node.onNodeActivated @
			onActivatedAction = null
			#@trigger 'onActivated', @

		@onDeactivated = ->
			sm().onTransitionComplete()
			Node.onNodeDeactivated @
			onDeactivatedAction = null
			#@trigger 'onDeactivated', @

	# Public
	prepare: ->

	beforeActivate: ->
	doActivate: -> # Should be defined in the extending class

	beforeDeactivate: ->
	doDeactivate: -> # Should be defined in the extending class

	onChildActivated: (child) ->

	onChildDeactivated: (child) ->

module.exports = Node
