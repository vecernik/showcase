define [ "dojo", 'admin/UBPanelEditorManager', 'admin/UBEditablePanelProperty' ],
(dojo, UBPanelEditorManager, UBEditablePanelProperty) ->

  dojo.declare UBPanelEditorManager,

    properties: null
    fieldset_class: 'form-horizontal'


    constructor: (config) ->
      @inherited arguments
      @properties = {}

      for prop_name, property of @editable_manager().setup_properties
        attributes = name: prop_name, entry: { delegate: this }, property: property, loaded: yes
        @properties[prop_name] = new UBEditablePanelProperty attributes
        @properties[prop_name].populate_value property.content


    create_container_with_legend: (legend=false) ->
      container = @inherited arguments
      dojo.addClass(container, 'setup-manager');
      container


    start: (editable_manager) ->
      dialog = @editable_manager().open_dialog({
        title: @setup_dialog_title()
#        href: @setup_manager_url()
      })
#      dojo.hitch this, 'started')
#      @started(dialog)
#    started: (dialog) ->
      container_node = @edit_with_properties @properties

      @attach_submit_to container_node

      dojo.create 'input', { type: 'hidden', name: 'authenticity_token', value: @editable_manager().authenticity_token()}, container_node

      dojo.attr @panel_form_node(), action: @setup_update_url(), method: 'post'

      dialog.UBConnections.push dojo.connect(@panel_form_node(), 'onsubmit', this, 'dialog_form_submit')

      dialog.layout()

#      page_container = @create_container_with_legend 'SEO'



    dialog_form_submit: (event) ->
#      dojo.stopEvent event
#
      @delegate.event_manager.set_loading yes
      @delegate.event_manager.go_to_step 4
#
#      content = dojo.formToObject(@panel_form_node())
#      content.authenticity_token =
#
#      dojo.xhrPost({
#        url: @setup_update_url()
##        handleAs: 'json'
#        content: content
#        error: dojo.hitch @delegate, 'backend_error'
#      })
#      .then( dojo.hitch this, 'dialog_form_submitted' )
#
#
#    dialog_form_submitted: ->
#      @editable_manager().close_dialog()
#      @delegate.event_manager.set_loading no
#      @delegate.event_manager.go_to_step 1
#    # TODO hlaska ok
##      window.location.reload()



  # tools

    attach_submit_to: (container) ->
      fs = dojo.create 'fieldset', { class: 'actions form-actions'}, container
      dojo.create 'input', { type: 'submit', class: 'btn btn-primary', value: @setup_submit_title()}, fs


    default_props_for: (propname) ->
      props = @inherited arguments
      props.required = 'required'
      props.name = "properties[#{propname}]"
      props


    panel_editor: -> @editable_manager().dialog.containerNode # if @editable_manager().dialog

#    panel_form_node: -> dojo.create('form', { action: 'post' }, @panel_editor(), 'first')


  # wrappery

    editable_manager: -> @delegate.editable_manager
#    setup_manager_url: -> @delegate.setup_manager_url
    setup_dialog_title: -> @delegate.setup_dialog_title
    setup_submit_title: -> @delegate.setup_submit_title
    setup_update_url: -> @delegate.setup_update_url
    undo_editing_entry: (entry) -> @delegate.undo_editing_entry(entry)
    confirm_persist: (entry, event) ->
      yes
