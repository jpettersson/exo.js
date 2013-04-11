DOMOrganizer = 

  reorganizeDOM: ->
    return unless @children().filter((child)-> child.isDeactivating()).length == 0
    
    getElAt = (index) =>
      model = @collection[index]
      child = @childById("#{model.constructor.className}#{model.cid}")
      return child.el

    for child, index in @collection
      if el = getElAt(index)
        if index == 0
          $(@el).prepend(el)
        else
          prev = getElAt(index-1)
          el.insertAfter(prev)

Exo?.Spine ||= {}
Exo?.Spine.Modules ||= {}
Exo?.Spine.Modules.DOMOrganizer ||= DOMOrganizer
module?.exports = DOMOrganizer