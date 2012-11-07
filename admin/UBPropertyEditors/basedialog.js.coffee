define [ "dojo", 'admin/UBPropertyEditors/base', 'dojo/io/iframe'], (dojo, EditorBase, ioIframe) ->

  dojo.declare EditorBase,

    connections: null


    constructor: (property, default_props) ->
      @props = default_props
      @property = property
      @connections = []
      @dialog = null


    build: (value=no) ->
      @connections = []

      value = @property.original_node.src if !value and @property.original_node and @property.original_node.src!=''

      node = dojo.create 'img', { className: @props['className'], src: if value then value else @panel_placeholder_image() } #, container_node
      @connections.push dojo.connect node, 'onclick', this, 'open_file_browser'

      node


    set_value: (value) ->
      @value_node().src = if !value or value == '' then @panel_placeholder_image() else value


    value: ->
      value = dojo.attr @value_node(), 'src'
#      filename = if !value || value == '' then '' else value #.match(/(https?:\/\/[^\/]+)?(\/uploads|\/system)?(\/.+)?/i)[3]
#      console.log 'get', filename, value
      if value && value.match(@panel_placeholder_image()) then '' else value


    start_editing: ->
#      console.log @value(), this
      @open_file_browser()


    dialog_url: ->
      "#{@file_manager_url()}?file=#{encodeURIComponent(@value())}&folder=#{encodeURIComponent(@folder_name())}"


    open_file_browser: (event) ->
      event.preventDefault() if event
      @editing_manager().open_dialog({
        title: "#{@file_manager_title()} : #{@label()}"
        href: @dialog_url()
      },
      dojo.hitch this, 'dialog_loaded')


    dialog_loaded: (dialog) ->
      dojo.query('a.use', dialog.containerNode).forEach ((link) ->
        dialog.UBConnections.push dojo.connect link, 'onclick', this, 'asset_clicked'
      ), this

      dojo.query('a.delete', dialog.containerNode).forEach ((link) ->
        dialog.UBConnections.push dojo.connect link, 'onclick', this, 'delete_asset'
      ), this

      dojo.query('a.rename', dialog.containerNode).forEach ((link) ->
        dialog.UBConnections.push dojo.connect link, 'onclick', this, 'rename_asset'
      ), this

      form_node = dojo.query('form', dialog.containerNode)[0]

      dialog.UBConnections.push dojo.connect(form_node, 'onsubmit', this, 'dialog_form_submit')

      dojo.query('#asset_file_uploader', dialog.containerNode).forEach ((input) ->
        dialog.UBConnections.push dojo.connect input, 'onchange', this, (event) -> @asset_set_title_for event.currentTarget.value
      ), this

      @dialog = dialog


    asset_set_title_for: (value='') ->
#      console.log value
      try
        title = value.replace(/[-_/]/ig, ' ').replace('  ', ' ')
      catch error
        title = value
      dojo.attr 'asset_title', 'value', title


    dialog_form_submit: (event) ->
      event.preventDefault()
#      console.log @editing_manager()
      ioIframe.send({
        form: dojo.query('form', @dialog.containerNode)[0]
        handleAs: 'json'
        url: @file_create_url()
        error: dojo.hitch @error_delegate(), 'backend_error'
      })
      .then( dojo.hitch this, 'dialog_refresh' )


    dialog_refresh: (data) ->
#      model = data[0] or no
#      console.log data
#      if model
      @open_file_browser()


    asset_clicked: (event) ->
      event.preventDefault()
      node = event.currentTarget
      value = if node.pathname == '/' then '' else node.href
#      console.log node, value
      @set_value value
      @property.save_value()
      @editing_manager().close_dialog()


    delete_asset: (event) ->
      event.preventDefault()
      if confirm('Opravdu smazat?')
        dojo.xhrGet(
          url: event.currentTarget.href
          handleAs: 'json'
        )
        .then dojo.hitch(this, 'dialog_refresh'), dojo.hitch(@error_delegate(), 'backend_error')


    rename_asset: (event) ->
      event.preventDefault()
      current_file = dojo.attr(event.currentTarget, 'data-filename')
      new_file = prompt(@file_manager_rename_prompt(), current_file) or ''

      if new_file != '' and new_file != current_file
        dojo.xhrGet(
          url: "#{event.currentTarget.href}?filename=#{encodeURIComponent(new_file)}"
          handleAs: 'text'
        )
        .then dojo.hitch(this, 'dialog_refresh'), dojo.hitch(@error_delegate(), 'backend_error')


    destroy: ->
      dojo.forEach @connections, dojo.disconnect
      @inherited arguments


    folder_name: ->  ''

    label: -> @property.property.label
    editing_manager: -> @property.entry.delegate
    panel_placeholder_image: -> @editing_manager().panel_placeholder_image()
    file_manager_title: -> @editing_manager().file_manager_title()
    file_manager_url: -> @editing_manager().file_manager_url()
    file_create_url: -> @editing_manager().file_create_url()
    file_manager_rename_prompt: -> @editing_manager().file_manager_rename_prompt()
    error_delegate: -> @editing_manager().delegate

