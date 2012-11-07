define [ "dojo" ], (dojo) ->
#  console.log InlineEditBox

  dojo.declare null,

    debug: no

  # private

    delegate: null
    active_panel_state: null
    previous_panel_state: null


    constructor: (config) ->
      dojo.safeMixin this, config
      dojo.query('>html').addClass("live-admin")


    go_to_step: (state) ->

      dojo.query('>html').removeClass("admin-state-#{@active_panel_state}") if @active_panel_state
      dojo.query('>html').addClass("admin-state-#{state}")

      return if state == @active_panel_state

      @previous_panel_state = @active_panel_state
#      console.log @active_panel_state, state

      dojo.forEach [0,1,2,3,4], ((n) ->
        if n == state then @show_panel_step(n) else @hide_panel_step(n)
      ),
      this

      if state == 2 or state == 3 or state == 4
        @mark_editable_containers @delegate.editable_manager.containers
      else
        @unmark_editable_containers @delegate.editable_manager.containers

      @active_panel_state = state


    is_editing: ->
      dojo.query(".#{@editable_input_class()}").filter((node) -> dojo.style(node, 'display') != 'none').length > 0


    focus_first_editing: ->
      node = dojo.query("INPUT.#{@editable_input_class()}, TEXTAREA.#{@editable_input_class()}").filter((node) -> dojo.style(node, 'display') != 'none')[0] or no
      node.focus() if node


    go_back: ->
      @go_to_step(@previous_panel_state)

  # wrappery atributu

    editable_class: -> @delegate.editable_class
    editable_container_class: -> @delegate.editable_container_class
    loading_class: -> @delegate.loading_class
    editing_entry_class: -> @delegate.editing_entry_class
    last_editing_entry_class: -> @delegate.last_editing_entry_class
    editable_input_class: -> @delegate.editable_input_class


  # tools

    container_node: (name) -> dojo.byId name
    hide_panel_step: (n) -> dojo.style(@panel_button_node(n), display: 'none')
    show_panel_step: (n) -> dojo.style(@panel_button_node(n), display: 'block')
    hide_panel_editor: -> dojo.style(@panel_editor(), display: 'none')
    show_panel_editor: -> dojo.style(@panel_editor(), display: 'block')

    set_loading: (isLoading) ->
      if isLoading
        dojo.addClass @panel_node(), @loading_class()
      else
        dojo.removeClass @panel_node(), @loading_class()
      console.log('Loading: ', isLoading) if @debug

    mark_editable_containers: (containers) -> @mark_editable_containers_with(containers, yes)
    unmark_editable_containers: (containers) -> @mark_editable_containers_with(containers, no)

    mark_editable_containers_with: (containers, to_mark=yes) ->
      for name, container of containers
        @mark_editable_container_with container, to_mark if to_mark != container.marked
      true

    mark_editable_container_with: (container, to_mark) ->
      container.marked = to_mark
      @mark_node_with(container.key_name, to_mark, @editable_container_class())

      for entry_id, entry of @delegate.editable_manager.entries_for(container.key_name)
        @mark_node_with entry.node, to_mark
        for name, property of entry.editable_properties
          @mark_node_with property.original_node, to_mark


    mark_node_with: (id, to_mark, class_name=@editable_class()) ->
      node = dojo.byId id
      if to_mark
        dojo.addClass node, class_name
      else
        dojo.removeClass node, class_name


    mark_editing_entry_with: (id, to_mark) ->
      @mark_node_with id, to_mark, @editing_entry_class()


    mark_last_editing_entry_with: (id, to_mark) ->
      @mark_node_with id, to_mark, @last_editing_entry_class() if id


  # wrappery metod

    panel_node: -> @delegate.panel_node()
    panel_button_node: (n) -> dojo.byId('admin-step'+n)
    panel_editor: -> dojo.byId @delegate.panel_editor_id
