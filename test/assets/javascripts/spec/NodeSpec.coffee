describe "Node", ->

	Exo = Node = main = experience = share = overlay = null

	beforeEach ->
		Exo = require 'exo/exo'
		Node = Exo.Node
		# main = new Node
		# experience = new Node
		# share = new Node
		# overlay = new Node

	it 'should instantiate', ->
		expect(new Node).not.toEqual null

	describe "as a new instance", ->
		test = null

		beforeEach ->
			test = new Node

		it 'should be deactivated', ->
			expect(test.isActivated()).toEqual false

		it 'should not be transitioning', ->
			expect(test.isTransitioning()).toEqual false

		it 'should activate()', ->
			expect(test.activate()).toEqual true

		it 'should not deactivate()', ->
			expect(test.deactivate()).toEqual false