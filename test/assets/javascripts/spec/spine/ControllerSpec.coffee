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

		classFuncs = [	
			'activate'
			'deactivate'
			'toggle'
			'lineageIsBusy'
			'onNodeActivated'
			'onNodeDeactivated'
			'processAction' 
		]

		it "should have all #{classFuncs.length} class functions", ->
			undefineds = classFuncs.map((fn) -> Controller[fn]).filter((a) -> a is undefined).length
			expect(undefineds).toEqual 0

		instanceFuncs = [
			# protected
			'sm'
			'prepare'
			'setParent'
			'addChild'
			'removeChild'
			'children'
			'activatedChildren'
			'childById'
			'descendantById'
			'siblings'
			'isActivated'
			'isTransitioning'
			'isBusy'
			'attemptTransition'
			'activate'
			'deactivate'
			'onActivated'
			'onDeactivated'
			# public
			'prepare'
			'beforeActivate'
			'doActivate'
			'beforeDeactivate'
			'doDeactivate'
			'onChildActivated'
			'onChildDeactivated'
		]

		it "should have all #{instanceFuncs.length} instance functions", ->
			undefineds = instanceFuncs.map((fn) -> test[fn]).filter((a) -> a is undefined).length
			expect(undefineds).toEqual 0
	
	describe 'as a new instance', ->

		it "should be possible to activate() the Controller", ->
			test.activate()
			expect(test.isActivated()).toEqual true

		it "should not be possible to deactivate() the Controller", ->
			expect(test.deactivate()).toEqual false

