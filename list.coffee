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
	
	#constructor: (options={}) ->
	#	@template = options.template
	#	super
	#		#multipleActiveChildren: true
	#		defaultState: options.defaultState or Exo.Controller.STATE_ACTIVATED
			
	prepare: ->
		
	render:(collection) ->
		if @template
			# Render HAML view. Requires the wrapping Array for some reason.
			# TODO: Fix this so that the list works with other templating engines.
			@html @template(collection)								
		else if @controller
			# Dynamically create child controllers
			for item in collection
				child = @getOrCreateChild item

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

		return child

	# Find children that have been deleted from the collection. Deactivate them, remove them from the DOM and make them available for GC.
	deactivateAndKillOrphans: (children, collection) ->

	# Reorder the children in the DOM according to the collection order.
	orderChildren: (children, collection) ->

	click: (e) ->
		item = $(e.currentTarget).item()
		@trigger('change', item, $(e.currentTarget))
		true

module.exports = List