Node = require '../node'

NodeClassFuncs = [
	'activate'
	'deactivate'
	'toggle'
	'lineageIsBusy'
	'onNodeActivated'
	'onNodeDeactivated'
	'processAction'
]

NodeInstanceFuncs = [
	# protected
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

class Controller extends Spine.Controller

	constructor: (opts={}) ->
		super
		
		node = new Node
		that = @
		
		# Map the Node Class functions to our Class.
		for func in NodeClassFuncs
			a = (fn) ->
				Controller[fn] = (params...) -> 
					# if the param is @, convert it to the Node instance
					if params
						modParams = params.map (p) -> if p is that then node else p
						Node[fn].apply(Node, modParams)
					else
						Node[fn]()
					
			a(func)

		# Map the Node instance functions on our object to 
		# an encapsulated instance of Node.
		for func in NodeInstanceFuncs
			a = (fn) ->
				that[func] = (params...) ->
					node[fn].apply(node, params)
			a(func)

module.exports = Controller