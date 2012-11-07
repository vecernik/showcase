define [ "dojo", 'admin/UBPanelEditorManager', 'dijit/layout/ContentPane' ],
(dojo, UBPanelEditorManager, ContentPane) ->

  dojo.declare UBPanelEditorManager,

    dijit_id: 'image-chooser'
    connections: null
    cache: null

    constructor: (config) ->
      @inherited arguments
      @cache = {}
      @connections = []


    start_with_entry: (entry, container, property=null) ->

      node = @edit_with_properties entry.other_properties #if !@last_editing_entry

      if @editable_manager().entry_wants_buttons(entry)
#          @panel_editor_manager.add_controll_buttons_to node, container
        div = dojo.create 'div', { class: 'control-group form-actions' }, node

        if container.can_delete
          link = dojo.create 'a', { href: @entry_delete_base_url() + entry.id, class: 'btn btn-small btn-danger center', innerHTML: '<i class="icon-trash icon-white"></i>' }, div
          dojo.connect link, 'onclick', @editable_manager(), 'delete_entry'

        if container.can_move && !@editable_manager().is_entry_first_in entry, container
          link = dojo.create 'a', { href: @entry_moveup_base_url() + entry.id, class: 'btn btn-inverse btn-small btn-warning left', innerHTML: '<i class="icon-chevron-left icon-white"></i>' }, div
          dojo.connect link, 'onclick', @editable_manager(), 'moveup_entry'

        if container.can_move && !@editable_manager().is_entry_last_in entry, container
          link = dojo.create 'a', { href: @entry_movedown_base_url() + entry.id, class: 'btn btn-inverse btn-small btn-warning right', innerHTML: '<i class="icon-chevron-right icon-white"></i>' }, div
          dojo.connect link, 'onclick', @editable_manager(), 'movedown_entry'


      should_open_assets = property and property.is_richtext()

      #entry.has_markdown()
      if should_open_assets

        assets_dijit = dijit.byId @dijit_id or no

        if assets_dijit
          for i in @connections
            dojo.disconnect i
          assets_dijit.destroy()

        assets_node = dojo.create 'div', { id: @dijit_id }, node, 'first'

        assets_dijit = new ContentPane({
#          id: 'image-chooser-pane'
          href: "#{@file_manager_url()}?folder=#{encodeURIComponent(@images_folder_name())}&not_new=1"
          onDownloadEnd: dojo.hitch this, ->
            @connect_links assets_dijit
        },
        assets_node)
#          console.log assets_dijit, assets_node
        assets_dijit.startup();


    connect_links: (assets_dijit) ->
      dojo.query('a.use', assets_dijit.containerNode).forEach ((link) ->
        @connections.push dojo.connect link, 'onclick', this, 'markdown_asset_clicked'
      ), this


    markdown_asset_clicked: (event) ->
      event.preventDefault()
      return unless @last_editing_property()

      node = @last_editing_property().editor.value_node()
      return if !node or node.nodeName != 'TEXTAREA'

      value = "\n#{event.currentTarget.href}\n"

      @insert_at_caret(node, value)


    insert_at_caret: (node, value) ->
      scrollPos = node.scrollTop
      strPos = 0

      if dojo.isIE
        node.focus()
        range = document.selection.createRange()
        range.moveStart "character", -1*node.value.length
        strPos = range.text.length
      else
        strPos = node.selectionStart

      front = (node.value).substring(0, strPos)
      back = (node.value).substring(strPos, node.value.length)
      node.value = front + value + back
      strPos = strPos + value.length

      if dojo.isIE
        node.focus()
        range = document.selection.createRange()
        range.moveStart "character", -1*node.value.length
        range.moveStart "character", strPos
        range.moveEnd "character", 0
        range.select()
      else
        node.selectionStart = strPos
        node.selectionEnd = strPos
        node.focus()
      node.scrollTop = scrollPos


    editable_manager: -> @delegate.editable_manager
    file_manager_url: -> @delegate.file_manager_url
    images_folder_name: -> @delegate.images_folder_name
    entry_delete_base_url: -> @delegate.entry_delete_base_url
    entry_moveup_base_url: -> @delegate.entry_moveup_base_url
    entry_movedown_base_url: -> @delegate.entry_movedown_base_url

    last_editing_property: -> @delegate.last_editing_property
