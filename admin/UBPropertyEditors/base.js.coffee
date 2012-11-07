define [ "dojo" ], (dojo) ->

  dojo.declare null,

    property: null
    props: null
    input_node: null
    _node: null
#    connections: null


    constructor: (property, default_props) ->
      @props = default_props
      @property = property
#      @connections = []


    node: ->
      @_node ||= @build()


    build: ->
      dojo.create 'input', @props


    is_disabled: ->
      @value_node().disabled == 'disabled'

    disable: (should) ->
      @value_node().disabled = if should then 'disabled' else ''


    value:  -> @value_node().value
    set_value: (value) -> @value_node().value = value

    show: -> dojo.style @node(), display: 'block'
    hide: -> dojo.style @node(), display: 'none'
    focus: -> @value_node().focus()
    blur: -> @value_node().blur()
#    style: (styles) -> dojo.style @node(), styles


    start_editing: ->
      yes

    destroy: ->
      dojo.destroy @node()
      dojo.destroy @value_node() if @value_node()
#      @disconnect()


    value_node: ->
      @input_node || @node()

    set_value_node: (node) ->
      @input_node = node


#    disconnect: ->
#      dojo.forEach @connections, dojo.disconnect
#      @connections = []
