define [ "dojo", 'admin/UBEditableInlineProperty', 'admin/UBEditablePanelProperty' ],
(dojo, UBEditableInlineProperty, UBEditablePanelProperty) ->
#  console.log InlineEditBox

  dojo.declare null,

    debug: yes
    debug_remote: yes


  # atributy
    id: null
    container_name: null
    properties_url: '/property_url'
    delegate: null
    editable: no


  # private
    editable_properties: null
    other_properties: null
    editing: no
    node: null
    hash: null


    constructor: (config, node) ->
      dojo.mixin this, config
      @node = node
      @set_hash()
      @editable_properties = {}
      @other_properties = {}


    setup_properties_from: (manager, container_properties) ->
      for prop_name, prop_query of container_properties
        property = manager.property(prop_name)
        prop_node = if prop_query == '.' then @node else prop_query != '' and dojo.query(prop_query, @node)[0] or no

        attributes = name: prop_name, entry: this, property: property #, delegate: this

        if @editable
          if prop_node and !/_/.test(prop_name) and @tag_is_not_empty(prop_node)
            @editable_properties[prop_name] = new UBEditableInlineProperty attributes, prop_node
          else
            @other_properties[prop_name] = new UBEditablePanelProperty attributes


    start_editing_property: (property) ->
#      console.log event, property
      if @loaded()
        @delegate.editable_property_clicked(property)
      else
        @delegate.load_entry_and_edit_property(this, property)


    populate_with: (data) ->
      for ename, eproperty of @editable_properties
        eproperty.populate_value data[ename]

      for oname, oproperty of @other_properties
        oproperty.populate_value data[oname]

      @set_hash()


    has_markdown: ->
      has_markdown = no
      for ename, eproperty of @editable_properties
        has_markdown = yes if eproperty.is_richtext()
      for oname, oproperty of @other_properties
        has_markdown = yes if oproperty.is_richtext()
      has_markdown


    visible_changed: (properties) ->
      for ename, eproperty of @editable_properties
        if properties[ename] or no
          value = properties[ename]
          eproperty.original_node.innerHTML = value
  #          dojo.style eproperty.original_node, display: 'none' if eproperty.original_node.innerHTML == ''
          eproperty.original_value = value
#          eproperty.loaded = no
#          eproperty.entry_saved()


  # wrappery metod
    panel_node: -> @delegate.panel_node()
    panel_button_node: (n) -> @delegate.panel_button_node(n)
    panel_editor: -> @delegate.panel_editor()


    loaded: ->
      loaded = yes

      for name, property of @other_properties
        loaded = no unless property.loaded

      if loaded
        for name, property of @editable_properties
          loaded = no unless property.loaded

      loaded


    changed_attributes: ->
      changed = no
      changes = {}
      for name, oproperty of @other_properties
        if oproperty.value_changed()
          changes[name] = oproperty.value()
          changed = yes

      for name, eproperty of @editable_properties
        if eproperty.value_changed()
          changes[name] = eproperty.value()
          changed = yes
#      console.log changed, changes
      if changed then changes else no


    has_other_properties: ->
      return yes for own key of @other_properties
      no


    save: ->
      for epropname, eproperty of @editable_properties
        eproperty.save_value()

      for propname, property of @other_properties
        property.save_value()


    undo_changed_properties: ->
      for ename, eproperty of @editable_properties
        eproperty.undo()

      for oname, oproperty of @other_properties
        oproperty.undo()


    saved: ->
      for ename, eproperty of @editable_properties
        eproperty.entry_saved()


    disconnect: ->
      for ename, eproperty of @other_properties
        eproperty.disconnect()
#        eproperty.entry_saved()


    equal_with: (entry) ->
      @hash == entry.hash


    tag_is_not_empty: (node) ->
      if node.tagName == 'IMG'
        node.src != ''
      else
        node.innerHTML != ''


    set_hash: ->
      @hash = "#{@container_name}-#{@id}"


    wants_assets_panel: (container) ->
      @has_other_properties() or container.can_delete or container.can_move #or @has_markdown()
