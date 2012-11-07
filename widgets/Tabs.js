// Unobtrusive content switcher widget

// Simulation of animated tabs switching effect.

// It's used on various websites we authored :
// http://www.graffiti-walls.com/discover
// http://www.trussaluminium.com/ft33.html

// (c) 2009 Michal Zeravik


define([ 'dojo' ], function(dojo) { return dojo.declare(null,
{
// mandatory members
	tabs : 'DIV.tabs > UL > LI > A',
	contents : 'DIV.tabcontents > DIV',
	
// non-mandatory members
	selectedClass : 'selected',
	tabSuffix : '-content',
	showFunc : dojo.fadeIn,
	hideFunc : dojo.fadeOut,
	duration : 300,
	onClick : null,
	onTransitionEnd : null,
	onHideEnd : null,
	id : false,
	
	_tabs : null,
	_contents : null,
	_lastSelected : null,
	_showTransitionAnim : null,
	_hideTransitionAnim : null,

	constructor : function(params, srcNodeRef)
	{
		this._tabs = this._contents = [];
	
		this.srcNodeRef = dojo.byId(srcNodeRef) || false;
		
		if (!this.srcNodeRef) return;
		
		dojo.mixin(this, params);
		
		if (!this.id) this.id = this.srcNodeRef.id;
		
		this._tabs = dojo.query(this.tabs, this.srcNodeRef);
		this._contents = dojo.query(this.contents, this.srcNodeRef);

		this._lastSelected = dojo.filter(this._tabs, function(tab) { return dojo.hasClass(tab, this.selectedClass); }, this)[0] || this.tabOnIndex(0);
		
	// skryti ostatnich obsahu
		
		if (this._lastSelected) 
		{
			if (!dojo.hasClass(this._lastSelected, this.selectedClass)) dojo.addClass(this._lastSelected, this.selectedClass);
			
			dojo.forEach(this._contents, function(content) 
			{ 
				var props = (content.id != this._lastSelected.id+this.tabSuffix) ? { 'display' : 'none', 'opacity': 0 } : { 'display' : 'block', 'opacity': 1 };
				
				dojo.style(content, props); 
			}, 
			this);
		}
		
	// navazani tabu na klik
		
		this._tabs.connect('onclick', this, 'clickOnTab');
		
		this.afterInit();
	},
	
	clickOnTab : function(event)
	{
		var tab = event.currentTarget;

		if (tab.nodeName == 'A' || tab.nodeName == 'BUTTON') dojo.stopEvent(event);
		
		this.clickOn(tab);
	},
	
	clickOn : function(tabid)
	{
		var
			tab = dojo.byId(tabid)
//			i = dojo.indexOf(this._tabs, node),
//			tab = this.tabOnIndex(i)
		;
		
		tab.blur();
		
		return !this.isSelected(tab) && this._handleClickOnTab(tab);
	},
	
	tabOnIndex : function(index)
	{
		return  this._tabs[index] || false;
	},
	contentOnIndex : function(index)
	{
		var tab = this.tabOnIndex(index), content = null;
		
		if (tab) content = this.getContentByTab(tab);
		
		return content;
	},
	clickOnIndex : function(index)
	{
		var tab = this.tabOnIndex(index);
		
		return tab ? this.clickOn(tab) : false;
	},
	clickOnFirst : function()
	{
		return this.clickOnIndex(0);
	},
	
	_handleClickOnTab : function(tab)
	{
		if (this.onClick) this.onClick(tab);
		
		this._clickOnTab(tab);
	},
	
	_clickOnTab : function(tab)
	{
		var 
			lastContent = this.getContentByTab(this._lastSelected), 
			newContent = this.getContentByTab(tab),
			showAnimConfig = { 
				node: newContent, 
				duration: this.duration 
			},
			hideAnimConfig = { 
				node: lastContent, 
				duration: this.duration,
				onEnd: dojo.hitch(this, function() 
				{
					this._hideTransitionAnim = null;
					
					if (this.onHideEnd) this.onHideEnd(tab, newContent, lastContent);
					
					dojo.style(lastContent, {'display': 'none'});
					
					this._lastSelected = tab;
					
				// zobrazeni kliknuteho
					
					dojo.style(newContent, {'display': 'block'});
					
					this._showTransitionAnim.play();
				})
			}
		;
		
		dojo.removeClass(this._lastSelected, this.selectedClass);
		
		this.onBlur(this._lastSelected, lastContent);

		
		dojo.addClass(tab, this.selectedClass);
		
		this.onFocus(tab, newContent);
		
		
		this._hideTransitionAnim = this.hideFunc(hideAnimConfig);
		
		
		if (this.onTransitionEnd) showAnimConfig.onEnd = dojo.hitch(this, function() { this._showTransitionAnim = null; this.onTransitionEnd(tab, newContent); });
		
		this._showTransitionAnim = this.showFunc(showAnimConfig);
		
		
		this._hideTransitionAnim.play();
		
		return true;
	},
	
	onBlur : function(tab, lastContent) { },
	onFocus : function(tab, newContent) { },
	
	isSelected : function (tab)
	{
		var id = dojo.attr(tab, 'id');
		
		return this._lastSelected ? this._lastSelected.id == id : this.tabOnIndex(0).id == id;
	},
	
	getContentByTab : function (tab)
	{
		var id = dojo.attr(tab, 'id') + this.tabSuffix;
		
		return dojo.byId(id);
	},
	
	afterInit : function() {}
})});
