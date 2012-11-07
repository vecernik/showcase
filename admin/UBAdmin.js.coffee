# Unobtrusive ajax in-place website administration

# It's based on idea of cached 'containers' in html identified with ID attribute
# Features admin panel, live page Seo editor, asset manager (S3 or local), panel editor for invisible attributes
# Backend models attached are creating universal background for storing dynamic editable data.

define [ "dojo", 'admin/UBEventManager', 'admin/UBPanelEditorManager', 'admin/UBEditableManager', 'admin/UBSetupManager', 'admin/UBCreatingEditorManager', 'admin/UBSeoEditorManager', 'admin/UBAssetPanelManager' ],
(dojo, UBEventManager, UBPanelEditorManager, UBEditableManager, UBSetupManager, UBCreatingEditorManager, UBSeoEditorManager, UBAssetPanelManager) ->

  dojo.declare null,

    debug: no

  # admin panel
    panel_id: 'live-admin-panel'

  # event manager
    event_manager: null
    editable_class: 'editable'
    editable_container_class: 'editable-container'
    loading_class: 'loading'
    editing_entry_class: 'editing-entry'
    last_editing_entry_class: 'last-editing-entry'
    editable_input_class: 'editable-input'

  # editable manager
    editable_manager: null
    metadata_url: '/admin/metadata.json'
    property_attribute: 'data-property'
    entryid_attribute: 'data-entryid'

    persist_entries_url: '/admin/entriespersist'
    entry_properties_url: '/admin/entryproperties.json'

    file_manager_url: '/admin/filemanager.html'
    file_manager_title: 'Prohlížeč souborů'
    file_create_url: '/admin/assetcreate'
    file_manager_delete_prompt: 'Are you sure to delete?'
    file_manager_icon_path: '/assets/file_icons'
    file_manager_no_file_name: 'choose file ...'
    file_manager_rename_prompt: 'New name'


  # panel editor
    panel_editor_id: 'panel-editor'
#    panel_button_ids: ['go-editseo', 'go-setup', 'edit-save', 'edit-undo', 'go-help']
    panel_button_ids: ['go-editseo', 'go-setup', 'go-destroypage', 'go-addpage', 'edit-save', 'edit-undo', 'go-help']
    panel_editor_manager: null
    panel_connections: null
    panel_placeholder_image: '/assets/admin/panel-image-placeholder.png'
    panel_otherbutton_class: 'btn btn-inverse'

    last_editing_entry: null
    last_editing_property: null

    entry_delete_base_url: '/admin/entrydelete/'
    entry_moveup_base_url: '/admin/entrymoveup/'
    entry_movedown_base_url: '/admin/entrymovedown/'

  # setup manager
    setup_manager: null
#    setup_manager_url: '/admin/setupmanager'
    setup_update_url: '/admin/setupupdate'
    setup_dialog_title: 'Setup'
    setup_submit_title: 'Save setup'

  # creating_editor_manager
    creating_editor_manager: null
    create_button_label: 'Add'

    label_for_create_page: 'What is name of new page?'

  # seo manager
    seo_editor_manager: null
    seo_editor_update_url: '/admin/seoupdate'
    seo_editor_dialog_title: 'SEO of active page'

    images_folder_name: 'Obrázky'
    attachments_folder_name: 'Přílohy'

    help_dialog_title: 'Nápověda'
    server_error_message: 'Vyskytla se chyba při komunikaci se serverem.'
    confirm_destroy_page1: 'Opravdu si přejete odstranit tuto stránku?'
    confirm_destroy_page2: 'POZOR! Při odstranění stránky se smaže i obsah na stránce.\r\nOpravdu si přejete odsranit stránku včetně jejího obsahu?'

  # asset panel
    asset_panel_manager: null

    delegate: null
    onLoad: null


    constructor: (config) ->
      dojo.safeMixin this, config if config
      @panel_connections = []

      @event_manager = new UBEventManager delegate: this
      @event_manager.set_loading yes

      @editable_manager = new UBEditableManager delegate: this
      @editable_manager.get_starting_metadata_and(@loaded)

      @panel_editor_manager = new UBPanelEditorManager delegate: this

      @asset_panel_manager = new UBAssetPanelManager delegate: this



    loaded: ->
      @seo_editor_manager = UBSeoEditorManager delegate: this

      dojo.destroy('go-editmode') unless @editable_manager.containers

      unless @editable_manager.page_properties
        dojo.destroy('go-editseo')
        dojo.destroy('go-addpage')
        dojo.destroy('go-destroypage')

      @connect_panel()

      @creating_editor_manager = new UBCreatingEditorManager delegate: this
      @creating_editor_manager.create_buttons() if @editable_manager.edit_mode

      @setup_manager = new UBSetupManager delegate: this

      @event_manager.set_loading no

      if @editable_manager.edit_mode
        @event_manager.go_to_step 3
      else
        @event_manager.go_to_step 1

      @delegate = this

      @onLoad() if @onLoad



  # entry je uz populated

    editing_entry_with: (entry, property=null) ->

      @last_editing_property = property if property

      same_as_last = @last_editing_entry && entry.equal_with @last_editing_entry

      unless same_as_last

        if @last_editing_entry
          @event_manager.mark_last_editing_entry_with(@last_editing_entry.node, false)
          @last_editing_entry.save()
          @last_editing_entry.disconnect()

        @event_manager.go_to_step(2)
        @event_manager.mark_last_editing_entry_with(entry.node, true)

      container = @editable_manager.container entry.container_name

      should_open_assets = (property and property.is_richtext()) or entry.wants_assets_panel(container)

