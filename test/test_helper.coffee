requireDir = require 'require-dir'

# traverse = (tree)=>
#   for subtree, node of tree
#     if node && {}.toString.call(node) == '[object Function]'
#       node.call @
#     else
#       traverse(node)

global.expect = require 'expect.js'

global.Exo = require '../src/exo'

global.Exo.Spine = {}
global.Exo.Spine.Model = require '../src/spine/Model'
global.Exo.Spine.Controller = require '../src/spine/controller'
global.Exo.Spine.List = require '../src/spine/list'

requireDir "./specs", {recurse: true}
