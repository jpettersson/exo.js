SpineList ?= require('spine/lib/list')
$ ?= Spine.$

class List extends SpineList

  click: (e) ->
    item = $(e.currentTarget).item()
    @trigger('change', item, $(e.currentTarget))
    false

module.exports = List