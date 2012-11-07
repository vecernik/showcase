define [ "dojo", 'admin/UBPropertyEditors/base' ], (dojo, EditorBase) ->

  dojo.declare EditorBase,


    constructor: (property, default_props) ->
      @inherited arguments


    build: ->
#      console.log @is_long(), @props
      if @is_long()
        dojo.create 'textarea', @props
      else
        @props.type = 'text'
        dojo.create 'input', @props


    set_value: (value) ->
      if @is_long()
        @value_node().innerHTML = value
      else
        @value_node().value = value


    is_long: ->
      !@props.maxlength or @props.maxlength > 200
