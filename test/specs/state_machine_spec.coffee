expect = require 'expect.js'
Exo = require('../../src/exo')
StateMachine = Exo.StateMachine

describe 'StateMachine', ->
  describe 'when configured with states A, B and transitions to_B(A => B), to_A(B => A)', ->

    sm = null

    beforeEach ->
      sm = new StateMachine {
        states: ['A', 'B']
        initialState: 'A'
        transitions: 
          to_B:
            from: 'A'
            to: 'B'
          to_A:
            from: 'B'
            to: 'A'
      }

    it 'should have two states', ->
      expect sm.states().length == 2

    it 'should have 2 transitions', ->
      expect(sm.transitions().length == 2)

    it 'should initially be at state A', ->
      expect(sm.currentState()).to.equal 'A'

    it 'should allow transition from A -> B through to_B', ->
      expect(sm.attemptTransition('to_B')).to.equal true

    it 'should not allow transition from A -> A through to_A', ->
      expect(sm.attemptTransition('to_A')).to.not.equal true

    it 'should successfully transition from A -> B -> A through to_B, to_A', ->
      expect(sm.attemptTransition('to_B')).to.equal true
      expect(sm.isTransitioning()).to.equal true

      expect(sm.onTransitionComplete()).to.equal true
      expect(sm.currentState()).to.equal 'B'

      expect(sm.attemptTransition('to_A')).to.equal true
      expect(sm.isTransitioning()).to.equal true

      expect(sm.onTransitionComplete()).to.equal true
      expect(sm.currentState()).to.equal 'A'

describe "when instantiating new instances", ->
  it 'should not allow duplicate states', ->
    expect( ->
      # Two states are identical.
      failSm = new StateMachine
        states: ['A', 'A']
        initialState: 'A'
    ).to.throwException StateMachine.E_DUPLICATE_STATE

  it 'should not allow duplicate transitions', ->
    expect( ->
      # Two transitions are identical.
      failSm = new StateMachine
        states: ['A', 'B']
        initialState: 'A'
        transitions:
          t0:
            from: 'A'
            to: 'B'
          t1:
            from: 'A'
            to: 'B'
    ).to.throwException StateMachine.E_DUPLICATE_TRANSITION

  it 'should not allow undefined states', ->
    expect( ->
      # t1 contains and undefined to state.
      failSm = new StateMachine
        states: ['A', 'B']
        initialState: 'A'
        transitions:
          t0:
            from: 'A'
            to: 'B'
          t1:
            from: 'A'
            to: 'C'
    ).to.throwException StateMachine.E_UNDEFINED_STATE