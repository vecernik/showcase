define [ "dojo", 'admin/UBEditableProperty' ], (dojo, UBEditableProperty) ->

  dojo.declare UBEditableProperty,

#    debug: no

    constructor: (config) ->
      @inherited arguments


    create_and_add_to: (container_node, props) ->

      props.maxlength = @property.max_length if @property.max_length > 200
      props.placeholder = @property.placeholder if @property['placeholder'] or no

      @editor = @build_property_editor props

#      @editor_connect 'onchange', 'save_value'
      @editor_connect 'onkeypress', 'resolve_editor_keypress'

      @editor.set_value @value()

      dojo.place(@create_markup(), container_node)

#      @editor.start_editing()


    create_markup: ->
      container = dojo.create 'div', { className: "control-group type-#{@property.prop_type} prop-#{@property.name}" }
      dojo.create 'label', { innerHTML: @property.label, class: 'control-label clearfix' }, container
      # pridat div, tohle funguje skoro, akorat vyhazuje undefined
#      dojo.place @editor.node(), container
      dojo.place @editor.node(), dojo.create 'div', { class: 'controls' }, container
      container


    entry_saved: ->
      @inherited arguments
      @editor.destroy() if @editor
      @editor = null

