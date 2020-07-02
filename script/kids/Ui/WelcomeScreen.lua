--[[
Title: Welcome screen
Author(s): LiXizhi
Date: 2007/6/15
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/Ui/WelcomeScreen.lua");
WelcomeScreen.Show("HideWelcomeWorldWindow", "Texture/ParaEngineLogo_cn.swf");
WelcomeScreen.Show("HideWelcomeWorldWindow", "Texture/ParaEngineLogo_cn.swf", "lefttop_normal");
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/OneTimeAsset.lua");
local L = CommonCtrl.Locale("KidsUI");

if(not WelcomeScreen) then WelcomeScreen={}; end

WelcomeScreen.userinfoField = nil;
WelcomeScreen.contentFilename = nil;

-- Show the welcome screen
-- e.g. WelcomeScreen.Show("HideWelcomeWorldWindow", "Texture/ParaEngineLogo_cn.swf");
-- @param userinfoFieldName: String: such as "HideWelcomeWorldWindow", more information, please see kids_db.User.userinfo
--  this can be nil, in which case the state of the always display checkbox is not saved.
-- @param contentFilename: the relative path of a flash or image file. 
-- @param style: it can be nil, "center_toplevel" or "lefttop_normal". nil is the same as "center_toplevel", 
--   "center_toplevel": displayed as top level in the center of the screen. "lefttop_normal": displayed at left top as normal window
function WelcomeScreen.Show(userinfoFieldName, contentFilename, style)
	local _this,_parent;
	if(contentFilename==nil or contentFilename =="") then
		return
	end
	WelcomeScreen.userinfoField = userinfoFieldName;
	WelcomeScreen.contentFilename = contentFilename;
	CommonCtrl.OneTimeAsset.Add("WelcomeScreen", contentFilename)
	
	_this=ParaUI.GetUIObject("WelcomeScreen_cont");
	if(_this:IsValid() == false) then
	
		if(style ~= nil and style=="lefttop_normal") then 
			local width, height = 480, 400;
			_this=ParaUI.CreateUIObject("container","WelcomeScreen_cont", "_lt", 0, 0, width, height);
		else --"center_toplevel" or nil
			local width, height = 558, 408;
			_this=ParaUI.CreateUIObject("container","WelcomeScreen_cont", "_ct", -width/2, -height/2-50, width, height);
			_this:SetTopLevel(true);
			
			KidsUI.PushState({name = "WelcomeScreen", OnEscKey = WelcomeScreen.OnDestory});
		end	
		
		_this.background="Texture/whitedot.png";
		_guihelper.SetUIColor(_this, "200 200 200 128");
		_this:AttachToRoot();
		_parent = _this;
		
		local fileext = ParaIO.GetFileExtension(contentFilename);
		local left,top,width, height = 5,10,5,60
		if ( fileext== "swf" or fileext== "flv") then
			NPL.load("(gl)script/ide/FlashPlayerControl.lua");
			local ctl = CommonCtrl.FlashPlayerControl:new{
				name = "WelcomeScreen_FlashPlayerControl1",
				FlashPlayerIndex = 0,
				alignment = "_fi",
				left=left, top=top,
				width = width,
				height = height,
				parent = _parent,
			};
			ctl:Show();
			ctl:LoadMovie(contentFilename);
		else
			_this = ParaUI.CreateUIObject("container", "WelcomeScreen_Content", "_fi", left,top,width, height)
			_this.background=contentFilename;	
			_parent:AddChild(_this);
		end

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "WelcomeScreen_checkBoxShowNextTime",
			alignment = "_lb",
			left = 31,
			top = -50,
			width = 171,
			height = 20,
			parent = _parent,
			isChecked = true,
			text = L"Always display this screen",
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("button", "button1", "_rb", -135, -53, 100, 26)
		_this.text=L"Close";
		_this.onclick=";WelcomeScreen.OnDestory();";
		_parent:AddChild(_this);
		
	else
		WelcomeScreen.OnDestory();
	end	
end

-- destory the control
function WelcomeScreen.OnDestory()
	KidsUI.PopState("WelcomeScreen");
	ParaUI.Destroy("WelcomeScreen_cont");
	CommonCtrl.OneTimeAsset.Add("WelcomeScreen", nil);
	
	if(WelcomeScreen.userinfoField~=nil) then
		local alwaysHide;
		local ctl = CommonCtrl.GetControl("WelcomeScreen_checkBoxShowNextTime");
		if(ctl ~=nil) then
			alwaysHide = not ctl:GetCheck();
			if(not alwaysHide) then
				alwaysHide = nil;
			end
		end
		if(alwaysHide ~= kids_db.User.userinfo[WelcomeScreen.userinfoField]) then
			kids_db.User.userinfo[WelcomeScreen.userinfoField] = alwaysHide;
			kids_db.User.SaveUserInfo();
		end
	end
end