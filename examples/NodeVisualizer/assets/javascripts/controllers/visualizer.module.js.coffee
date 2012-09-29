VisualNode = require './visual_node'

class Visualizer extends Exo.Spine.Controller

	className: 'visualizer'

	prepare: ->
		main = new VisualNode
		@append main

		for i in [0..4]
			c = new VisualNode
			@append c
			main.addChild c
			c.position()
		
		#main.addChild child
	
module.exports = Visualizer