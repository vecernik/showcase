define [ "dojo", 'admin/UBPropertyEditors/base' ], (dojo, EditorBase) ->

  dojo.declare EditorBase,


    constructor: (property, default_props) ->
      @inherited arguments
#      console.log this
      @props.type = 'number'
#      @props.required = 'required'


