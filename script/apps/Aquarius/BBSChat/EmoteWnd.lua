--[[
Title: The emotion icons window used during chat
Author(s): WangTian
Date: 2008/10/26
Desc: It show/hide the emotion chat icons window. the emotion icon window displays a grid of chat icons or avatar actions, which can be used during chat. 
Implementation: this can be done either in pure NPL, or pure MCML.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/BBSChat/EmoteWnd.lua");
MyCompany.Aquarius.EmoteWnd.Show(bShow);
------------------------------------------------------------
]]

-- create class
local EmoteWnd = {
	name = "HelloEmoteWnd",
};
commonlib.setfield("MyCompany.Aquarius.EmoteWnd", EmoteWnd);

-- show or hide task bar UI
function EmoteWnd.Show(bShow)
	local _this, _parent;
	local left,top,width,height;
	
	_this = ParaUI.GetUIObject(EmoteWnd.name);
	if(_this:IsValid())then
		if(bShow==nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	else
		if( bShow == false)then
			return;
		end
		local left,top,width, height = 0, 0, 350,27;
		_this = ParaUI.CreateUIObject("container", EmoteWnd.name, "_lb", 0, -200, 350, 165);
		--_this.background = "";
		--_this.zorder = 5; -- make it stay on top. 
		_this:AttachToRoot();
		_parent = _this;
	end
end
