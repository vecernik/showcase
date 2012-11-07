define [ "dojo", 'admin/UBPropertyEditors/basedialog'], (dojo, BaseDialog) ->

  dojo.declare BaseDialog,

    folder_name: ->
      @property.entry.delegate.images_folder_name()


    dialog_url: ->
      m = @property.property.label.match(/([0-9]+x[0-9]+)/i)
      r = @inherited arguments
      r += "&px-size=#{m[1]}" if m and m[1]
      r
