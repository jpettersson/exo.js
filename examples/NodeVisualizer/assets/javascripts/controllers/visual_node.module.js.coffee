class VisualNode extends Exo.Spine.Controller

	className: 'visualNode'

	HEIGHT: 100
	WIDTH: 100

	events:
		'click': 'toggle'

	toggle: ->
		console.log 'click'
		Exo.Spine.Controller.toggle @

	doActivate: ->
		@el.addClass 'activated'
		@onActivated()

	doDeactivate: ->
		@el.removeClass 'activated'
		@onDeactivated()

	position: ()->
		console.log @parent()
		if @parent()
			console.log "JA"
			console.log @parent().el
			@el.css('top', @parent().el.css('top') + @HEIGHT)
			@el.css('left', '50%')
		else
			@el.css('top', '10px')
			@el.css('left', '50%')

module.exports = VisualNode