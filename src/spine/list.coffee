class List extends Exo.Spine.Controller
  
  constructor: (opts={}) ->
    opts.initialState ||= Exo.Node.States.ACTIVATED
    opts.mode ||= Exo.Node.Modes.MULTI
    super opts

  templateFor: (templates, item) ->
    templates[item.className]

  controllerFor: (controllers, item) ->
    controllers[item.className]

  render:(collection, opts={}) ->
    @collection = collection
    if @template || @templates
      @renderTemplates(collection) 
    else if @controller || @controllers
      @renderControllers collection, opts

  ###
  Erase the current DOM children and render 
  all items in the collection.
  ###
  renderTemplates: (collection) ->
    templates = @templates || {default: @template}
    @html ''
    for item in collection 
      html = (templates.default or templates[item.constructor.className]).call(@, item)
      el = $(html).appendTo(@el)
      $(el).data('item', item)

  renderControllers: (collection, opts) ->
    controllers = @controllers || {default: @controller}

    @deactivateAndKillOrphans(@children(), collection)

    for item, i in collection
      child = @getOrCreateChild(item, controllers[item.constructor.className] or controllers.default, opts)

      child.listIndex = i
      child.moveTo i if child.moveTo
      child.activate()

    @trigger 'afterRender', @

  getOrCreateChild: (item, controller, opts) ->
    child = @childById(item.constructor.className + item.cid)
    unless child
      child = new controller(opts)
      @addChild child
      child.setNodeId(item.constructor.className + item.cid)
      child.prepareWithModel item
      @append child
      $(child.el).data('item', item)

    return child

  # Find children that have been deleted from the collection. Deactivate them, remove them from the DOM and make them available for GC.
  deactivateAndKillOrphans: (children, collection) ->
    orphans = children.filter (child) -> child.nodeId() not in collection.map (item) -> item.constructor.className + item.cid
    for orphan in orphans
      if orphan.isActivated() and not orphan.isBusy()
        orphan.bind 'onDeactivated', (controller) =>
          @removeChild controller
          controller.release()

      orphan.deactivate()

  click: (e) ->
    if $(e.currentTarget).item
      item = $(e.currentTarget).item()
    else
      item = $(e.currentTarget).data('item')
    
    @trigger('select', item, $(e.currentTarget))
    true

Exo?.Spine ||= {}
Exo?.Spine.List = List
module?.exports = List