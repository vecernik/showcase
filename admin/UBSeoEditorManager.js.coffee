define [ "dojo", 'admin/UBPanelEditorManager', 'admin/UBEditablePanelProperty'],
(dojo, UBPanelEditorManager, UBEditablePanelProperty) ->

  dojo.declare UBPanelEditorManager,

    properties: null

    constructor: (config) ->
      @inherited arguments
      @properties = {}

      if @editable_manager().page_properties

        for prop_name, property of @editable_manager().page_properties
          attributes = name: prop_name, entry: {delegate: this}, property: property
          @properties[prop_name] = new UBEditablePanelProperty attributes
          @properties[prop_name].populate_value property.content
#      else
#        i = dojo.indexOf(@panel_button_ids(), 'go-editseo')
#        @panel_button_ids().splice(i, 1)


    start: ->
      @edit_with_properties @properties


    changed_properties: ->
      props = {}
      changed = false
      for prop_name, property of @properties
        property.save_value()
#        console.log prop_name, property.persisted_value, property.value_changed(), property.value()
        props[prop_name] = property.value() if property.value_changed()
        changed = yes
      props if changed


  # wrappery

#    entry: -> self
#    editable_manager: -> @delegate.editable_manager
    panel_button_ids: -> @delegate.panel_button_ids
#    setup_manager_url: -> @delegate.setup_manager_url
    seo_editor_dialog_title: -> @delegate.seo_editor_dialog_title
    seo_editor_update_url: -> @delegate.seo_editor_update_url
    images_folder_name: -> @delegate.images_folder_name
    attachments_folder_name: -> @delegate.attachments_folder_name
    panel_placeholder_image: -> @delegate.panel_placeholder_image
    file_manager_url: -> @delegate.file_manager_url
    file_manager_title: -> @delegate.file_manager_title
    file_create_url: -> @delegate.file_create_url
    open_dialog: (conf, callback) -> @editable_manager().open_dialog(conf, callback)
    close_dialog: -> @editable_manager().close_dialog()

    undo_editing_entry: (entry) ->
      @inherited arguments
      @event_manager().go_to_step(1)
