describe "Spine: Exo.Controller", ->

	Exo = null
	Controller = null
	test = null

	beforeEach ->
		Exo = require 'exo/exo'
		Controller = Exo.Spine.Controller

	it 'should instantiate', ->
		expect(new Controller).not.toEqual null

	describe 'when testing for Exo.Node functions', ->
		test = null

		beforeEach ->
			test = new Controller

		it "should have all class functions", ->
			undefineds = Controller.NodeClassFuncs.map((fn) -> Controller[fn]).filter((a) -> a is undefined).length
			expect(undefineds).toEqual 0

		it "should have all instance functions", ->
			undefineds = Controller.NodeInstanceFuncs.map((fn) -> test[fn]).filter((a) -> a is undefined).length
			expect(undefineds).toEqual 0
	
	describe 'as a new instance', ->

		it "should be possible to activate() the Controller", ->
			test.activate()
			expect(test.isActivated()).toEqual true

		it "should not be possible to deactivate() the Controller", ->
			expect(test.deactivate()).toEqual false

