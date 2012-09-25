NetworkedStateMachine = require 'networked_state_machine'

class Controller extends Spine.Controller
	
	constructor: (opts={})->

		@sm().performTransition = (transition) =>
			methName = transition.charAt(0).toUpperCase() + transition.slice(1)
			@["do#{methName}"]

		super opts

	# Create and return the state machine instance
	sm: ->
		@smRef ||= new NetworkedStateMachine
			transitions:
				activate:
					from: 'deactivated'
					to: 'activated'
				deactivate: 
					from: 'activated'
					to: 'deactivated'
			initialState: 'deactivated'

	addChild: (controller) ->
		@sm().connectChild controller.sm(), 'activated', ''

	removeChild: (controller) ->
		@sm().disconnectChild controller.sm()

	activate: ->
		@sm().attemptTransition 'activate'

	doActivate: ->
		# Should be defined in the extending class

	onActivated: ->
		@sm().onTransitionComplete()

	deactivate: ->
		@sm().attemptTransition 'activate'

	doDeactivate: ->
		# Should be defined in the extending class

	onDeactivated: ->
		@sm().onTransitionComplete()		