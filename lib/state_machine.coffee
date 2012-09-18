class StateMachine extends Spine.Module
	@include Spine.Events
	
	constructor: ->
		@states = []
		@currentState = null
		@nextState = null
		@initialState = null
		@enabled = true
		
	addState: (state, isInitialState=false)->
		@states.push state
		if isInitialState
			@currentState = @initialState = state
	
	activate: (state)->
		if state in @states
			if @enabled && @nextState == null && state != @currentState
				@nextState = state
				@trigger "on_transition", this, @currentState, @nextState
				return true
				
		return false
	
	onTransitionComplete: ->
		@currentState = @nextState
		@nextState = null
		
	getCurrentState: ->
		@currentState
	
	getNextState: ->
		@nextState
		
	enable: ->
		@enabled = true
		
	disable: ->
		@enabled = false
	
	reset: ->
		@nextState = null
		@currentState = @initialState
