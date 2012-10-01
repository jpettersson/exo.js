class Star extends Exo.Spine.Controller

	className: 'item'

	prepareWithModel: (model) ->
		@model = model

	render: ->
		@html JST['templates/star'](@model)

	beforeActivate: ->
		@render()

	moveTo: (index) ->
		@index = index

	doActivate: ->
		TweenLite.from(@el, 2, {
			css: {
				alpha: 0
				left: if @index % 2 then -500 else 500
			},
			delay: @index * .1
			ease: Elastic.easeOut,
			onComplete: => @onActivated()
		})

	doDeactivate: ->
		TweenLite.to(@el, 1.5, {
			css: {
				alpha: 0
				rotation: if @index % 2 then -360 else 360
			},
			ease: Quad.easeOut,
			onComplete: => @onDeactivated()
		})

module.exports = Star