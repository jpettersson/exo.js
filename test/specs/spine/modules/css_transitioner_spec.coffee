describe "Exo.Spine.Modules.CSSTransitioner", ->
  it 'should be includeable by controllers', ->

    class Dummy extends Exo.Spine.Controller
      @include Exo.Spine.Modules.CSSTransitioner

    controller = new Dummy

    expect(typeof controller['cssListen'] == 'function').to.equal true
    expect(typeof controller['cssStartTransition'] == 'function').to.equal true