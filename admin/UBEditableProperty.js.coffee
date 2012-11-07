define [ "dojo", 'admin/UBPropertyEditors/text', 'admin/UBPropertyEditors/markdown', 'admin/UBPropertyEditors/select', 'admin/UBPropertyEditors/image', 'admin/UBPropertyEditors/file', 'admin/UBPropertyEditors/number', 'admin/UBPropertyEditors/email', 'admin/UBPropertyEditors/ckeditor'],
(dojo, TextEditor, MarkdownEditor, SelectEditor, ImageEditor, FileEditor, NumberEditor, EmailEditor, CkeditorEditor) ->
#  console.log InlineEditBox

  dojo.declare null,

    debug: yes

    name: ''
    entry: null
    property: null
#    delegate: null

    loaded: no

#    current_value: null
#    previous_value: null
#    old_value: null
    editor: null
    current_value: null
    persisted_value: null
    editing: no

    connections: null


    constructor: (config) ->
      @connections = []
      dojo.mixin this, config


  # tools

    populate_value: (value) ->
      @loaded = yes
      @persisted_value = value
      @set_value value
      @editor.disable(no) if @editor


    resolve_editor_keypress: (event) ->
      if event.charOrCode == 27 #esc
        @undo()
#        console.log @entry
        @entry.delegate.undo_editing_entry(@entry)
      else if event.charOrCode == 13 and event.currentTarget.tagName == "INPUT"
        @save_value()
        @entry.delegate.confirm_persist(@entry, event)


    value: ->
#      if @editor then @editor.value() else @current_value
      @current_value


    set_value: (value) ->
      @current_value = value
      @editor.set_value(value) if @editor
#        console.log @editor_node.value
#        else
#          @editor_node.innerHTML = value#

    value_changed: ->
#      console.log @name, @persisted_value, @loaded and @persisted_value != @value(), @value(), @entry.id if @name=='button_type'
      @loaded and @persisted_value != @value()


    save_value: ->
      @current_value = @editor.value() if @editor


    entry_saved: ->
#      console.log @name, @editor.value_node(), @entry.id, this
      @editing = no
      @persisted_value = @value()


    undo: ->
      @set_value @persisted_value


    disconnect: ->
      dojo.forEach @connections, dojo.disconnect
      @connections = []


    build_property_editor: (props={}) ->

      props.name = @property.name unless props['name']

      props.maxlength = @property.max_length if @property.max_length > 0
      props.placeholder = @property.placeholder if @property['placeholder'] or no

      type = @property.prop_type
      type = 'select' if @property.meta and @property.meta['select'] or no

#      console.log @property.name, type, @property
      method_name = "create_editor_#{type}"

      props['className'] = 'editable-input'

      dojo.hitch(this, method_name)(props)


    editor_connect: (event_name, method_name) ->
      @connections.push dojo.connect @editor.value_node(), event_name, dojo.hitch(this, method_name)


    is_richtext: ->
      @property.prop_type == 'markdown' or @property.prop_type == 'ckeditor'


  # wrappery

    create_editor_text: (props) ->
      new TextEditor this, props

    create_editor_markdown: (props) ->
      new MarkdownEditor this, props

    create_editor_select: (props) ->
      new SelectEditor this, props

    create_editor_file: (props) ->
      new FileEditor this, props

    create_editor_image: (props) ->
      new ImageEditor this, props

    create_editor_number: (props) ->
      new NumberEditor this, props

    create_editor_integer: (props) ->
      new NumberEditor this, props

    create_editor_email: (props) ->
      new EmailEditor this, props

    create_editor_ckeditor: (props) ->
      new CkeditorEditor this, props


    panel_placeholder_image: -> @entry.delegate.panel_placeholder_image()
    file_manager_icon_path: -> @entry.delegate.file_manager_icon_path()
    file_manager_no_file_name: -> @entry.delegate.file_manager_no_file_name()
