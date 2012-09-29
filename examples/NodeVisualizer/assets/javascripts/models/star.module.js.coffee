class Star extends Spine.Model
	# 'Exo' is appended to the name in order to avoid 
	# collitions between the examples. 
	@configure "ExoStar", "name", "optional"
	@extend Spine.Model.Local

	@DEFAULTS: [
		'Transition State Machines',
		'Enhanced Models',
		'???'
	]

	@createDefaults: ->
		for name in @DEFAULTS
			if Star.select((star) -> star.name == name).length == 0
				star = new Star
					name: name
					optional: false

				star.save()

module.exports = Star