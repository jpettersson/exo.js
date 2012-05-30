# Globals
Exo = @Exo = {}
module?.exports  = Exo

Exo.Model = require('lib/exo/model')

Exo.Controller = require('lib/exo/controller')					# Note: If you subclass any of your own lib classes
Exo.List = require('lib/exo/list')								# they have to be defined after the superclass (doh).

Exo.NullTransitions = require('lib/exo/null_transitions')