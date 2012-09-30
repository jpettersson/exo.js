VisualNode = require './visual_node'

class Visualizer extends Exo.Spine.Controller

	className: 'visualizer'

	CENTER: 450
	HEIGHT: 160
	WIDTH: 160
	PADDING: 10

	prepare: ->
		main = new VisualNode
			className: 'visualNode root'
		@append main

		main.el.offset
			top: 0
			left: @CENTER - @WIDTH/2

		total = [0..2]
		for i in total
			c = new VisualNode
			@append c
			
			c.el.offset
				top: @HEIGHT + @PADDING
				left: (@CENTER) - ((total.length * @WIDTH) / 2) + (i * @WIDTH)

			main.addChild c
		
		total = [0..1]
		for i in total
			d = new VisualNode
			@append d

			d.el.offset
				top: (@HEIGHT + @PADDING) * 2
				left: @CENTER + i * @WIDTH

			c.addChild d

module.exports = Visualizer