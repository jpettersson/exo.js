class StateMachine

	constructor: (opts={})->
		states = opts.states || []
		transitions = opts.transitions || []

		currentState = initialState = opts.initialState || null

		# @attemptTransition: (transitionName) ->
		# 	if @isReady() and @transitionIsPossible(transitionName)
		# 		@currentTransition = @transitions[transitionName]
		# 		@performTransition(transitionName)
		# 		true
		# 	else
		# 		false

		# @isReady: ->
		# 	@currentTransition is null

		# @transitionIsPossible: (transitionName) ->
		# 	if transition = @transitions[transitionName]
		# 		@currentState != transition.to && @currentState == transition.from
		# 	else 
		# 		false

		# @performTransition: (transitionName) ->
			
		# # Time to complete the transition and free up the state machine
		# @onTransitionComplete: ->
		# 	if @currentTransition
		# 		@currentState = @currentTransition.to
		# 		@currentTransition = null
		# 		true
		# 	else 
		# 		false

		@states: ->

		@transitions: ->

		@currentState: ->

		@initialState: ->

module.exports = StateMachine