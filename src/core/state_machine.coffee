class StateMachine
  
  @E_DUPLICATE_STATE = "E_DUPLICATE_STATE: States must be distinct"
  @E_DUPLICATE_TRANSITION = "E_DUPLICATE_TRANSITION: Transitions must be distinct"
  @E_UNDEFINED_STATE = "E_UNDEFINED_STATE: All states used in transitions must be defined in the states array"

  constructor: (opts={})->

    states = opts.states || []
    transitions = opts.transitions || []

    # Validate inputs
    do validate = ->
      unique = (a)->
        output = {}
        output[a[key]] = a[key] for key in [0...a.length]
        value for key, value of output

      if states.length != unique(states).length
        throw StateMachine.E_DUPLICATE_STATE

      tCheck = []
      sCheck = []
      for transition, tStates of transitions
        tCheck.push "#{tStates.from}->#{tStates.to}"
        sCheck.push tStates.to
        sCheck.push tStates.from

      if unique(sCheck).length > states.length
        throw StateMachine.E_UNDEFINED_STATE

      if tCheck.length != unique(tCheck).length
        throw StateMachine.E_DUPLICATE_TRANSITION
      
    # Setup

    currentState = initialState = opts.initialState || null
    currentTransition = null

    @attemptTransition = (transitionName) ->
      if not @isTransitioning() and @transitionIsPossible(transitionName)
        currentTransition = transitions[transitionName]
        @performTransition(transitionName)
        true
      else
        false

    @isTransitioning = ->
      currentTransition != null

    @transitionIsPossible = (transitionName) ->
      if transition = transitions[transitionName]
        currentState != transition.to && currentState == transition.from
      else 
        false
      
    @onTransitionComplete = ->
      if currentTransition
        currentState = currentTransition.to
        currentTransition = null
        true
      else 
        false

    @states = ->    
      states

    @transitions = ->
      transitions

    @currentState = ->
      currentState

    @initialState = ->
      initialState

  performTransition: (transitionName) ->

Exo.StateMachine = StateMachine