Superstars = require 'controllers/superstars'
Machines = require 'controllers/machines'

class Main extends Exo.Spine.Controller

	className: 'main'

	constructor: ->
		super
			defaultState: Exo.Node.States.ACTIVATED

	activateNext: (next) ->
		unless @next
			@next = next

			@addChild @next											# Add the section to the controller hierarchy				
			@next.bind "onDeactivated", @onControllerDeactivated	# Get notified when the controller is deactivated
			@next.bind "onActivated", @onControllerActivated		# and activated.

			@append @next											# Also append it's @el to the DOM.
	
			console.log "Main: Activate next: #{next.className}"
			@next.activate()										# Attempt to activate the section.
			
	onControllerActivated: (controller) =>
		@current = controller
		@next = null

	onControllerDeactivated: (controller) =>
		@removeChild controller
		controller.release()

	superstars: ->
		@activateNext new Superstars

	machines: ->
		@activateNext new Machines

module.exports = Main