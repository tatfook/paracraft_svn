local function activate()
local __this,__parent,__font,__texture;
if(_demo_state_openedwin~="item_container")then
	if(_demo_state_openedwin~=nil)then
		ParaUI.Destroy(_demo_state_openedwin);
	end
	_demo_state_openedwin="item_container";
	
	_guihelper.CheckRadioButtons( _demo_person_pages, "person_items", "255 0 0");
	
	__this=ParaUI.CreateUIObject("container","item_container", "_lt",30,60,299,390);
	__parent=ParaUI.GetUIObject("demo_main");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	__texture=__this:GetTexture("background");
	__texture.transparency=0;
	
	__this=ParaUI.CreateUIObject("container","item_c1", "_lt",8,30,280,75);
	__parent=ParaUI.GetUIObject("item_container");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	__texture=__this:GetTexture("background");
	__texture.transparency=0;
	
	__this=ParaUI.CreateUIObject("container","container9", "_lt",18,7,50,50);
	__parent=ParaUI.GetUIObject("item_c1");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	
	__this=ParaUI.CreateUIObject("container","container10", "_lt",82,6,50,50);
	__parent=ParaUI.GetUIObject("item_c1");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	
	__this=ParaUI.CreateUIObject("container","container11", "_lt",148,6,50,50);
	__parent=ParaUI.GetUIObject("item_c1");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	
	__this=ParaUI.CreateUIObject("container","container12", "_lt",213,6,50,50);
	__parent=ParaUI.GetUIObject("item_c1");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	
	__this=ParaUI.CreateUIObject("text","text25", "_lt",23,55,42,22);
	__parent=ParaUI.GetUIObject("item_c1");__parent:AddChild(__this);
	__this.text="主手";
	__this.autosize=true;
	
	__this=ParaUI.CreateUIObject("text","text26", "_lt",88,53,42,22);
	__parent=ParaUI.GetUIObject("item_c1");__parent:AddChild(__this);
	__this.text="副手";
	__this.autosize=true;
	
	__this=ParaUI.CreateUIObject("text","text27", "_lt",154,54,42,22);
	__parent=ParaUI.GetUIObject("item_c1");__parent:AddChild(__this);
	__this.text="远程";
	__this.autosize=true;
	
	__this=ParaUI.CreateUIObject("text","text28", "_lt",219,53,42,22);
	__parent=ParaUI.GetUIObject("item_c1");__parent:AddChild(__this);
	__this.text="弹药";
	__this.autosize=true;
	
	__this=ParaUI.CreateUIObject("container","item_c3", "_lt",8,294,280,75);
	__parent=ParaUI.GetUIObject("item_container");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	__texture=__this:GetTexture("background");
	__texture.transparency=0;
	
	__this=ParaUI.CreateUIObject("container","container21", "_lt",18,6,50,50);
	__parent=ParaUI.GetUIObject("item_c3");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	
	
	__this=ParaUI.CreateUIObject("container","container23", "_lt",149,6,50,50);
	__parent=ParaUI.GetUIObject("item_c3");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	
	
	__this=ParaUI.CreateUIObject("container","container22", "_lt",82,6,50,50);
	__parent=ParaUI.GetUIObject("item_c3");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	
	
	__this=ParaUI.CreateUIObject("container","container24", "_lt",215,6,50,50);
	__parent=ParaUI.GetUIObject("item_c3");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	
	__this=ParaUI.CreateUIObject("text","text38", "_lt",24,53,42,22);
	__parent=ParaUI.GetUIObject("item_c3");__parent:AddChild(__this);
	__this.text="项链";

	__this=ParaUI.CreateUIObject("text","text39", "_lt",87,54,42,22);
	__parent=ParaUI.GetUIObject("item_c3");__parent:AddChild(__this);
	__this.text="戒指";
	__this.autosize=true;

	__this=ParaUI.CreateUIObject("text","text40", "_lt",156,53,42,22);
	__parent=ParaUI.GetUIObject("item_c3");__parent:AddChild(__this);
	__this.text="戒指";
	__this.autosize=true;
	
	__this=ParaUI.CreateUIObject("text","text41", "_lt",222,53,42,22);
	__parent=ParaUI.GetUIObject("item_c3");__parent:AddChild(__this);
	__this.text="标志";
	__this.autosize=true;

	__this=ParaUI.CreateUIObject("text","text6", "_lt",7,10,42,22);
	__parent=ParaUI.GetUIObject("item_container");__parent:AddChild(__this);
	__this.text="武器";
	__this.autosize=true;
	
	__this=ParaUI.CreateUIObject("text","text7", "_lt",6,105,42,22);
	__parent=ParaUI.GetUIObject("item_container");__parent:AddChild(__this);
	__this.text="护甲";
	__this.autosize=true;
	
	__this=ParaUI.CreateUIObject("text","text8", "_lt",5,274,42,22);
	__parent=ParaUI.GetUIObject("item_container");__parent:AddChild(__this);
	__this.text="饰物";
	__this.autosize=true;
	
	__this=ParaUI.CreateUIObject("container","item_c2", "_lt",8,125,280,150);
	__parent=ParaUI.GetUIObject("item_container");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	__texture=__this:GetTexture("background");
	__texture.transparency=0;
	
	__this=ParaUI.CreateUIObject("container","container17", "_lt",18,80,50,50);
	__parent=ParaUI.GetUIObject("item_c2");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	
	__this=ParaUI.CreateUIObject("container","container18", "_lt",82,80,50,50);
	__parent=ParaUI.GetUIObject("item_c2");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	
	__this=ParaUI.CreateUIObject("container","container20", "_lt",215,80,50,50);
	__parent=ParaUI.GetUIObject("item_c2");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";

	__this=ParaUI.CreateUIObject("container","container13", "_lt",18,6,50,50);
	__parent=ParaUI.GetUIObject("item_c2");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	
	
	__this=ParaUI.CreateUIObject("container","container14", "_lt",82,6,50,50);
	__parent=ParaUI.GetUIObject("item_c2");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	
	
	__this=ParaUI.CreateUIObject("container","container16", "_lt",214,6,50,50);
	__parent=ParaUI.GetUIObject("item_c2");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	
	
	__this=ParaUI.CreateUIObject("container","container15", "_lt",149,6,50,50);
	__parent=ParaUI.GetUIObject("item_c2");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	
	
	__this=ParaUI.CreateUIObject("container","container19", "_lt",149,80,50,50);
	__parent=ParaUI.GetUIObject("item_c2");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/item.png;";
	
	__this=ParaUI.CreateUIObject("text","text29", "_lt",26,53,42,22);
	__parent=ParaUI.GetUIObject("item_c2");__parent:AddChild(__this);
	__this.text="帽子";
	__this.autosize=true;
	
	__this=ParaUI.CreateUIObject("text","text30", "_lt",89,54,42,22);
	__parent=ParaUI.GetUIObject("item_c2");__parent:AddChild(__this);
	__this.text="护肩";
	__this.autosize=true;
	
	__this=ParaUI.CreateUIObject("text","text31", "_lt",154,54,42,22);
	__parent=ParaUI.GetUIObject("item_c2");__parent:AddChild(__this);
	__this.text="上衣";
	__this.autosize=true;

	__this=ParaUI.CreateUIObject("text","text32", "_lt",219,54,42,22);
	__parent=ParaUI.GetUIObject("item_c2");__parent:AddChild(__this);
	__this.text="披风";
	__this.autosize=true;

	__this=ParaUI.CreateUIObject("text","text33", "_lt",24,128,42,22);
	__parent=ParaUI.GetUIObject("item_c2");__parent:AddChild(__this);
	__this.text="护腕";
	__this.autosize=true;

	__this=ParaUI.CreateUIObject("text","text34", "_lt",88,128,42,22);
	__parent=ParaUI.GetUIObject("item_c2");__parent:AddChild(__this);
	__this.text="手套";
	__this.autosize=true;

	__this=ParaUI.CreateUIObject("text","text36", "_lt",155,128,42,22);
	__parent=ParaUI.GetUIObject("item_c2");__parent:AddChild(__this);
	__this.text="护腕";
	__this.autosize=true;

	__this=ParaUI.CreateUIObject("text","text37", "_lt",221,128,42,22);
	__parent=ParaUI.GetUIObject("item_c2");__parent:AddChild(__this);
	__this.text="鞋子";
	__this.autosize=true;
	
end

end
NPL.this(activate);
