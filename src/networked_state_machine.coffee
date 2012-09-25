StateMachine = require 'state_machine'

# The Networked State Machine is capable of binding local transitions to an external 
# state machine event. 

class NetworkedStateMachine extends StateMachine

	parent: null
	connections: []

	# route an external event to an intrinsic transition
	connectChild: (child, event, transition) ->
		# Does the transition exist locally?
		if @transitions[transition]
			# make sure we each connection is added only once.
			@connections.push
				sm: child
				event: event
				transition: transition

			# Give the child a reference to the single parent
			sm.parent = @

	disconnectChild: (sm, event, transition) ->
		# If it exists, remove the external connection.

	onExternalEvent: (sm, event) ->
		# Do we have this connection?
		# Are we ready to perform the transition?
		@attemptTransition transition

	onTransitionComplete: ->
		if super
			# We successfully entered a new state, do any of our parents/children care?

module.exports = NetworkedStateMachine