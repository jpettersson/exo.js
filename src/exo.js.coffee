//= require './namespace'
//= require './state_machine'
//= require './node'
//= require './spine/controller'
//= require './spine/list'


#Exo.Model = require('./vendor/exo/model')
#Exo.Controller = require('./vendor/exo/controller')					# Note: If you subclass any of your own lib classes
#Exo.List = require('./vendor/exo/list')								# they have to be defined after the superclass (doh).
#Exo.GroupController = require('./vendor/exo/group_controller')

# # Will be deprecated
#Exo.ExclusiveStack = require('./vendor/exo/exclusive_stack')
#Exo.NullTransitions = require('./vendor/exo/null_transitions')

#TODO: Turn this in to a nice module. Also, allow rending of multiple objects.
#Exo.HAML = (view, obj) ->
#	require(view)([obj])
