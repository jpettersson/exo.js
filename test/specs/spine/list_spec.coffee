describe "Exo.Spine.List as a new instance", ->
  Fish = FishController = list = null

  class Fish extends Exo.Spine.Model
    @configure "Fish", "species"

  Fish.create({species: 'Minnow'})
  Fish.create({species: 'Fugu'})
  Fish.create({species: 'Tucuxi'})

  class FishController extends Exo.Spine.Controller
    prepareWithModel: (fish)->
      @fish = fish
      @render()

    render: ->
      @html "<div>#{@fish.species}</div>"

  beforeEach -> 
    list = new Exo.Spine.List
      controller: FishController
    $('body').append list

  it "can render controllers", ->
    list.render Fish.all()
    expect(list.el[0].innerText).to.equal 'MinnowFuguTucuxi'

  it "has consistent children after multiple render calls", ->
    list.render Fish.all()
    expect(list.children().length).to.equal 3
    list.render Fish.all()
    expect(list.children().length).to.equal 3

    for child in list.children()
      expect(child.children().length).to.equal 0