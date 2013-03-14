describe "Exo.Spine.List as a new instance", ->
  # Fish = FishController = list = null

  # beforeEach -> 
  #   class Fish extends Exo.Spine.Model
  #     @configure "Fish", "species"

  #   class FishController extends Exo.Spine.Controller
  #     prepareWithModel: (fish)->
  #       @fish = fish
  #       @render()

  #     render: ->
  #       @html "<div>#{@fish.name}</div>"

  #   list = new Exo.Spine.List
  #     controller: FishController

  #   $('body').append list

  # it "can render controllers", ->
  #   Fish.create({name: 'Minnow'})
  #   Fish.create({name: 'Fugu'})
  #   Fish.create({name: 'Tucuxi'})

  #   list.render Fish.all()

    #console.log $(list.el)
    #expect(list.el)