Spine = @Spine or require('spine')

class Controller extends Spine.Controller

	@Events:
		ON_ACTIVATED: 'onActivated'
		ON_DEACTIVATED: 'onDeactivated'
		BEFORE_ACTIVATE: 'beforeActivate'
		BEFORE_DEACTIVATE: 'beforeDeactivate'

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
		'setParent'
		'parent'
		#'addChild'
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
		'toggle'
		'setMode'
		'mode'
		'setOnActivatedAction'
		'onActivatedAction'
		'setOnDeactivatedAction'
		'onDeactivatedAction'
		'deactivateChildren'
		# These are special, since we want to override them override them on 
		# this object, explain this better.
		#'onActivated'
		#'onDeactivated'
	]	

	@NodePublicFuncs = [
		'beforeActivate'
		'doActivate'
		'beforeDeactivate'
		'doDeactivate'
		'onChildActivated'
		'onChildDeactivated'
	]

	constructor: (opts={}) ->
		# keep a private reference to a Node instance.
		node = new Exo.Node opts
		that = @
		
		@id = node.id

		@node = ()->
			node

		# Map the Node Class functions to our Class.
		for func in Controller.NodeClassFuncs
			a = (fn) ->
				# add function as a prop on Controller
				Controller[fn] = (params...) -> 
					if params
						# if the param is 'that', convert it to the Node instance reference.
						modParams = params.map (p) -> if p is node then that else p
						# call the Class function on Node with our modified params and return.
						Exo.Node[fn].apply(Exo.Node, modParams)
					else
						# call the class function on Node without any params.
						Exo.Node[fn]()
					
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

			# node['beforeActivate'] = (params...) ->
			# 	that['proxyBeforeActivate'].apply that, params

			# node['beforeDeactivate'] = (params...) ->
			# 	that['proxyBeforeDeactivate'].apply that, params

		# Hack hack.. make sure we always add the Controller instance and not the Node.
		@addChild = (controller) ->
			controller.setParent(@)

			node.addChild controller
			@onChildAdded controller

		delete opts.initialState if opts.initialState
		delete opts.mode if opts.mode
		delete opts.children if opts.children

		super opts
		@prepare()

	# Public
	prepare: ->

	proxyBeforeActivate: ->
		@trigger Controller.Events.BEFORE_ACTIVATE, @
		@beforeActivate()

	beforeActivate: ->

	doActivate: -> 
	onActivated: -> 
		@node().onActivated()
		@trigger Controller.Events.ON_ACTIVATED, @

	proxyBeforeDeactivate: ->
		@trigger Controller.Events.BEFORE_DEACTIVATE, @
		@beforeDeactivate()

	beforeDeactivate: ->

	doDeactivate: -> 
	onDeactivated: -> 
		@node().onDeactivated()
		@trigger Controller.Events.ON_DEACTIVATED, @

	onChildAdded: (child) ->
	onChildActivated: (child) ->
	onChildDeactivated: (child) ->

Exo?.Spine ||= {}
Exo?.Spine.Controller = Controller
module?.exports = Controller