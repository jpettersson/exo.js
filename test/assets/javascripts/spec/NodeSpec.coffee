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

	describe 'when we have a node', ->

		beforeEach ->
			test = new Node

		it 'should die', ->
