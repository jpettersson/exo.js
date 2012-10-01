Machine = require 'controllers/machines/machine'

class Machines extends Exo.Spine.Controller
	
	className: 'machines'

	events:
		'click .superstars': 'navigateToSuperstars'

	elements:
		'.items': 'itemsEl'

	prepare: ->
		# first, draw the DOM objects we need.
		@render()
		@el.hide()
	
		@machine = new Machine
		@addChild @machine
		@machine.appendTo @itemsEl

	doActivate: ->
		@el.show()
		TweenLite.from(@el, 3, {
			css: {
				top: -500
				rotation: 90
				alpha: 0
			},
			ease: Elastic.easeOut,
			onComplete: @onActivated
		})

	onActivated: =>
		super
		@machine.activate()

	doDeactivate: ->
		TweenLite.to(@el, 2, {
			css: {
				rotation: 90
				alpha: 0
			},
			ease: Elastic.easeIn,
			onComplete: => @onDeactivated()
		})

	render: =>
		@html JST['templates/machines']()	

	navigateToSuperstars: =>
		@navigate '/superstars'

module.exports = Machines