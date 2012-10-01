StateMachine = require 'state_machine'

# The Networked State Machine is capable of binding local transitions to an external 
# state machine event. 

class NetworkedStateMachine extends StateMachine

	connections: []
	transitionQueue: []
	
	# TYPE
	# parent 	
	# child

	# Map a local state to an external sm transition.
	connectChild: (localState, child, childTransition) ->
		# make sure we each connection is added only once.
		@connections.push
			type: 'child'
			sm: child
			localState: localState

	connectParent: (parent) ->
		@connections.push
			type 'parent'
			sm: parent

	# If the connection exists, remove it.
	disconnectChild: (sm, event, transition) ->
		#@connections = @children.filter (child) -> child isnt c

	onExternalEvent: (sm, event) ->
		# Do we have this connection?
		# Are we ready to perform the transition?
		@attemptTransition transition

	onTransitionComplete: ->
		if super

			# Tell our children/parents we are done!

			# We successfully entered a new state, do we have a pending transition
			# queued up?
			if @nextTransition
				# run this transition and remove it's ref.

	children: (state)->
		@connections.filter (conn) -> conn.type is 'child'

	parents: ->
		@connections.filter (conn) -> conn.type is 'parent'

	siblings: ->
		@connections.filter((conn) -> conn.type is 'parent').map((p) p.children().filter((c) -> c is not @))

module.exports = NetworkedStateMachine