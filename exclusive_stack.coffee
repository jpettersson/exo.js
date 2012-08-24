class ExclusiveStack extends Exo.Controller

	activateNext: (next, targetEl=null) ->
		unless @next
			@next = next

			@addChild @next											# Add the section to the controller hierarchy				
			@next.bind "onDeactivated", @onControllerDeactivated	# Get notified when the controller is deactivated
			@next.bind "onActivated", @onControllerActivated		# and activated.

			if targetEl == null
				@append @next											# Also append it's @el to the DOM.
			else
				@next.appendTo targetEl

			console.log "Activate next now: #{next.className}"
			@next.activate()										# Attempt to activate the section.
			
	onControllerActivated: (controller) =>
		@current = controller
		@next = null

	onControllerDeactivated: (controller) =>
		@removeChild controller
		controller.release()

module.exports = ExclusiveStack