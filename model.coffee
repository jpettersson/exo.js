Spine ?= require('spine')

class Model extends Spine.Model
	
	@defaults: (atts) ->
		@defaultValues = atts
	
	@configure: (name, attributes...) ->
		attributes = attributes.concat(['created_at', 'updated_at'])
		super name, attributes...

	@create: (atts, options) ->
		
		# Set default values
		for attribute in @attributes
			unless attribute in atts
				atts[attribute] = @defaultValues[attribute] if @defaultValues[attribute]
		super
	
module.exports = Model