// Unobtrusive ajax loader/pager

// It was written mainly for
// http://www.graffiti-walls.com/flicks

// (c) 2010 Michal Zeravik


define([ 'dojo' ], function(dojo) { return dojo.declare(null,
{
	containerQuery: '.list',
	controllerQuery : 'BUTTON',
	pageRows: null,
	parameter: 'e[offset][queryname]',
	url: '/grid/e/list',
	loadingString: 'Nahrávání ...',
	loadingClass: 'loading',
	afterInit : false,

	_actualPage: 1,
//	_controlls: null,
	_openPageRows : 0,
	
	constructor : function(params, srcNodeRef)
	{
		this.srcNodeRef = dojo.byId(srcNodeRef) || false;
		
		if (!this.srcNodeRef) return false;
		
		dojo.safeMixin(this, params);
		
	// contents 
		
		this.containerNode = dojo.query(this.containerQuery, this.srcNodeRef)[0] || false;

		var firstControll = this.controlls()[0] || false;

		if (this.containerNode && firstControll)
		{
			this._connections = [];

			this._openPageRows = this.getLoadedItemCount();

			if (!this.pageRows) this.pageRows = parseInt(dojo.attr(firstControll, 'data-limit')); //this.controlls()[0].attr('[data-total]'));

			if (this.afterInit) this.afterInit();

			if (this._openPageRows < this.pageRows) this.destroyControlls(); else this.connect();
		}
	},
	
	getLoadedItemCount : function()
	{
		return dojo.query('> *', this.containerNode).length;
	},
	
	connect : function()
	{
		this._labels = [];

		this.controlls().forEach(function(ctl, i)
		{
			var value = dojo.attr(ctl, 'innerHTML');
			
			dojo.attr(ctl, { placeholder: value });
			
			this._connections.push(dojo.connect(ctl, 'onclick', this, 'clickOnControll'));
		},
		this);
	},

	disconnect : function()
	{
		this._connections.forEach(dojo.disconnect);
	},
	
	clickOnControll : function(e)
	{
		dojo.stopEvent(e);
		
		this.controllClicked(e.currentTarget);
	},
	
	presentIsLoading : function()
	{
		dojo.addClass(this.containerNode, this.loadingClass);
		
		this.controlls().forEach(function(node) 
		{
//			console.log(node, this.loadingClass);
			
			dojo.attr(node, { disabled: true });
			
			dojo.addClass(node, this.loadingClass);
		},
		this);
	},

	presentIsNotLoading : function()
	{
		dojo.removeClass(this.containerNode, this.loadingClass);

		this.controlls().forEach(function(node)
		{
			dojo.attr(node, { disabled: false });

			dojo.removeClass(node, this.loadingClass);
		},
		this);
	},

	controllClicked : function(node)
	{
		this.presentIsLoading();
		
		dojo.attr(node, { innerHTML: this.loadingString });

		this._actualPage++;

		var parameters = this._getParameters();
		
		parameters[this.parameter] = this._actualPage;
		
		dojo.mixin(parameters, this.getParameters());
//		console.log(parameters);
		dojo.xhrGet(
		{
			url : this.url,
			content : parameters,
			load : dojo.hitch(this, function(data) 
			{
				this.presentIsNotLoading();

				if (data.length > 1)
				{
					var label = dojo.attr(node, 'placeholder');
					
					dojo.attr(node, { innerHTML: label });
					
					dojo.place(data, this.containerNode, 'last');

					var justLoadedCount = this.getLoadedItemCount() - this._openPageRows;

					if (justLoadedCount < this.pageRows) this.destroyControlls();
				}
				else
				{
					this.destroyControlls();
				}

				this._openPageRows += this.pageRows;
			}),
			preventCache: !!dojo.isIE
		});
	},

	destroyControlls : function()
	{
		this.disconnect();

		this.controlls().forEach(dojo.destroy);
	},
	
	controlls : function()
	{
		return dojo.query(this.controllerQuery, this.srcNodeRef);
	},
	
	_getParameters: function()
	{
		return dojo.queryToObject(window.location.search.substring(1));
	},
	
	getParameters: function()
	{
		return {};
	}
})});
