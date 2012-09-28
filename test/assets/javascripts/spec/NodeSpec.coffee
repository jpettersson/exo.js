describe "Node", ->

	Exo = Node = main = experience = share = overlay = null

	beforeEach ->
		Exo = require 'exo/exo'
		Node = Exo.Node
		
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
			expect(test.isActivated() && not test.isTransitioning()).toEqual true

		it 'should not deactivate()', ->
			expect(test.deactivate()).toEqual false

		it 'should be able to cycle deactivated -> activated -> deactivated', ->
			test.activate()
			expect(test.isActivated() && not test.isTransitioning()).toEqual true

			test.deactivate()
			expect(not test.isActivated() && not test.isTransitioning()).toEqual true

			test.activate()
			expect(test.isActivated() && not test.isTransitioning()).toEqual true

		it 'should be able to add and remove children', ->
			for i in [0..4]
				c = new Node
				test.addChild c
			expect(test.children().length).toEqual 5

			test.removeChild(test.children()[0])
			expect(test.children().length).toEqual 4

	describe "as a parent and child", ->
		p = c = test = null

		beforeEach ->
			p = new Node
			c = new Node
			test = new Node

			p.addChild test
			test.addChild c

		it 'should have a blocked lineage if a parent or child is transitioning', ->
			# Parent
			p.doActivate = c.doActivate = -> null
			p.activate()
			expect(Node.lineageIsBusy(test)).toEqual true
			p.onActivated()
			expect(Node.lineageIsBusy(test)).toEqual false
			# Child
			c.activate()
			expect(Node.lineageIsBusy(test)).toEqual true
			c.onActivated()
			expect(Node.lineageIsBusy(test)).toEqual false

		it 'should have an activated child if a child is activated', ->
			c.activate()
			expect(test.activatedChildren().length).toEqual 1

		describe "when configured as mode = Mode.EXCLUSIVE", ->
			it 'should only have one activated child at any time', ->
				c1 = new Node
				c2 = new Node 

				test.addChild c1
				test.addChild c2

				c.activate()
				c1.activate()
				c2.activate()

				expect(c2.isActivated() and not c.isActivated() and not c1.isActivated()).toEqual true

		describe "when configured as mode = Mode.MULTI", ->
			it 'should allow multiple activated children', ->
				test.mode = Node.Modes.MULTI
				
				c1 = new Node
				c2 = new Node

				test.addChild c1
				test.addChild c2

				c.activate()
				c1.activate()
				c2.activate()

				expect(c.isActivated() and c1.isActivated() and c2.isActivated()).toEqual true

