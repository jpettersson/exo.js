DOMInflater =

  included: ->
    ((@filters ||= {})['before_prepare'] ||= []).push 'inflateFromDOM'

  inflateFromDOM: ->
    return unless @modelClass
    className = @dashify(@modelClass.className)
    id = @el.attr("data-#{className}-id")
    
    attributes = {id: id}
    for attr in @modelClass.attributes
      if el = @el.find("[data-#{className}-attribute='#{attr}']")[0]
        attributes[attr] = el.innerText

    @model = new @modelClass(attributes)

  dashify: (name) ->
    first = true
    name.replace /[A-Z]/g, (match) ->
      unless first
        "-#{match.toLowerCase()}"
      else
        first = false
        match.toLowerCase()

Exo?.Spine ||= {}
Exo?.Spine.Modules ||= {}
Exo?.Spine.Modules.DOMInflater ||= DOMInflater
module?.exports = DOMInflater