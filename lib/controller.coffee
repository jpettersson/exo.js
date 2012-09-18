class Controller

	States:
		DEACTIVATED: 0
		ACTIVATED: 1

	sm: ->
		#return or create the SM instance
		@statemachine || @statemachine = new StateMachine
			initialState: opts.initialState || States.DEACTIVATED
			states:
				States.ACTIVATED
				States.DEACTIVATED

	activate: ->
		@sm().transitionTo States.ACTIVATED

	doActivate: ->
		# must be overriden

	onActivated: ->
		@sm().onState ACTIVATED

	deactivate: ->
		@sm().transitionTo DEACTIVATED

	doDeactivate: ->
		# must be overriden

	onDeactivated: ->
		@sm().onState DEACTIVATED

module.exports = Controller