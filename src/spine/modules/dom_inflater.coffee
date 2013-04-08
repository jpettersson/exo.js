DOMInflater =

  included: ->
    ((@filters ||= {})['before_prepare'] ||= []).push 'inflateFromDOM'

  inflateFromDOM: ->
    return unless typeof @['deactivateAndKillOrphans'] == 'function'

    classNames = []

    # Do we have modelClass -> template mappings?
    if @templates
      for key, val of @templates
        classNames.push key

    # Do we have modelClass -> controller mappings?
    if @controllers
      for key, val of @controllers
        classNames.push key

    # 1. Select data-*-id
    # 2. Reject those not present in current model names
    # 3. Map them to model instances

    dashifiedClassNames = classNames.map (className)=> @dashify(className)

    selectors = dashifiedClassNames.map (className)->
      "[data-#{className}-id]"

    # Only use data attributes that mirror the class names of the 
    # passed model classes.
    elements = @el.find.call(@el, selectors.join(', ')).filter (i)->
      for className in dashifiedClassNames
        return true if $(@).data("#{className}-id")

    collection = elements.map (index, el)=>
      id = undefined

      for className in classNames
        downcaseName = className[0].toLowerCase() + className[1..-1]
        break if id = $(el).data("#{downcaseName}Id")

      throw "Invalid DOM" unless id
      @inflateModel $(el), className

    console.log 'collection', collection

    if @template || @templates
      @tagElements(collection)
    #else if @controller || @controllers
    #  @createControllers(collection)

  # Tag existing DOM elements that should be represented by 
  # rendered templates.
  tagElements: (collection)->
    for model in collection
      

  # Create controllers for existing DOM elements and add them 
  # to the Exo hierarchy, tag them with corresponding models.
  createControllers: (collection)->

  inflateModel: (el, modelClassName)->
    if @modelClass
      modelClass = @modelClass
    else if @modelClasses
      modelClass = @modelClasses.filter((item)-> 
        item.className == modelClassName)[0]
    else
      throw "No Model Class specified!"

    return unless modelClass
    className = @dashify(modelClass.className)
    id = el.attr("data-#{className}-id")

    attributes = {id: id}
    for attr in modelClass.attributes
      if targetEl = el.find("[data-#{className}-attribute='#{attr}']")[0]
        attributes[attr] = targetEl.innerText

    new modelClass(attributes)

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