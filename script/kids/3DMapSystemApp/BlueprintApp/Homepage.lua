--[[
Title: template: windows form or modeless dialog
Author(s): [your name], original template by LiXizhi
Date: 2007/2/7
Parameters:
	Homepage: it needs to be a valid name, such as MyDialog
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/BlueprintApp/Homepage.lua");
Homepage.Show();
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");

if(not Homepage) then Homepage={}; end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function Homepage.Show(bShow)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("Homepage_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		_this=ParaUI.CreateUIObject("container","Homepage_cont","_lt",0,0,400,300);
		--_this.background="Texture/whitedot.png;0 0 0 0";
		_this:AttachToRoot();
		_parent = _this;
		
		local left, top, width, height = 0,0, 124, 32
		_this=ParaUI.CreateUIObject("button","Homepage_OK","_lt",left,top,width,height);
		_this.text="OK";
		_this.onclick=";Homepage.OnDestory();";
		_parent:AddChild(_this);
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
	end	
end

-- destory the control
function Homepage.OnDestory()
	ParaUI.Destroy("Homepage_cont");
end