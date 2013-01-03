class List extends Exo.Spine.Controller
	
	###
		
		TODO: 
		* Add option to auto select any item on render.
		* Allow the items to be Exo.Controller instances
			* Allow each item to have it's own in/out transitions.
			* Allow the entire list to have a single in/out transition.
		* Allow the items to be simple rendered views.
		
	###

	#debug: true
	
	constructor: (opts={}) ->
		opts.initialState ||= Exo.Node.States.ACTIVATED
		opts.mode ||= Exo.Node.Modes.MULTI
		super opts

	templateFor: (templates, item) ->
		templates[item.className]

	controllerFor: (controllers, item) ->
		controllers[item.className]

	render:(collection) ->
		@collection = collection
		if @template || @templates
			@renderTemplates(collection) 
		else if @controller || @controllers
			@renderControllers collection

	renderTemplates: (collection) ->
		templates = @templates || {default: @template}
		for item in collection 
			html = (templates.default or templates[item.constructor.className]).call(@, item)
			el = $(html).appendTo(@el)
			$(el).data('item', item)

	renderControllers: (collection) ->
		controllers = @controllers || {default: @controller}
		# Dynamically create child controllers
		
		#Also, change the actual div order!
		@deactivateAndKillOrphans(@children(), collection)

		for item, i in collection
			child = @getOrCreateChild item, controllers[item.constructor.className] or controllers.default

			child.listIndex = i
			child.moveTo i if child.moveTo
			child.activate()

		@trigger 'afterRender', @

		console.log "children before deactivate: #{@children().length}" if @debug

	getOrCreateChild: (item, controller) ->
		child = @childById(item.constructor.className + item.id)
		unless child
			child = new controller
			child.id = item.constructor.className + item.id
			@addChild child
			child.prepareWithModel item
			@append child
			console.log "child was created: #{child.id}" if @debug

		else
			console.log "child was found: #{child.id}" if @debug

		return child

	# Find children that have been deleted from the collection. Deactivate them, remove them from the DOM and make them available for GC.
	deactivateAndKillOrphans: (children, collection) ->
		orphans = children.filter (child) -> child.id not in collection.map (item) -> item.constructor.className + item.id
		for orphan in orphans
			console.log "Deactivate: #{orphan.id}" if @debug
			if orphan.isActivated() and not orphan.isBusy()
				orphan.bind 'onDeactivated', (controller) =>
					console.log "Remove child: #{controller.id}" if @debug
					@removeChild controller
					controller.release()

			orphan.deactivate()

	click: (e) ->
		if $(e.currentTarget).item
			item = $(e.currentTarget).item()
		else
			item = $(e.currentTarget).data('item')
		
		@trigger('select', item, $(e.currentTarget))
		true

Exo.Spine.List = List