Spine = require('spine')

NullTransitions = 

	doActivate: ->
		@onActivated()

	doDeactivate: ->
		@onDeactivated()