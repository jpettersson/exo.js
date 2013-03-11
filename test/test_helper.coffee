requireDir = require 'require-dir'

# traverse = (tree)=>
#   for subtree, node of tree
#     if node && {}.toString.call(node) == '[object Function]'
#       node.call @
#     else
#       traverse(node)

requireDir "./specs", {recurse: true}
