define [ "dojo", 'admin/UBPropertyEditors/base' ], (dojo, EditorBase) ->

  dojo.declare EditorBase,


    constructor: (property, default_props) ->
      @inherited arguments
#      @props.innerHTML = property.value()


    build: ->
      dojo.create 'textarea', @props


#    start_editing: ->
#      console.log 'start_editing', this, @node()
#      @connections.push dojo.connect @node(), 'ondrop', this, 'drop_text'


#    drop_text: (event) ->
#      console.log event.dataTransfer.getData('Text')
#      console.log @value()


    set_value: (value) ->
#      @value_node().innerHTML = value
      @value_node().value = value

