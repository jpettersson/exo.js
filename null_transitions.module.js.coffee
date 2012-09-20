NullTransitions = 

	doActivate: ->
		console.log "heh"
		@onActivated()

	onActivated: ->
		console.log 'drep'
		$(@).show()
		super

	doDeactivate: ->
		@onDeactivated()

	onDeactivated: ->
		$(@).hide()
		super