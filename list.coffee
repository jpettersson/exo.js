Spine = require('spine')
#Exo = require('controller')

class List extends Exo.Controller
	
	###
		
		TODO: 
		* Add option to auto select any item on render.
		* Allow the items to be Exo.Controller instances
			* Allow each item to have it's own in/out transitions.
			* Allow the entire list to have a single in/out transition.
		* Allow the items to be simple rendered views.
		
	###
	
	constructor: (options={}) ->
		options.defaultState ||= Exo.Controller.STATE_ACTIVATED
		options.mode ||= Exo.Controller.MODE_MULTI
		super options
	
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
		@html collection.map (item) => (templates.default or templates[item.getClassName()]).call(@, [item])[0]

	renderControllers: (collection) ->
		controllers = @controllers || {default: @controller}
		# Dynamically create child controllers
		
		#Also, change the actual div order!
		@deactivateAndKillOrphans(@getChildren(), collection)

		for item, i in collection
			child = @getOrCreateChild item, controllers[item.getClassName()] or controllers.default
			
			child.listIndex = i
			child.moveTo i if child.moveTo
			child.activate()

		@trigger 'afterRender', @

		console.log "children before deactivate: #{@getChildren().length}" if @debug

	getOrCreateChild: (item, controller) ->
		child = @getChildById(item.getClassName() + item.id)
		unless child
			child = new controller
			child.id = item.getClassName() + item.id
			@addChild child
			child.prepareWithModel item
			@append child
			console.log "child was created: #{child.id}" if @debug

		else
			console.log "child was found: #{child.id}" if @debug

		return child

	# Find children that have been deleted from the collection. Deactivate them, remove them from the DOM and make them available for GC.
	deactivateAndKillOrphans: (children, collection) ->
		orphans = children.filter (child) -> child.id not in collection.map (item) -> item.getClassName() + item.id
		for orphan in orphans
			console.log "Deactivate: #{orphan.id}" if @debug
			if orphan.isActive() and not orphan.isBusy()
				orphan.bind 'onDeactivated', (controller) =>
					console.log "Remove child: #{controller.id}" if @debug
					@removeChild controller
					controller.release()

			orphan.deactivate()

	click: (e) ->
		item = $(e.currentTarget).item()
		@trigger('select', item, $(e.currentTarget))
		true

module.exports = List