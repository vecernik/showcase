define [ "dojo", 'admin/UBEditableProperty' ], (dojo, UBEditableProperty) ->

  dojo.declare UBEditableProperty,

#    debug: yes

  # private
    editing: no


    original_node: null
    original_value: null


    constructor: (config, propnode) ->
      @inherited(arguments)

      @original_node = propnode
      @original_value = propnode.innerHTML

      @loaded = no if @property.prop_type == 'markdown'

      @editor = @build_property_editor()

      @connections.push dojo.connect @original_node, 'onclick', dojo.hitch(this, 'resolve_click')

      @editor_connect 'onkeypress', 'resolve_editor_keypress'
      @editor_connect 'onclick', 'resolve_click'



    resolve_click: (e) ->
#      console.log @name, @editing, @loaded
      unless @editing
        @editing = yes
        @decorate_editor_node()
        dojo.place @editor.node(), @original_node, 'after'
        @editor.start_editing()

      @resolve_editing()

      @entry.start_editing_property this

#    resolve_editor_click: (e) ->
#      @entry.start_editing_property this

    resolve_editing: ->
#      console.log @name, @editing
      if @editing
        dojo.style @original_node, display: 'none'
        @editor.show()
        @editor.focus()
      else
        @editor.hide()
        dojo.style @original_node, display: ''

#    get_input_name: ->
#      "entries[#{@entry.id}][#{@name}]"

    decorate_editor_node: ->
      rules = ['display', 'float', 'position', 'color', 'backgroundColor', 'fontWeight', 'fontFamily', 'fontStyle', 'textAlign', 'textTransform', 'verticalAlign' ]
#      rulespx = ['width', 'height', 'marginLeft', 'marginRight', 'marginTop', 'marginBottom', 'paddingLeft', 'paddingRight', 'paddingTop', 'paddingBottom', 'fontSize', 'lineHeight', 'textIndent', 'letterSpacing', 'top', 'left']
      rulespx = ['marginLeft', 'marginRight', 'marginTop', 'marginBottom', 'paddingLeft', 'paddingRight', 'paddingTop', 'paddingBottom', 'fontSize', 'lineHeight', 'textIndent', 'letterSpacing', 'top', 'left']

      for rule in rules
        value = dojo.style(@original_node, rule)
        dojo.style(@editor.value_node(), rule, value)

      for rule in rulespx
        value = dojo.style(@original_node, rule)
        num_value = parseInt(value)
        dojo.style(@editor.value_node(), rule, if isNaN(num_value) then value else "#{num_value}px")

      if dojo.style(@original_node, 'display') != 'inline'
#        pos = dojo.position @original_node
#        dojo.style @editor.value_node(), height: "#{pos.h}px", width: "#{pos.w}px" #width: "auto"
        dojo.style @editor.value_node(), height: "#{dojo.style(@original_node, 'height')}px", width: "#{dojo.style(@original_node, 'width')}px" #width: "auto"


    cancel_editing: ->
      dojo.place @original_node, @editor.node(), 'replace'
      @editing = no


    undo: ->
      @set_value @original_value
      @entry_saved()


    populate_value: (value) ->
      @inherited arguments
      @original_value = value
      @resolve_editing()


    entry_saved: ->
      @inherited arguments
      @resolve_editing()
#      dojo.style @original_node, 'display': ''
#      @editor.hide()
#      @editor.blur()
