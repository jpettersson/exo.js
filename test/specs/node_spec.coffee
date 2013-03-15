Node = Exo.Node

describe "Node as a new instance", ->
  test = null

  beforeEach ->
    test = new Node

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
      c = new Node
      test.addChild c
    expect(test.children().length).to.equal 5

    test.removeChild(test.children()[0])
    expect(test.children().length).to.equal 4

describe 'Node as a child', ->
  p = test = s = null

  beforeEach ->
    p = new Node
    test = new Node
    s = new Node

    p.addChild test
    p.addChild s

  it "should be able to activate it's parent", ->
    test.activate()
    expect(test.isActivated() and p.isActivated()).to.equal true

  it "should be able to activate by deactivating it's sibling", ->
    s.activate()
    test.activate()
    expect(test.isActivated() and p.isActivated() and not s.isActivated()).to.equal true

describe "Node as a parent and child", ->
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
    expect(Node.lineageIsBusy(test)).to.equal true
    p.onActivated()
    expect(Node.lineageIsBusy(test)).to.equal false
    # Child
    c.activate()
    expect(Node.lineageIsBusy(test)).to.equal true
    c.onActivated()
    expect(Node.lineageIsBusy(test)).to.equal false

  it 'should have an activated child if a child is activated', ->
    c.activate()
    expect(test.activatedChildren().length).to.equal 1

  it 'should only have one activated child at any time when mode = Mode.EXCLUSIVE', ->
    c1 = new Node
    c2 = new Node 

    test.addChild c1
    test.addChild c2

    c.activate()
    c1.activate()
    c2.activate()

    expect(c2.isActivated() and not c.isActivated() and not c1.isActivated()).to.equal true

  it 'should allow multiple activated children when mode = Mode.MULTI', ->
    test.setMode Node.Modes.MULTI
    
    c1 = new Node
    c2 = new Node

    test.addChild c1
    test.addChild c2

    c.activate()
    c1.activate()
    c2.activate()

    expect(c.isActivated() and c1.isActivated() and c2.isActivated()).to.equal true

  it 'should report haveBusyChildren = true when mode = Mode.MULTI and children are transitioning', ->
    test.setMode Node.Modes.MULTI

    c1 = new Node
    c2 = new Node
    c1.doActivate = c2.doActivate = ->

    test.addChild c1
    test.addChild c2

    c1.activate()
    c2.activate()

    expect(test.haveBusyChildren()).to.equal true
    expect(test.isTransitioning()).to.equal false
    expect(test.isBusy()).to.equal false

  it 'should activate the default child after its siblings deactivate', ->
    theDefault = new Node
    test.addChild theDefault, {default: true}
    c.activate()
    c.deactivate()

    expect(theDefault.isActivated()).to.equal true

  it 'should be possible to get the default child', ->
    theDefault = new Node
    test.addChild theDefault, {default: true}
    expect(test.defaultChild().nodeId()).to.equal theDefault.nodeId()
