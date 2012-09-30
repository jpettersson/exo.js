class VisualNode extends Exo.Spine.Controller

	className: 'visualNode'

	events:
		'click': 'toggle'

	elements: 
		'.items': 'itemsEl'

	constructor: ->
		super

	doActivate: ->
		TweenLite.to(@el, .3, {
			css: {
				rotation: 90
				backgroundColor: '#42a4ff'
			},
			#ease: Elastic.easeOut,
			onComplete: => @onActivated()
		})

	doDeactivate: ->
		TweenLite.to(@el, .3, {
			css: {
				rotation: 0
				backgroundColor: '#90a1b1'
			},
			#ease: Elastic.easeOut,
			onComplete: => @onDeactivated()
		})

	toggle: ->
		console.log 'click'
		Exo.Spine.Controller.toggle @

	# position: ()->
	# 	console.log @parent()
	# 	if @parent()
	# 		y = @parent().el.position().top + @HEIGHT
	# 		@el.css('top', y + 'px')
	# 		@el.css('left', '200px')
	# 	else
	# 		@el.css('left', '50%')

module.exports = VisualNode