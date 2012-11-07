# Fading Carousel widget

# Unobtrusive vertical item changer

# It's used on various websites we authored :
# http://www.lindabbuildings.cz/

# (c) 2010-11 Michal Zeravik


define [ "dojo", "dojo/fx", "sys/widgets/Carousel" ], (dojo, dojo_fx, carousel) ->

  dojo.declare carousel,

    crossFadeFunction: dojo_fx.combine
    showFirst: true


    slideFromTo: (fromPosition, toPosition) ->
      return  if fromPosition is toPosition
      @_oldPosition = fromPosition
      @_currentPosition = toPosition
      @_currentPagerPosition = toPosition
      @_slidingOver = false
      @slide()


    getSlideAnim: ->
      currentChild = @getCurrentChild()
      lastChild = @getLastChild()
      animin = (if currentChild then @getAnimDefaultConfig(currentChild) else false)
      animout = (if lastChild then @getAnimDefaultConfig(lastChild) else false)
      if animin
        animin.beforeBegin = (node) ->
          dojo.style node,
            visibility: "visible"
      if animout
        animout.onEnd = (node) ->
          dojo.style node,
            visibility: "hidden"
      anims = []
      anims.push dojo.fadeOut(animout)  if animout
      anims.push dojo.fadeIn(animin)  if animin
      mainanim = @crossFadeFunction(anims)
      dojo.connect mainanim, "onEnd", this, "_afterSlide"
      mainanim


    getAnimDefaultConfig: (node) ->
      node: node
      duration: @duration
      easing: @easing


    pushChangedContainer: ->


    setContainerSize: ->
      size = @childSize()
      if size
        containerStyle = {}
        containerStyle[(if @isPortrait then "height" else "width")] = size + "px"
        dojo.style @containerNode, containerStyle


    afterInit: (enabled) ->
      @inherited arguments
      @showOnlyChildAtIndex 0  if @showFirst and enabled


    showOnlyChildAtIndex: (i) ->
      dojo.forEach @childrenNodes(), (child, index) ->
        dojo.style child,
          opacity: (if index is i then 1 else 0)
          visibility: (if index is i then "visible" else "hidden")


    visibleSize: ->
      @childSize()
