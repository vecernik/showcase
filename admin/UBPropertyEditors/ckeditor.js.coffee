define [ "dojo", 'admin/UBPropertyEditors/base' ], (dojo, EditorBase) ->

  dojo.declare EditorBase,

    ck_instance: null

    constructor: (property, default_props) ->
      @inherited arguments
#      @props.type = 'text'
#      console.log this
      @props.rows = 20
      @props.id = "ckeditor-#{Math.round(Math.random()*10000000000000)}"


    build: ->
      container = dojo.create 'div'
      @input_node = dojo.create 'textarea', @props, container
      container


    start_editing: ->
      config = @config()
      config.height = dojo.attr(@property.original_node, 'height') if @property['original_node']
      @ck_instance = CKEDITOR.replace(@value_node(), config)


    value: ->
      @ck_instance.getData()


    set_value: (value) ->
      @value_node().value = value
      @ck_instance.setData(value)


    destroy: ->
      @inherited arguments
      @ck_instance.destroy(yes)
      @ck_instance = null


    config: ->
      {
        customConfig : ''
        language : 'cs'
        uiColor : '#f0f0f0'
      #			extraPlugins : 'pastefromword,autogrow'
        extraPlugins : 'pastefromword,autogrow'

        height: 400

        pasteFromWordNumberedHeadingToList : true
        pasteFromWordRemoveFontStyles : true
        pasteFromWordRemoveStyles : true

        disableNativeSpellChecker : true
      #			disableNativeTableHandles : no

        enterMode : CKEDITOR.ENTER_P
        fillEmptyBlocks : no

        forcePasteAsPlainText : true

        removePlugins : 'about,a11yhelp,bidi,elementspath,find,font,forms,maximize,newpage,pagebreak,popup,preview,print,save,scayt,templates,wsc'

        shiftEnterMode : CKEDITOR.ENTER_BR

        entities_latin : no
        entities_processNumerical : no

        scayt_autoStartup : no

        fullPage : no

      #		resize_dir : 'vertical'

        toolbarCanCollapse : no

        format_tags : 'p;h2;h3;h4;h5;h6'

        removeFormatTags : 'big,del,dfn,font,ins,kbd,q,samp,span,strike,sub,sup,tt,u,var,script'
        removeFormatAttributes : 'style,lang,width,height,align,hspace,valign'

        toolbar : [
          ['Format', '-', 'Bold','Italic','Underline','Strike','-', 'JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock', '-', 'NumberedList', 'BulletedList', '-', 'Outdent','Indent', '-', 'Subscript','Superscript' ],# /*'Blockquote','CreateDiv'*/ ]
      #            ['Link','Unlink'/*,'Anchor'*/, '-', 'Image',/*'Anchor',*/ /*'Flash',*#*'-','Print','SpellChecker', 'Scayt'*/ /*'Styles',*/ /*'Font', *#*'Find','Replace','-',*#*'SelectAll',*/ 'Table', 'HorizontalRule', /*'SpecialChar', 'Smiley', */ '-', 'TextColor','BGColor', '-', 'Cut','Copy',/*'Paste',*/ 'PasteText', 'PasteWord', '-', 'Undo','Redo', '-', 'Source', '-', 'RemoveFormat', 'Maximize' ]
          ['Table', 'HorizontalRule', '-', 'TextColor','BGColor', '-', 'Cut','Copy', 'PasteText', 'PasteWord', '-', 'Undo','Redo', '-', 'Source', '-', 'RemoveFormat', 'Maximize' ]
      #			['Form','Checkbox','Radio','TextField','Textarea','Select','Button','HiddenField']
      #			'/'
      #			['Link','Unlink'/*,'Anchor'*/, '-', 'Image','Flash', '-', 'Table', 'HorizontalRule', 'SpecialChar', 'Smiley']
          #'/'
        ]

      #          on : {
      #            instanceReady : function( ev ) {
      #              @dataProcessor.writer.indentationChars = ''
      #              @dataProcessor.writer.sortAttributes = no
      #
      #              @dataProcessor.writer.setRules( 'p', { indent: no, breakBeforeOpen: true, breakAfterOpen: no, breakAfterClose: no });
      #            }/*
      #            blur : function(e) {
      #              #console.log(this, e, e.editor.container.$);
      #              #app && app.getContentPaneDijit(e.editor.container.$).setDirty();
      #            }
      #            key : function( ev )
      #            {
      #              app && app.getCurrentTab().setDirty();
      #            }*/
      #          }

      #			filebrowserBrowseUrl : '/fckbrowser.php?user[onlyimages]=1'
      #          filebrowserBrowseUrl : APPURL+'/grid/activeuser/ckbrowser?activeuser[onlyimages]=1'
      #			filebrowserBrowseUrl : APPURL+'/grid/activeuser/ckbrowser'
      #          filebrowserUploadUrl : APPURL+'/worker/activeuser/ckupload'
      #			filebrowserWindowWidth : '640'
      #			filebrowserWindowHeight : '480'

      #			resize_enabled : true
      #			removeDialogTabs : 'image:Link', - error

        defaultLanguage : 'cs'

        skin : 'office2003'
      }

