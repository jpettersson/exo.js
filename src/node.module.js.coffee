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
				if parent.mode() == Node.Modes.EXCLUSIVE
					if sibling = parent.activatedChildren()[0]
						sibling.setOnDeactivatedAction
							node: node
							transition: Node.Transitions.ACTIVATE
						return Node.deactivate sibling
			else
				parent.setOnActivatedAction
					node: node
					transition: Node.Transitions.ACTIVATE
				return Node.activate parent

		node.attemptTransition Node.Transitions.ACTIVATE

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
		if action = node.onActivatedAction()
			@processAction action

	@onNodeDeactivated: (node)->
		node.parent().onChildDeactivated(node) if node.parent()
		if action = node.onDeactivatedAction()
			@processAction action

	@processAction: (action) ->
		if action.transition == Node.Transitions.ACTIVATE
				@activate(action.node)
			else if action.transition == Node.Transitions.DEACTIVATE
				@deactivate(action.node)

	# Instance functions
	
	constructor: (opts={})->
		parent = null
		children = []

		# Did we receive an array of children from the opts hash?
		if opts.children
			for node in opts.children
				node.setParent @
			children = opts.children

		id = opts.id
		mode = opts.mode ||= Node.Modes.EXCLUSIVE
		initialState = opts.initialState ||= Node.States.DEACTIVATED

		onActivatedAction = null
		onDeactivatedAction = null

		# Create and return the state machine instance
		smRef = null
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

		# Add a callback lambda to the SM and map the two  
		# state transitions to methods in this class.
		@sm().performTransition = (t) =>
			if t == Node.Transitions.ACTIVATE
				@beforeActivate()
				@doActivate()
			else if t == Node.Transitions.DEACTIVATE
				@beforeDeactivate()
				@doDeactivate()

		@setOnActivatedAction = (action) ->
			onActivatedAction = action

		@onActivatedAction = ->
			onActivatedAction

		@setOnDeactivatedAction = (action) ->
			onDeactivatedAction = action

		@onDeactivatedAction = ->
			onDeactivatedAction

		@setMode = (m) ->
			mode = m

		@mode = () ->
			mode

		@setParent = (node) ->
			parent = node

		@parent = ->
			parent

		@addChild = (node) ->
			node.setParent(@)
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
				return parent.children().filter (n)-> n isnt @

			return []

		@isActivated = ->
			@sm().currentState() == Node.States.ACTIVATED
		
		@isTransitioning = ->
			@sm().isTransitioning()
			
		@isBusy = ->
			return true if @isTransitioning()
	
			if @mode() == Node.Modes.EXCLUSIVE
				# Why was this in here? It didn't work.. check old implementation!
				# return true if @onActivatedAction() != null or @onDeactivatedAction() != null
				return true if children.filter((n) -> n.isBusy()).length > 0

			return false

		@attemptTransition = (t) ->
			@sm().attemptTransition t

		@activate = -> Node.activate @
		@deactivate = -> Node.deactivate @
		@toggle = -> Node.toggle @
		
		# TODO
		@deactivateChildren = ->
			for child in @children()
				child.deactivate()

		@onActivated = ->
			@sm().onTransitionComplete()
			Node.onNodeActivated @
			@setOnActivatedAction null

		@onDeactivated = ->
			@sm().onTransitionComplete()
			Node.onNodeDeactivated @
			@setOnDeactivatedAction null

	beforeActivate: ->
	doActivate: -> @onActivated()

	beforeDeactivate: ->
	doDeactivate: -> @onDeactivated()

	onChildActivated: (child) ->

	onChildDeactivated: (child) ->

module.exports = Node
