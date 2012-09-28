describe "Exo.Spine.Controller", ->

	Exo = null
	Controller = null
	test = null

	beforeEach ->
		Exo = require 'exo/exo'
		Controller = Exo.Spine.Controller

	it 'should instantiate', ->
		expect(new Controller).not.toEqual null

	describe 'when looking for Exo.Node functions', ->
		test = null

		beforeEach ->
			test = new Controller

		it "should have all class functions", ->
			undefineds = Controller.NodeClassFuncs.map((fn) -> Controller[fn]).filter((a) -> a is undefined).length
			expect(undefineds).toEqual 0

		it "should have all instance functions", ->
			undefineds = Controller.NodePrivilegedFuncs.map((fn) -> test[fn]).filter((a) -> a is undefined).length
			expect(undefineds).toEqual 0
	
	describe 'as a new instance', ->
		test = null

		beforeEach ->
			test = new Controller

		it "should be possible to activate() the Controller", ->
			test.activate()
			expect(test.isActivated()).toEqual true

		it "should not be possible to deactivate() the Controller", ->
			expect(test.deactivate()).toEqual false

	describe "as a parent and child", ->
		p = c = test = null

		beforeEach ->
			p = new Controller
			c = new Controller
			test = new Controller

			p.addChild test
			test.addChild c

		it 'should have a blocked lineage if a parent or child is transitioning', ->
			# Parent
			p.doActivate = c.doActivate = -> null
			p.activate()
			expect(Controller.lineageIsBusy(test)).toEqual true
			p.onActivated()
			expect(Controller.lineageIsBusy(test)).toEqual false
			# Child
			c.activate()
			expect(Controller.lineageIsBusy(test)).toEqual true
			c.onActivated()
			expect(Controller.lineageIsBusy(test)).toEqual false

		it 'should have an activated child if a child is activated', ->
			c.activate()
			expect(test.activatedChildren().length).toEqual 1