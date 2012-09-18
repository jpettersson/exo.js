class TestController
	@include Exo.Controller

	doActivate: ->
		@onActivated()

	doDeactivate: ->
		@onDeactivated()

module.exports = TestController