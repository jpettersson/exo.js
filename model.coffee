Spine ?= require('spine')

class Model extends Spine.Model
	
	@configure: (name, attributes...) ->
		attributes = attributes.concat(['created_at', 'updated_at'])
		super name, attributes...
	
module.exports = Model