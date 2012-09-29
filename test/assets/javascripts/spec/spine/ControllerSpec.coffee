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
			test.onActivated()
			expect(test.isActivated()).toEqual true

		it "should not be possible to deactivate() the Controller", ->
			expect(test.deactivate()).toEqual false

	describe "as a parent and child", ->
		p = c = test = null

		beforeEach ->
			# Create our parent controller
			p = new Controller
			# Since controllers don't have default doActivate and doDeactivate functions
			# we need to create one that immidiately calls the onActivated callback.
			p.doActivate = -> @onActivated()

			# Create the child
			c = new Controller

			# Create or test controller, which will be both a child and a parent
			test = new Controller

			# Add test as a child of p and c as a child of test.
			p.addChild test
			test.addChild c

		it 'should have a blocked lineage if a parent or child is transitioning', ->
			# Activate test and since it has no default function for doActivate
			# expect the lineage to be blocked until we manually call onActivated()
			test.activate()
			
			expect(Controller.lineageIsBusy(test)).toEqual true
			test.onActivated()
			expect(Controller.lineageIsBusy(test)).toEqual false

			# Do the same test with the child of test, to make sure the lineage 
			# blocks in both directions.
			c.activate()
			expect(Controller.lineageIsBusy(test)).toEqual true
			c.onActivated()
			expect(Controller.lineageIsBusy(test)).toEqual false

		it 'should have an activated child if a child is activated', ->
			# Here we need test to automatically call the onActivated callback 
			# so we can test activating the entire lineage by calling activate()
			# on c.
			test.doActivate = -> @onActivated()

			c.activate()
			c.onActivated()
			
			# Expect test to have 1 activated child.
			expect(test.activatedChildren().length).toEqual 1

