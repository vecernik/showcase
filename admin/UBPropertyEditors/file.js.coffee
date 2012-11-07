define [ "dojo", 'admin/UBPropertyEditors/basedialog'], (dojo, BaseDialog) ->

  dojo.declare BaseDialog,

    _value: ''
    icon_node: null
    title_node: null

    build: (value=no) ->
      @connections = []
#      console.log @property
      node = dojo.create 'div', { className: "#{@props['className']} attachment" }

      value = @property.current_value

      icon_src = @get_icon_src value
      filename = @get_filename value

      @icon_node = dojo.create 'img', { src: icon_src }, node
      @title_node = dojo.create 'span', { innerHTML: filename }, node

      @connections.push dojo.connect node, 'onclick', this, 'open_file_browser'

      node


    get_icon_src: (filename) ->
      if !filename || filename == ''
        "#{@file_manager_icon_path()}/unknown.png"
      else
        r = filename.match(/\.([a-z]+)$/)
        ext = if r then r[1] else 'unknown'
        "#{@file_manager_icon_path()}/#{ext}.png"


    get_filename: (filename) ->
      if !filename || filename == ''
        @file_manager_no_file_name()
      else
        filename.match(/([^\/]+)$/)[1].replace(/[_-]/g, ' ')


    set_value: (value) ->
#      console.log 'set', value
#      @value_node().src = value
#      @property.original_node.href = value if @property.original_node
      value = '' if value.match(@panel_placeholder_image())
      dojo.attr @icon_node, 'src', @get_icon_src(value)
      dojo.attr @title_node, 'innerHTML', decodeURIComponent(@get_filename(value))
      @_value = value


    value: ->
      @_value

    destroy: ->
      dojo.destroy @icon_node
      dojo.destroy @title_node
      @inherited arguments

    folder_name: ->
      @property.entry.delegate.attachments_folder_name()

    file_manager_icon_path: -> @property.entry.delegate.file_manager_icon_path()
    file_manager_no_file_name: -> @property.entry.delegate.file_manager_no_file_name()
