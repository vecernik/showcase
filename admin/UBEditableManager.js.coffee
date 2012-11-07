define [ "dojo", 'admin/UBEntry', 'dijit/Dialog'  ], (dojo, UBEntry, Dialog) ->

  dojo.declare null,

    debug: no
    debug_remote: yes
    delegate : null

  # metadata
    containers: null
    properties: null
    page_properties: null
    setup_properties: null
    server_time: null
    edit_mode: no

  # private
    entries: null
    dialog: null
    dialog_onload: null
    dialog_onclose: null

    constructor: (config) ->
      @entries = {}
      dojo.mixin this, config


    get_starting_metadata_and: (callback) ->
      console.log 'Loading metadata from', @metadata_url() if @debug_remote
      @start_load_metadata()
      .then( dojo.hitch this, 'metadata_loaded' )
      .then( dojo.hitch this, 'suppress_link_clicks' )
      .then( dojo.hitch this, 'initialize_properties' )
      .then( dojo.hitch @delegate, callback )


    start_load_metadata: ->
      dojo.xhrGet(
        url: @metadata_url()
        handleAs: 'json'
        preventCache: yes
        error: dojo.hitch @delegate, 'backend_error'
      )

    metadata_loaded: (data) ->
      if data['containers']
        for name, container of data['containers']
          if dojo.byId name
            @containers = {} unless @containers
            @containers[name] = container
            @containers[name].marked = no
      else
        @containers = null

      @properties = data['properties']
      @page_properties = data['page']
      @setup_properties = data['setup_properties']
      @server_time = data['server_time']
      @edit_mode = data['edit_mode'] or no

      console.log 'Metadata loaded, server time: ', @server_time, 'edit_mode: ', @edit_mode if @debug_remote
      yes


    suppress_link_clicks: ->
      return unless @edit_mode
      for container_name, container of @containers
        console.log 'Disabling links for container', container_name if @debug
#        console.log "#{container.entry_path}, #{container.entry_path} a", dojo.byId container_name
        dojo.query("#{container.entry_path}, #{container.entry_path} a", dojo.byId container_name).connect 'onclick', (e) -> e.preventDefault()
      yes



    initialize_properties: ->
      return unless @edit_mode
      for container_name, container of @containers
        if container.can_edit

          @entries[container_name] = {}
          console.log 'Reading container', container_name if @debug

          @entry_nodes_for(container).forEach ((entry_node, index) ->

            console.log 'Reading entry', entry_node  if @debug

            entry_id = container.entry_ids[index]

            entry = new UBEntry({
              id: entry_id
              container_name: container_name
              properties_url: @entry_properties_url()
              delegate: this
              editable: yes
            },
            entry_node)

            entry.setup_properties_from this, container.properties

            console.log 'Adding entry', entry if @debug
            @entries[container_name][entry_id] = entry
          ),
          this


    load_entry_and_edit_property: (entry, property) ->
      dojo.xhrGet(
        url: @entry_properties_url()
        content: { entryid: entry.id }
        handleAs: 'json',
        error: dojo.hitch @delegate, 'backend_error'
      )
      .then (
        dojo.hitch this, (data) ->
          console.log 'Populating entry with', data if @debug_remote
          entry.populate_with data
          @editable_property_clicked property
      )


# entry je jiz loaded
    editable_property_clicked: (property) ->
      console.log 'Editing property', property if @debug
      entry = property.entry
      entry.editing = yes
      @delegate.editing_entry_with entry, property


    persist_changes: ->
      content = { authenticity_token: @authenticity_token() }
      do_save = no

      i = 0
      for container_name, container_entries of @entries
        for entry_id, entry of container_entries
          changed_properties = entry.changed_attributes()
          if changed_properties
            for propname, value of changed_properties
              content["entries[#{entry_id}][#{propname}]"] = value
            do_save = yes
          else
            entry.saved() if entry.editing

          @event_manager().mark_editing_entry_with(entry.node, no) if entry.editing

        container = @container(container_name)

        if container['new_entry'] or no
          add_this = no
          new_properties = container.new_entry.changed_attributes()

          for propname, value of new_properties
            content["new_entries[#{i}][#{propname}]"] = value
            add_this = yes

          if add_this
            content["new_entries[#{i}][container_id]"] = container.id
            do_save = yes
            i++
            container.new_entry = null


      seo_changed = @delegate.seo_editor_manager.changed_properties()

      if seo_changed
        do_save = yes
        for prop_name, value of seo_changed
          content["page[#{prop_name}]"] = value
        content["page[current_url]"] = window.location.pathname #@delegate.seo_editor_manager.properties.url.persisted_value
#        console.log seo_changed, content


      return @delegate.all_changes_saved() unless do_save

      dojo.xhrPost(
        url: @persist_entries_url()
        content: content
        handleAs: 'text'
        sync: true
        load: dojo.hitch this, 'changes_saved'
#        error: dojo.hitch @delegate, 'backend_error'
      )

    changes_saved: (data) ->
      if data == ''
        window.location.reload()
      else
        window.location.href = data

