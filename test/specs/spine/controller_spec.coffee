describe "Exo.Spine.Controller at instantiation", ->
  it 'should call prepare', (done)->
    called = false
    class Test extends Exo.Spine.Controller
      prepare: ->
        called = true
        expect(called).to.equal true
        done()

    new Test()

describe "Exo.Spine.Controller as a new instance", ->
  test = null

  beforeEach ->
    test = new Exo.Spine.Controller

  it 'should be possible to set nodeId', ->
    test.setNodeId('banana')
    expect(test.nodeId()).to.equal 'banana'

  it 'should be deactivated', ->
    expect(test.isActivated()).to.equal false

  it 'should not be transitioning', ->
    expect(test.isTransitioning()).to.equal false

  it 'should activate()', ->
    expect(test.activate()).to.equal true
    expect(test.isActivated() && not test.isTransitioning()).to.equal true

  it 'should not deactivate()', ->
    expect(test.deactivate()).to.equal false

  it 'should be able to cycle deactivated -> activated -> deactivated', ->
    test.activate()
    expect(test.isActivated() && not test.isTransitioning()).to.equal true

    test.deactivate()
    expect(not test.isActivated() && not test.isTransitioning()).to.equal true

    test.activate()
    expect(test.isActivated() && not test.isTransitioning()).to.equal true

  it 'should be able to add and remove children', ->
    for i in [0..4]
      c = new Exo.Spine.Controller
      test.addChild c
    expect(test.children().length).to.equal 5

    test.removeChild(test.children()[0])
    expect(test.children().length).to.equal 4

  it 'should not allow passing self to addChild', ->
    expect( ->
      test.addChild(test)
    ).to.throw /ExoReferenceError/

  it 'should not allow passing null to addChild', ->
    expect( ->
      test.addChild(null)
    ).to.throw /ExoReferenceError/

  it 'should not allow passing undefined to addChild', ->
    expect( ->
      test.addChild()
    ).to.throw /ExoReferenceError/

  it 'should not allow a child to activate it if opts.childrenCanActivate = false', ->
    test = new Exo.Spine.Controller
      childrenCanActivate: false

    c = new Exo.Spine.Controller
    test.addChild c
    c.activate()

    expect(c.isActivated()).to.equal false
    expect(test.isActivated()).to.equal false

  it "should allow a child to activate if it's activated and opts.childrenCanActivate = false", ->
    test = new Exo.Spine.Controller
      childrenCanActivate: false

    c = new Exo.Spine.Controller
    test.addChild c
    test.activate()
    c.activate()

    expect(c.isActivated()).to.equal true
    expect(test.isActivated()).to.equal true

  it 'should throw "Exo: Incompatible object" when invalid objects are passed to node.addChild'

  it 'should trigger "onActivated" and pass itself when activated', (done)->
    test.bind 'onActivated', (controller)->
      expect(controller.nodeId()).to.equal test.nodeId()
      done()

    test.activate()

  it 'should trigger "onDectivated" and pass itself when deactivated', (done)->
    test.bind 'onDeactivated', (controller)->
      expect(controller.nodeId()).to.equal test.nodeId()
      done()

    test.activate()
    test.deactivate()

  it 'should trigger "beforeActivate" when activating', (done)->
    test.bind 'beforeActivate', (controller)->
      expect(controller.nodeId()).to.equal test.nodeId()
      done()

    test.activate()

  it 'should trigger "beforeActivate" when activating', (done)->
    test.bind 'beforeDeactivate', (controller)->
      expect(controller.nodeId()).to.equal test.nodeId()
      done()

    test.activate()
    test.deactivate()

