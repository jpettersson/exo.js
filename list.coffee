Spine ?= require('spine')
Exo ?= require('controller')

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
		super $.extend(options, {mode: Exo.Controller.MODE_MULTI, defaultState: Exo.Controller.STATE_ACTIVATED})
		
	render:(collection) ->
		if @template
			# Render HAML view. Requires the wrapping Array for some reason.
			# TODO: Fix this so that the list works with other templating engines.
			@html @template(collection)								
		else if @controller
			# Dynamically create child controllers
			for item in collection
				child = @getOrCreateChild item
				child.activate()

			console.log "children before deactivate: #{@getChildren().length}" if @debug

			@deactivateAndKillOrphans(@getChildren(), collection)
			@orderChildren(@getChildren(), collection)

	getOrCreateChild: (item) ->
		child = @getChildById(item.id)
		unless child
			child = new @controller
			child.id = item.id
			@addChild child
			child.prepareWithModel item
			@append child
			console.log "child was created: #{child.id}" if @debug

		else
			console.log "child was found: #{child.id}" if @debug

		return child

	# Find children that have been deleted from the collection. Deactivate them, remove them from the DOM and make them available for GC.
	deactivateAndKillOrphans: (children, collection) ->
		orphans = children.filter (child) -> child.id not in collection.map (item) -> item.id
		for orphan in orphans
			console.log "Deactivate: #{orphan.id}" if @debug
			if orphan.isActive() and not orphan.isBusy()
				orphan.bind 'onDeactivated', (controller) =>
					console.log "Remove child: #{controller.id}" if @debug
					@removeChild controller
					controller.release()

			orphan.deactivate()

	# Reorder the children in the DOM according to the collection order.
	orderChildren: (children, collection) ->

	click: (e) ->
		item = $(e.currentTarget).item()
		@trigger('change', item, $(e.currentTarget))
		true

module.exports = List