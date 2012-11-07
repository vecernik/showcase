define [ "dojo", 'admin/UBPropertyEditors/base' ], (dojo, EditorBase) ->

  dojo.declare EditorBase,


    constructor: (property, default_props) ->
      @inherited arguments


    build: ->
      node = dojo.create 'select', @props

      if @property.property.meta['select_null'] or no
#        null_option = dojo.create 'option', { innerHTML: @property.property.meta['select_null'], value: '' }
        null_option = new Option(@property.property.meta['select_null'], '')
#        console.log @property.property.meta['select_null']
#        console.log node.options.add
        node.options.add null_option

      for row in @property.property.meta.select
#        option = dojo.create 'option', { innerHTML: row[0], value: row[1] }
        option = new Option(row[0], row[1])
#        console.info option
        node.options.add option

#      console.log node
      node


    value: ->
      i = @selected_index()
      value = if i >= 0 then @value_node().options[i].value else ''
#      console.log @property.value(),  value
      value


    set_value: (value) ->
      options = @value_node().options

      selected = dojo.filter(options, (option) -> option.value == value)[0] or no

      @value_node().selectedIndex = dojo.indexOf(options, selected) if selected
#      console.log value, @value_node().selectedIndex, @value_node().options


    selected_index: ->
      @value_node().selectedIndex

