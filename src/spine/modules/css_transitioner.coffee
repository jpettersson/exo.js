CSSTransitioner = 
  cssTransitionEndEvents: 'transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd'
  cssActivateClass: 'active'
  cssDeactivateClass: undefined
  cssTransitionDelay: 10

  doActivate: ->
    if @cssDeactivateClass
      @el.removeClass @cssDeactivateClass

    @cssStartTransition('addClass', @cssActivateClass, @onActivated)

  doDeactivate: ->
    if @cssDeactivateClass
      @cssStartTransition('addClass', @cssDeactivateClass, @onDeactivated)
    else
      @cssStartTransition('removeClass', @cssActivateClass, @onDeactivated)
  
  cssListen: (callback, className)->
    $(@el).bind @cssTransitionEndEvents, =>
      callback.call @
      @el.off @cssTransitionEndEvents
      #@el.removeClass className

  cssStartTransition: (mutatorFunc, className, callback)->
    @cssListen(callback, className)

    @delay =>
      @el[mutatorFunc].call @el, className
    , @cssTransitionDelay

Exo?.Spine ||= {}
Exo?.Spine.Modules ||= {}
Exo?.Spine.Modules.CSSTransitioner ||= CSSTransitioner
module?.exports = CSSTransitioner