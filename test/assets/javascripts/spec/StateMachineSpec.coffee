describe "StateMachine", ->

	sm = null

	beforeEach ->
		StateMachine = require 'src/state_machine'
		sm = new StateMachine
			states: ['A', 'B']
			initialState: 'A'
			
			transitions:
				to_B:
					from: 'A'
					to: 'B'
				to_A:
					from: 'B'
					to: 'A'

	it 'should instantiate', ->
		expect(sm).not.toEqual null

	it 'should have 2 states', ->
		expect(sm.states.length == 2)

	it 'should have 2 transitions', ->
		expect(sm.transitions.length == 2)

	it 'should initially be at state A', ->
		expect(sm.currentState).toEqual 'A'

	describe "when in initial state A", ->

		it 'should allow transition from A -> B through to_B', ->
			expect(sm.attemptTransition('to_B')).toEqual true

		it 'should not allow transition from A -> A through to_A', ->
			expect(sm.attemptTransition('to_A')).not.toEqual true

		it 'should successfully transition from A -> B -> A through to_B, to_A, to_B', ->
			expect(sm.attemptTransition('to_B')).toEqual true
			expect(sm.isReady()).toEqual false
			
			expect(sm.onTransitionComplete()).toEqual true
			expect(sm.currentState).toEqual 'B'

			expect(sm.attemptTransition('to_A')).toEqual true
			expect(sm.isReady()).toEqual false

			expect(sm.onTransitionComplete()).toEqual true
			expect(sm.currentState).toEqual 'A'

	describe "when instantiating new instances", ->
		StateMachine = null

		beforeEach ->
			StateMachine = require 'src/state_machine'

		# it 'should not allow duplicate states', ->
		# 	expect( ->
		# 		failSm = new StateMachine
		# 			states: ['A', 'A']
		# 			initialState: 'A'

		# 	).toThrow "States must be distinct"
			
		it 'should not allow duplicate transitions', ->
			expect( ->
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
		
			).toThrow "Transitions must be distict"
