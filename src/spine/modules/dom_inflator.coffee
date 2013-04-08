DOMInflator =

  included: ->
    ((@filters ||= {})['before_prepare'] ||= []).push 'inflateFromDOM'

  inflateFromDOM: ->
    return unless typeof @['deactivateAndKillOrphans'] == 'function'

    classNames = []
    if @modelClass
      classNames = [@modelClass.className]
    else if @modelClasses
      classNames = @modelClasses.map (modelClass) -> modelClass.className

    throw "No Model Classes specified!" unless classNames.length > 0

    dashifiedClassNames = classNames.map (className)=> 
      @dashify(className)

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

    if @template || @templates
      @tagElements(collection)
    else if @controller || @controllers
     @createControllers(collection)
  
  ###
  Tag existing DOM elements that should be represented by 
  rendered templates.
  ###
  tagElements: (collection)->
    for model in collection
      el = @el.find("[data-#{@dashify(model.constructor.className)}-id]")
      @tagElement el, model

  ###
  Create controllers for existing DOM elements and add them 
  to the Exo hierarchy, tag them with corresponding models.
  ###
  createControllers: (collection)->
    throw 'No controllers specified!' unless @controller or @controllers
    controllers = @controllers || {default: @controller}

    for model in collection
      controllerClass = controllers['default'] || controllers[model.constructor.className]
      
      el = @el.find("[data-#{@dashify(model.constructor.className)}-id]")
      @tagElement el, model

      child = new controllerClass
        el: el
        model: model
        initialState: Exo.Node.States.ACTIVATED
      @addChild child

  tagElement: (el, model)->
    $(el).data('item', model)

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

  ###
  Take a CamelCase model class-name and return
  a dashified version: camel-case.
  @param [String] string
  ###
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
Exo?.Spine.Modules.DOMInflator ||= DOMInflator
module?.exports = DOMInflator