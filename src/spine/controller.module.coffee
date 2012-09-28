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

	@NodeInstanceFuncs = [
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
		# public
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

		# Map the Node instance functions on our object to 
		# an encapsulated instance of Node.
		for func in Controller.NodeInstanceFuncs
			a = (fn) ->
				# add function as a prop on the instance 'that'
				that[func] = (params...) ->
					# call the instance function on node and return.
					node[fn].apply(node, params)
			a(func)

module.exports = Controller