#      console.log entry, property, entry.wants_assets_panel(container)

      if !same_as_last || should_open_assets && !@asset_panel_manager.started

        if should_open_assets
          @asset_panel_manager.start_with_entry(entry, container, property)
          @event_manager.show_panel_editor()
        else
          @event_manager.hide_panel_editor()

        @last_editing_entry = entry


    undo_editing_entry: (entry) ->
#      console.log entry
      entry.undo_changed_properties() if entry.undo_changed_properties
#      @event_manager().mark_editing_entry_with(entry.node, no)
      @event_manager.mark_last_editing_entry_with(entry.node, no) if entry.node
#      console.log @last_editing_entry
      @panel_editor_manager.undo_changes()

      if @last_editing_entry
        @last_editing_entry.disconnect()
        @last_editing_entry = null

      if @event_manager.is_editing()
        @event_manager.focus_first_editing()
      else
        @event_manager.go_to_step(3) unless @event_manager.is_editing()

      @last_editing_property = null

  # akce na hlavnich buttonech

    connect_panel: ->
      for id in @panel_button_ids
        node = dojo.byId id
#        console.log node
        @panel_connections.push dojo.connect(node, 'onclick', this, 'panel_button_clicked') if node


    panel_button_clicked: (e) ->
      e.preventDefault()
      switch e.currentTarget.id
        when 'edit-undo'
          @undo_all_changes()
        when 'edit-save'
          @persist_all_changes()
        when 'go-setup'
          @start_setup_manager()
        when 'go-editseo'
          @start_seo_editor_manager()
        when 'go-help'
          @show_help(e.currentTarget.href)
        when 'go-addpage'
#          if confirm(@confirm_create_page)
#            window.location.href = e.currentTarget.href
          label = prompt(@label_for_create_page, '')
          window.location.href = "#{e.currentTarget.href}?label=#{encodeURIComponent(label)}" if label && !label != ''
        when 'go-destroypage'
          ok = confirm(@confirm_destroy_page1) and confirm(@confirm_destroy_page2)
          window.location.href = e.currentTarget.href if ok


    add_panel_button: (title, path) ->
      container = dojo.byId('other-buttons')
      dojo.create 'a', { href: path, className: @panel_otherbutton_class, innerHTML: title, title: "Open #{title}"}, container


    undo_all_changes: ->
      if @last_editing_entry
        @event_manager.mark_last_editing_entry_with(@last_editing_entry.node, false)
        @last_editing_entry.disconnect()
        @last_editing_entry = null
        @last_editing_property = null
      @editable_manager.undo_changes()
      @panel_editor_manager.undo_changes()
      @creating_editor_manager.undo_changes()
      @seo_editor_manager.undo_changes()
      @event_manager.go_to_step if @seo_editor_manager.started then 1 else 3


    persist_all_changes: ->
      if @last_editing_entry
        @last_editing_entry.save()
        @event_manager.mark_last_editing_entry_with(@last_editing_entry.node, false)
        @last_editing_entry.disconnect()
        @last_editing_entry = null
        @last_editing_property = null
      @event_manager.go_to_step 4
      @event_manager.set_loading yes
      @event_manager.hide_panel_editor()
      @editable_manager.persist_changes()


    start_setup_manager: ->
      @setup_manager.start()


    start_seo_editor_manager: ->
      @seo_editor_manager.start()
      @event_manager.go_to_step 2
      @event_manager.show_panel_editor()


    show_help: (href) ->
#      console.log href
      @editable_manager.open_dialog(
        title: @help_dialog_title
        href: href
      )

    # callbacky

    all_changes_saved: (data) ->
      @entry.undo()
      @panel_editor_manager.empty_panel_form()
      @event_manager.set_loading no
      @event_manager.go_to_step 3


    backend_error: (data, request_args) ->
      console.error arguments
      @event_manager.set_loading no
      alert @server_error_message
#      window.location.reload()

  # tools

    panel_node: -> dojo.byId(@panel_id)
