module.exports = 

  cssTransitionEndEvents: 'transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd'
  cssActiveClass: 'active'
  cssTransitionDelay: 10

  doActivate: ->
    @cssStartTransition('addClass', @onActivated)

  doDeactivate: ->
    @cssStartTransition('removeClass', @onDeactivated)
  
  cssListen: (callback)->
    @el.on @cssTransitionEndEvents, =>
      callback.call @
      @el.off @cssTransitionEndEvents

  cssStartTransition: (mutatorFunc, callback)->
    @cssListen(callback)

    @delay =>
      @el[mutatorFunc].call @el, @cssActiveClass
    , @cssTransitionDelay
