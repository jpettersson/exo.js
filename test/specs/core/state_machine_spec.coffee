StateMachine = Exo.StateMachine

describe 'StateMachine', ->
  describe 'when configured with states a, b and transitions to_b(a => b), to_a(b => a)', ->

    beforeEach ->
      sm = new StateMachine
        states: ['a', 'b']
        transitions: 
          to_b:
            from: 'a'
            to: 'b'
          to_a:
            from: 'b'
            to: 'a'

    it 'should have two states', ->
      expect sm.states().length == 2