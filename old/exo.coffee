# Globals
Exo = @Exo = {}
module.exports  = Exo

Exo.Model = require('lib/exo/model')

Exo.Controller = require('lib/exo/controller')					# Note: If you subclass any of your own lib classes
Exo.List = require('lib/exo/list')								# they have to be defined after the superclass (doh).
Exo.GroupController = require('lib/exo/group_controller')

# Will be deprecated
Exo.ExclusiveStack = require('lib/exo/exclusive_stack')

Exo.NullTransitions = require('lib/exo/null_transitions')

#TODO: Turn this in to a nice module. Also, allow rending of multiple objects.
Exo.HAML = (view, obj) ->
	require(view)([obj])
