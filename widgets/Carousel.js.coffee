# Endless carousel widget

# Unobtrusive item changed.
# This code was written because none of carousels these days available was not working as I required.
# As you can see, this code was converted from Javascript to Coffeescript.

# It's used on various websites we authored :
# http://www.kickthewaves.com/
# http://www.lindabbuildings.cz/
# http://www.trussaluminium.com/company
# http://www.graffiti-walls.com/

# (c) 2010-11 Michal Zeravik

define [ "dojo" ], (dojo) ->
  dojo.declare null,

    containerQuery: "> :first-child"
    disabledClass: "disabled"
    childrenQuery: "> DIV"
    prev: false
    next: false
    duration: 400
    easing: null
    waitForSlide: false
    isPortrait: false
    seamless: true
    startupSlideTimeout: 0
    autoSlideInterval: 0
    autoSlideOnlyOnce: false
    letPrevNext: false
    pager: false
    pagerSuffix: false
    pagerQuery: "> A"
    pagerSelectedClass: "selected"
    attachKeys: false
    srcNodeRef: null
    containerNode: null
    prevNode: null
    nextNode: null
    prevC: null
    nextC: null
    pagerCs: null
    pagerContainer: null
    _currentPagerPosition: 0
    _oldPagerPosition: 0
    _anim: null
    _currentPosition: 0
    _oldPosition: 0
    _slidingOver: false
    slidingRight: null
    _startupSlideTimeout: null
    _autoSlideInterval: null

    constructor: (params, srcNodeRef) ->
      @srcNodeRef = dojo.byId(srcNodeRef) or false
      return false  unless @srcNodeRef
      dojo.safeMixin this, params
      @containerNode = dojo.query(@containerQuery, @srcNodeRef)[0] or false
      @nextNode = dojo.byId(@next) or false  if @next
      @prevNode = dojo.byId(@prev) or false  if @prev
      @pagerContainer = (if @pagerSuffix then dojo.byId(@srcNodeRef.id + @pagerSuffix) else (if @pager then dojo.byId(@pager) else false))
      @setContainerSize()  if @containerNode
      @resolveEnabled()

    slideLeft: ->
      if @seamless
        if @currentPosition() is 0
          @moveChildNodeToBe "first"
          @pushChangedContainer "first"
          @_oldPosition = 1
          @_currentPosition = 1
      childrenNodesCount = @childrenNodesCount()
      @_currentPagerPosition--
      @_currentPagerPosition = (if @seamless then childrenNodesCount - 1 else 0)  if @_currentPagerPosition < 0
      @_currentPosition--  if @currentPosition() > 0
      @slidingRight = false
      @slide()
      true

    slideRight: ->
      lastVisibleLeftmostPosition = @lastVisibleLeftmostPosition()
      positionOnVisibleEnd = @currentPosition() >= lastVisibleLeftmostPosition
      unless @seamless
        return false  if positionOnVisibleEnd
      else
        if positionOnVisibleEnd
          @moveChildNodeToBe "last"
          @pushChangedContainer "last"
          @_oldPosition--
          @_currentPosition--
      childrenNodesCount = @childrenNodesCount()
      @_currentPagerPosition++
      @_currentPagerPosition = (if @seamless then 0 else childrenNodesCount - 1)  if @_currentPagerPosition is childrenNodesCount
      @_currentPosition++
      @slidingRight = true
      @slide()
      true

    slideTo: (newPosition) ->
      currentPosition = @_oldPagerPosition
      @slideFromTo currentPosition, newPosition

    slideBy: (steps) ->
      @slideFromTo 0, steps

    slideFromTo: (fromPosition, toPosition) ->
      return  if fromPosition is toPosition
      @slidingRight = fromPosition < toPosition
      from = (if @slidingRight then fromPosition else toPosition)
      to = (if @slidingRight then toPosition else fromPosition)
      @_slidingOver = true
      i = from

      while i < to
        @_slidingOver = false  if i is to - 1
        (if @slidingRight then @slideRight() else @slideLeft())
        i++

    slide: ->
      currentPosition = @currentPosition()
      oldPosition = @oldPosition()
      return  if oldPosition is currentPosition or (not @_slidingOver and not @beforeSlide())
      @setNodeEnabledWith @nextNode, @seamless or currentPosition < @lastVisibleLeftmostPosition()  if @nextNode and not @letPrevNext
      @setNodeEnabledWith @prevNode, @seamless or currentPosition > 0  if @prevNode and not @letPrevNext
      oldPagerChild = @getPagerChildAtIndex(@_oldPagerPosition)
      dojo.removeClass oldPagerChild, @pagerSelectedClass  if oldPagerChild
      pagerChild = @getPagerChildAtIndex(@_currentPagerPosition)
      dojo.addClass pagerChild, @pagerSelectedClass  if pagerChild
      delete @_anim

      @_anim = @getSlideAnim()
      @_anim.play()  if @_anim
      @_oldPosition = currentPosition
      @_oldPagerPosition = @_currentPagerPosition
      @slidingRight = null

    afterInit: (enabled) ->
      enabled

    beforeSlide: ->
      true

    afterSlide: ->

    getSlideAnim: ->
      animconfig = @getAnimDefaultConfig()
      endpx = -@currentPosition() * @childSize()
      animconfig.properties[(if @isPortrait then "top" else "left")] =
        end: endpx
        unit: "px"

      dojo.animateProperty animconfig

    getAnimDefaultConfig: ->
      node: @containerNode
      duration: @duration
      easing: @easing
      properties: {}
      onEnd: dojo.hitch(this, "_afterSlide")

    _afterSlide: ->
      delete @_anim

      @afterSlide()

    setContainerSize: ->
      childrenCount = @childrenNodesCount()
      containerStyle =
        position: "relative"
        oveflow: "hidden"

      containerStyle[(if @isPortrait then "height" else "width")] = @childSize() * childrenCount + "px"
      dojo.style @containerNode, containerStyle

    shouldBeEnabled: ->
      enabled = false
      childrenCount = @childrenNodesCount()
      if childrenCount > 1
        childSize = @childSize()
        childrenSize = childrenCount * childSize
        enabled = childrenSize > @visibleSize()
      enabled

    resolveEnabled: ->
      enabled = @shouldBeEnabled()
      if enabled
        @enable()
      else
        @disable()
      enabled

    enable: ->
      @setEnabled true

    disable: ->
      @setEnabled false

    setEnabled: (enabled) ->
      @setNodeEnabledWith @srcNodeRef, enabled
      @disconnect()
      currentPosition = @currentPosition()
      if @nextNode
        @setNodeEnabledWith @nextNode, @letPrevNext or enabled and currentPosition < @lastVisibleLeftmostPosition()
        @nextC = dojo.connect(@nextNode, "onclick", this, (if enabled or @letPrevNext then "handleSlideRight" else "stopClick"))
      if @prevNode
        @setNodeEnabledWith @prevNode, @letPrevNext or enabled and (@seamless or currentPosition > 0)
        @prevC = dojo.connect(@prevNode, "onclick", this, (if enabled or @letPrevNext then "handleSlideLeft" else "stopClick"))
      if @pagerContainer
        @setNodeEnabledWith @pagerContainer, enabled
        dojo.forEach @pagerChildrenNodes(), ((item) ->
          @pagerCs.push dojo.connect(item, "onclick", this, (if enabled then "handleSlideTo" else "stopClick"))
        ), this
      @clearAutoSlide()
      @afterInit enabled
      if enabled
        if @autoSlideInterval > 0
          if @startupSlideTimeout > 0
            @setStartupSlideTimeout()
          else
            @setAutoSlideInterval()
        if @attachKeys
          dojo.connect document, "onkeypress", this, (e) ->
            key = e.keyCode
            keyMatrix = {}
            keyMatrix[dojo.keys.LEFT_ARROW] = "slideLeft"
            keyMatrix[dojo.keys.RIGHT_ARROW] = "slideRight"
            if keyMatrix[key] or false
              nodeHasFocus = dojo.query("INPUT:focus, TEXTAREA:focus")[0] or false
              unless nodeHasFocus
                @clearAutoSlide()
                dojo.hitch(this, keyMatrix[key])()
      enabled

    moveChildNodeToBe: (position) ->
      childrenCount = (if position is "first" then @childrenNodesCount() else 1)
      clonePosition = childrenCount - 1
      child = @getChildAtIndex(clonePosition)
      dojo.place child, @containerNode, position

    pushChangedContainer: (position) ->
      styles = {}
      currentOffset = dojo.style(@containerNode, (if @isPortrait then "top" else "left"))
      childSize = @childSize()
      styles[(if @isPortrait then "top" else "left")] = currentOffset + (if position is "first" then -childSize else childSize) + "px"
      dojo.style @containerNode, styles

    handleSlide: (e, name) ->
      dojo.stopEvent e
      @slideByName name

    handleSlideLeft: (e) ->
      @handleSlide e, "slideLeft"

    handleSlideRight: (e) ->
      @handleSlide e, "slideRight"

    slideByName: (name) ->
      return false  if @waitForSlide and @_anim and not @_autoSlideInterval
      @clearAutoSlide()
      this[name]()

    handleSlideTo: (e) ->
      dojo.stopEvent e
      @slideToNode e.currentTarget

    slideToNode: (node) ->
      pagerChild = node
      return  if dojo.hasClass(pagerChild, @pagerSelectedClass)
      pagerPosition = @getPagerChildIndex(pagerChild)
      return false  if @waitForSlide and @_anim and not @_autoSlideInterval
      @clearAutoSlide()
      @slideTo pagerPosition

    setNodeEnabledWith: (node, enabled) ->
      if enabled
        dojo.removeClass node, @disabledClass
      else
        dojo.addClass node, @disabledClass  unless dojo.hasClass(node, @disabledClass)

    isNodeDisabled: (node) ->
      dojo.hasClass node, @disabledClass

    isEnabled: ->
      not @isNodeDisabled(@srcNodeRef)

    lastVisibleLeftmostPosition: ->
      childrenCount = @childrenNodesCount()
      visibleChildren = @visibleChildren()
      childrenCount - visibleChildren

    stopClick: (e) ->
      dojo.stopEvent e

    disconnect: ->
      dojo.disconnect @prevC  if @prevC
      dojo.disconnect @nextC  if @nextC
      dojo.forEach @pagerCs, dojo.disconnect  if @pagerCs
      @prevC = null
      @nextC = null
      @pagerCs = []

    setStartupSlideTimeout: ->
      @_startupSlideTimeout = setTimeout(dojo.hitch(this, "setAutoSlideInterval"), @startupSlideTimeout)

    setAutoSlideInterval: ->
      @_autoSlideInterval = setInterval(dojo.hitch(this, "autoSlideRight"), @autoSlideInterval)

    clearAutoSlide: ->
      clearTimeout @_startupSlideTimeout  if @_startupSlideTimeout
      @_startupSlideTimeout = null
      clearInterval @_autoSlideInterval  if @_autoSlideInterval
      @_autoSlideInterval = null

    autoSlideRight: ->
      @slideRight()
      @clearAutoSlide()  if @autoSlideOnlyOnce and @_currentPagerPosition is 0

    childrenNodes: ->
      (if @containerNode then dojo.query(@childrenQuery, @containerNode) else [])

    childrenNodesCount: ->
      @childrenNodes().length

    visibleChildren: ->
      childSize = @childSize()
      @visibleSize() / childSize

    childSize: ->
      childNode = @getChildAtIndex(0)
      childNodePos = (if childNode then dojo.position(childNode) else false)
      (if childNodePos then childNodePos[(if @isPortrait then "h" else "w")] else false)

    pagerChildrenNodes: ->
      (if @pagerContainer then dojo.query(@pagerQuery, @pagerContainer) else false)

    getLastChild: ->
      @getChildAtIndex @oldPosition()

    getCurrentChild: ->
      @getChildAtIndex @currentPosition()

    getChildAtIndex: (index) ->
      childrenNodes = @childrenNodes()
      childrenNodes[index] or false

    getPagerChildAtIndex: (index) ->
      nodes = @pagerChildrenNodes()
      (if nodes then nodes[index] else false)

    getPagerChildIndex: (node) ->
      dojo.indexOf @pagerChildrenNodes(), node

    getPagerSelectedChildIndex: ->
      foundIndex = null
      children = @pagerChildrenNodes()
      dojo.filter children, ((node, index) ->
        found = dojo.hasClass(node, @pagerSelectedClass)
        foundIndex = index  if found
        found
      ), this
      foundIndex

    getChildIndex: (childNode) ->
      dojo.indexOf @childrenNodes(), childNode

    getVisibleChildIndex: (childNode) ->
      @getChildIndex(childNode) - @currentPosition()

    visibleSize: ->
      dojo.position(@srcNodeRef)[(if @isPortrait then "h" else "w")]

    currentPosition: ->
      @_currentPosition

    oldPosition: ->
      @_oldPosition
