class GroupController extends Exo.Controller

	constructor: (opts={}) ->
		opts.mode = Exo.Controller.MODE_MULTI
		console.log opts.children
		super opts
		console.log @children

	onChildActivated: (child) ->
		#console.log "onChildActivated: #{@getActiveChildren().length} == #{@getChildren().length}"
		if @getActiveChildren().length == @getChildren().length
			@onChildrenActivated()

	onChildDeactivated: (child) ->
		if @getActiveChildren().length == 0
			@onChildrenDeactivated()

	onChildrenActivated: ->
		@trigger 'onChildrenActivated', @

	onChildrenDeactivated: ->
		@trigger 'onChildrenDeactivated', @

module.exports = GroupController