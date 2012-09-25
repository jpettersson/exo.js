StateMachine = require 'state_machine'

# The Networked State Machine is capable of binding local transitions to an external 
# state machine event. 

class NetworkedStateMachine extends StateMachine

	connections: []

	# route an external event to an intrinsic transition
	connect: (sm, event, transition) ->
		# Does the transition exist locally?
		if @transitions[transition]
			# make sure we each connection is added only once.
			@connections.push
				sm: sm
				event: event
				transition: transition

	disconnect: (sm, event, transition) ->
		# If it exists, remove the external connection.

	onExternalEvent: (sm, event) ->
		# Do we have this connection?
		# Are we ready to perform the transition?
		@attemptTransition transition

module.exports = NetworkStateMachine