#      window.location.reload()
#      for container_name, container_entries of data
#        for entry_id, changed_entry of container_entries
#          entry = @entry(container_name, entry_id)
#          console.log 'Populating persisted entry with', changed_entry if @debug_remote
#          entry.populate_with changed_entry
#          entry.visible_changed changed_entry
#
#      @delegate.all_changes_saved()


    undo_changes: ->
      for container_name, container_entries of @entries
        for id, entry of container_entries
          entry.undo_changed_properties()
          @event_manager().mark_editing_entry_with(entry.node, no)


    open_dialog: (props, callback) ->
#      console.log @dialog
      @close_dialog() if @dialog
      props.UBConnections = []
      props.refocus = no
      @dialog = new Dialog(props)
      @dialog.UBConnections.push dojo.connect @dialog, 'onLoad', this, -> callback(@dialog) if callback
      @dialog.UBConnections.push dojo.connect @dialog, 'onHide', this, 'close_dialog'
#      dojo.query('> html').addClass('dialog-open') # zapricini scrol nahoru
      @dialog.show()
      @dialog


    close_dialog: ->
      for i in @dialog.UBConnections
        dojo.disconnect i
      @dialog.destroy()
#      dojo.query('> html').removeClass('dialog-open')
      @dialog = null


    delete_entry: (event) ->
      event.preventDefault()
      node = event.currentTarget
      if confirm(@file_manager_delete_prompt())
        dojo.destroy @last_editing_entry().node
        console.log 'Deleting entry: ', node if @debug_remote
        window.location.href = node.href


    moveup_entry: (event) ->
      console.log 'Moving up entry: ', event.currentTarget if @debug_remote
#      event.preventDefault()
      entry = @last_editing_entry()
      entries = @entries_for(entry.container_name)
      entries_array = for id of entries
        id
      index = dojo.indexOf entries_array, entry.id
      dojo.place entry.node, entries[entries_array[index-1]].node, 'before'

      entry.saved()
      @event_manager().hide_panel_editor()
      @event_manager().set_loading yes
      @event_manager().go_to_step 4
#      console.log index, entries[entries_array[index-1]], entry.node


    movedown_entry: (event) ->
      console.log 'Moving down entry: ', event.currentTarget if @debug_remote
#      event.preventDefault()
      entry = @last_editing_entry()
      entries = @entries_for(entry.container_name)
      entries_array = for id of entries
        id
      index = dojo.indexOf entries_array, entry.id
      dojo.place entry.node, entries[entries_array[index+1]].node, 'after'

      entry.saved()
      @event_manager().hide_panel_editor()
      @event_manager().set_loading yes
      @event_manager().go_to_step 4


  # tools
    authenticity_token: -> dojo.query('head meta[name=csrf-token]')[0].content
    entry_nodes_for: (container) -> dojo.query(container.entry_path, dojo.byId(container.key_name))
    container: (name) -> @containers[name] or no
    property: (name) -> @properties[name] or no
    setup_property: (name) -> @setup_property[name] or no
    entries_for: (container_name) -> @entries[container_name] or {}
    entry: (container_name, id) -> (@entries_for(container_name) or [])[id] or no

    is_entry_first_in: (entry, container) ->
      container.entry_ids[0] == entry.id

    is_entry_last_in: (entry, container) ->
      container.entry_ids[container.entry_ids.length-1] == entry.id


    entry_wants_buttons: (entry) ->
      container = @container entry.container_name
      entry.id and (container.can_delete or container.can_move)

  # wrappery
#    edit_mode: -> @delegate.edit_mode
    metadata_url: -> @delegate.metadata_url
    entry_properties_url: -> @delegate.entry_properties_url
    persist_entries_url: -> @delegate.persist_entries_url
    file_manager_url: -> @delegate.file_manager_url
    file_manager_title: -> @delegate.file_manager_title
    file_manager_delete_prompt: -> @delegate.file_manager_delete_prompt
    file_create_url: -> @delegate.file_create_url
    event_manager: -> @delegate.event_manager
    property_attribute: -> @delegate.property_attribute
    entryid_attribute: -> @delegate.entryid_attribute
    last_editing_entry: -> @delegate.last_editing_entry

    images_folder_name: -> @delegate.images_folder_name
    attachments_folder_name: -> @delegate.attachments_folder_name

    panel_placeholder_image: -> @delegate.panel_placeholder_image
    file_manager_icon_path: -> @delegate.file_manager_icon_path
    file_manager_no_file_name: -> @delegate.file_manager_no_file_name
    file_manager_rename_prompt: -> @delegate.file_manager_rename_prompt

    undo_editing_entry: (entry) -> @delegate.undo_editing_entry(entry)

    confirm_persist: (entry, event)->
      event.preventDefault()
      @delegate.persist_all_changes()
