class Machine extends Exo.Spine.Controller

	className: 'machine-item'

	prepare: ->
		@el.hide()	

	doActivate: ->
		@el.show()
		TweenLite.from(@el, .5, {
			css: {
				scale: 0
			},
			ease: Quad.easeOut,
			onComplete: => @onActivated()
		})

	doDeactivate: ->
		TweenLite.to(@el, .5, {
			css: {
				scale: 0
			},
			ease: Quad.easeIn,
			onComplete: => @onDeactivated()
		})

module.exports = Machine