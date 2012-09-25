class StateMachine

	currentState: null
	currentTransition: null

	# opts.transitions		Object of transition & state names
	# opts.initialState		The initial state
	constructor: (opts)->
		@transitions = opts.transitions
		@currentState = @initialState = opts.initialState

		# create state transition methods dynamically	
		for transition, states of @transitions
			@[transition] = ()-> @attemptTransition transition

	attemptTransition: (transition) ->
		if @isReady() and @transitionIsPossible(transition)
			@performTransition(transition)

	isReady: ->
		@currentTransition is null

	transitionIsPossible: (transition) ->
		# If we have no initial state or, if there's an edge between current state and the target state.
		@currentState is null or transition.from == @currentState

	# Override this? Broadcast event?
	performTransition: (transition) ->

	# Time to complete the transition and free up the state machine
	onTransitionComplete: ->
		if @currentTransition
			@currentState = @currentTransition.to
			@currentTransition = null
			true

module.exports = StateMachine