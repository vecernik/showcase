define [ "dojo" ], (dojo) ->
#  console.log InlineEditBox

  dojo.declare null,

    debug: no
    delegate : null
    started: no

    connections: null
    fieldset_class: 'form-vertical'


    constructor: (config) ->
      @connections = []
      dojo.mixin this, config



    build_panel_form: ->
      @empty_panel_form()
      @create_container_with_legend false


    create_container_with_legend: (legend=false) ->
      container = dojo.create 'div', {class: 'well'}, dojo.create('fieldset', { class: @fieldset_class }, @panel_form_node())
      dojo.create 'legend', { innerHTML: legend }, container if legend
      container


    edit_with_properties: (properties) ->
      container_node = @build_panel_form()
      @started = yes

      for propname, prop of properties
        prop.create_and_add_to container_node, @default_props_for(propname)

      container_node


  # tools
    empty_panel_form: ->
      for e in @connections
        e.remove()
      @connections = []
      dojo.query('*', @panel_form_node()).forEach dojo.destroy


    undo_changes: ->
      for prop_name, property of @properties
        property.undo()
        property.disconnect()
      @event_manager().hide_panel_editor()
      @empty_panel_form()


    default_props_for: (propname) ->
      {
        className: ''
        name: propname
      }


  # wrappery

    panel_editor: -> dojo.byId(@delegate.panel_editor_id)
    panel_form_node: -> dojo.query('>form', @panel_editor())[0] or dojo.create('form', { action: 'post' }, @panel_editor(), 'first')
    event_manager: -> @delegate.event_manager
    file_manager_icon_path: -> @delegate.file_manager_icon_path
    file_manager_no_file_name: -> @delegate.file_manager_no_file_name

    editable_manager: -> @delegate.editable_manager
    confirm_persist: (entry, event) -> @editable_manager().confirm_persist(entry, event)

    undo_editing_entry: (entry) -> @delegate.undo_editing_entry(entry)

    file_manager_rename_prompt: -> @editable_manager().file_manager_rename_prompt()
