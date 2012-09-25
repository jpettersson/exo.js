NetworkedStateMachine = require 'networked_state_machine'

class Controller extends Spine.Controller
	
	constructor: (opts={})->
		
		@sm = new NetworkedStateMachine
			

		@sm.performTransition = (transition) ->
			# Do something here
			#@trigger 'perform_transition', transition

		super opts


	activate: ->

	doActivate: ->

	onActivated: ->

	deactivate: ->

	doDeactivate: ->

	onDeactivated: ->

