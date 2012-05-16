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
		console.log "Render"
		console.log collection
		@html @template(collection)								# Render HAML view. Requires the wrapping Array for some reason.
		console.log @el											# TODO: Fix this so that the list works with other templating engines.
	
	click: (e) ->
		item = $(e.currentTarget).item()
		@trigger('change', item, $(e.currentTarget))
		true

module.exports = List