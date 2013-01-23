class Model extends Spine.Model
	
	@defaults: (atts) ->
		@defaultValues = atts
	
	@configure: (name, attributes...) ->
		attributes = attributes.concat(['created_at', 'updated_at'])
		super name, attributes...

	@create: (atts={}, options={}) ->
		
		# Set default values
		for attribute in @attributes
			unless atts[attribute]
				atts[attribute.toString()] = @defaultValues[attribute.toString()] if @defaultValues[attribute.toString()] or @defaultValues[attribute.toString()] == 0

		super atts, options
	
	getClassName: ->
		@constructor.className

Exo.Spine.Model = Model