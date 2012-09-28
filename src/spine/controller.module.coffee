Node = require '../node'

class Controller extends Spine.Controller

	@NodeClassFuncs = [
		'activate'
		'deactivate'
		'toggle'
		'lineageIsBusy'
		'onNodeActivated'
		'onNodeDeactivated'
		'processAction'
	]

	@NodePrivilegedFuncs = [
		# privileged
		'sm'
		'prepare'
		'setParent'
		'addChild'
		'removeChild'
		'children'
		'activatedChildren'
		'childById'
		'descendantById'
		'siblings'
		'isActivated'
		'isTransitioning'
		'isBusy'
		'attemptTransition'
		'activate'
		'deactivate'
		'onActivated'
		'onDeactivated'
	]	

	@NodePublicFuncs = [
		'prepare'
		'beforeActivate'
		'doActivate'
		'beforeDeactivate'
		'doDeactivate'
		'onChildActivated'
		'onChildDeactivated'
	]

	constructor: (opts={}) ->
		super
		
		# keep a private reference to a Node instance.
		node = new Node
		that = @
		
		@node = ()->
			node

		# Map the Node Class functions to our Class.
		for func in Controller.NodeClassFuncs
			a = (fn) ->
				# add function as a prop on Controller
				Controller[fn] = (params...) -> 
					if params
						# if the param is 'that', convert it to the Node instance reference.
						modParams = params.map (p) -> if p is that then node else p
						# call the Class function on Node with our modified params and return.
						Node[fn].apply(Node, modParams)
					else
						# call the class function on Node without any params.
						Node[fn]()
					
			a(func)

		# Map the Node privileged functions on our object to 
		# an encapsulated instance of Node.
		for func in Controller.NodePrivilegedFuncs
			a = (fn) ->
				# add function as a prop on the instance 'that'
				that[fn] = (params...) ->	#WARNING: this was func before... and it worked :S
					# call the instance function on node and return.
					node[fn].apply(node, params)
			a(func)

		# We have to invert our reason when dealing with the public functions of node. 
		# These we want to map to functions on 'that'
		for func in Controller.NodePublicFuncs
			a = (fn) ->
				node[fn] = (params...) ->
					that[fn].apply(that, params)
			a(func)

	# Public
	prepare: ->

	beforeActivate: ->
	doActivate: -> @node().onActivated()

	beforeDeactivate: ->
	doDeactivate: -> @node().onDeactivated()

	onChildActivated: (child) ->

	onChildDeactivated: (child) ->


module.exports = Controller