describe 'Exo.Spine.Controller as a child and sibling', ->
  p = test = s = null

  beforeEach ->
    p = new Exo.Spine.Controller
    test = new Exo.Spine.Controller
    s = new Exo.Spine.Controller

    p.addChild test
    p.addChild s

  it "should be able to access it's parent", ->
    expect(test.parent()).to.be.an('object')

  it "should be able to activate it's parent", ->
    test.activate()
    expect(test.isActivated() and p.isActivated()).to.equal true

  it "should be able to acces it's sibling", ->
    expect(test.siblings()).to.be.an('array')
    expect(test.siblings().length).to.equal 1

  it "should be able to activate by deactivating it's sibling", ->
    s.activate()
    test.activate()
    expect(test.isActivated() and p.isActivated() and not s.isActivated()).to.equal true

  it "should be possible to fetch a child by id", ->
    expect(p.childById(s.nodeId())).to.be.an('object')
    expect(p.childById(s.nodeId()).nodeId()).to.equal s.nodeId()

  it "should be possible to fetch a descendant by id", ->
    expect(p.descendantById(s.nodeId())).to.be.an('object')
    expect(p.descendantById(s.nodeId()).nodeId()).to.equal s.nodeId()

describe "Exo.Spine.Controller as a parent and child", ->
  p = c = test = null

  beforeEach ->
    p = new Exo.Spine.Controller
    c = new Exo.Spine.Controller
    test = new Exo.Spine.Controller
    p.addChild test
    test.addChild c

  it 'should have a blocked lineage if a parent or child is transitioning', ->
    # Parent

    p.doActivate = c.doActivate = -> null
    p.activate()
    expect(Exo.Node.lineageIsBusy(test.node())).to.equal true
    p.onActivated()
    expect(Exo.Node.lineageIsBusy(test)).to.equal false
    # Child
    c.activate()
    expect(Exo.Node.lineageIsBusy(test)).to.equal true
    c.onActivated()
    expect(Exo.Node.lineageIsBusy(test)).to.equal false

  it 'should have an activated child if a child is activated', ->
    c.activate()
    expect(test.activatedChildren().length).to.equal 1

  it 'should only have one activated child at any time when mode = Mode.EXCLUSIVE', ->
    c1 = new Exo.Spine.Controller
    c2 = new Exo.Spine.Controller

    test.addChild c1
    test.addChild c2

    c.activate()
    c1.activate()
    c2.activate()

    expect(c2.isActivated() and not c.isActivated() and not c1.isActivated()).to.equal true

  it 'should allow multiple activated children when mode = Mode.MULTI', ->
    test.setMode Exo.Node.Modes.MULTI

    c1 = new Exo.Spine.Controller
    c2 = new Exo.Spine.Controller

    test.addChild c1
    test.addChild c2

    c.activate()
    c1.activate()
    c2.activate()

    expect(c.isActivated() and c1.isActivated() and c2.isActivated()).to.equal true

  it 'should trigger onChildActivated & onChildDeactivated when cycling a child', (done)->
    counter = (total)->
      pos=0
      ->
        pos++
        done() if pos >= total

    count = counter(2)

    test.bind 'onChildActivated', (controller)->
      expect(controller.nodeId()).to.equal c.nodeId()
      count()

    test.bind 'onChildDeactivated', (controller)->
      expect(controller.nodeId()).to.equal c.nodeId()
      count()

    c.activate()
    c.deactivate()

  it 'should activate the default child after its siblings deactivate', ->
    theDefault = new Exo.Spine.Controller
    test.addChild theDefault
    test.setDefaultChild theDefault
    c.activate()
    c.deactivate()

    expect(theDefault.isActivated()).to.equal true

  it 'should be able to get the default child', ->
    theDefault = new Exo.Spine.Controller
    test.addChild theDefault
    test.setDefaultChild theDefault
    expect(test.defaultChild().nodeId()).to.equal theDefault.nodeId()

  it 'is able to retrieve child by id', ->
    expect(test.childById(c.nodeId()).nodeId()).to.equal c.nodeId()

  it 'should allow children to change nodeId', ->
    expect(test.childById( c.nodeId() ).nodeId() ).to.equal c.nodeId()
    c.setNodeId('banana')
    expect(test.childById('banana').nodeId()).to.equal 'banana'

