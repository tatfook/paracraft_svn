--[[
Title: world info control
Author(s): LiXizhi
Date: 2007/1/12
Desc: it displays a world information window, such as user name and world description. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/ui/worldinfoCtrl.lua");
local info = {
	creator = "LiXizhi",
	date = "2007/1/2",
	background="Texture/whitedot.png", -- 1024*768
	copyright = "Copyrighted By ParaEngine Tech Studio",
	desc = "this is a demo \nYou can add your world description text here ",
}
KidsUI.ShowWorldInfo(info);
------------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/commonlib.lua");
local L = CommonCtrl.Locale:new("KidsUI");

if(not KidsUI) then KidsUI={}; end
KidsUI.DefaultWorldBackGround = "Texture/kidui/main/loading.png"
-- @param info: table containing the fields: creator, date, background, copyright and desc. all fields are optional.
function KidsUI.ShowWorldInfo(info)
	local _this,_parent;
	if(info == nil) then
		_parent=ParaUI.GetUIObject("KidsUI_worldinfo_cont");
		if(_parent:IsValid()==true) then
			local str = _parent.background;
			ParaUI.Destroy("KidsUI_worldinfo_cont");
			ParaAsset.LoadTexture("",str,1):UnloadAsset();
		end	
	else
		KidsUI.worldinfo = info;
		local left, top, width, height;
		width, height = 579, 440;
		ParaUI.Destroy("KidsUI_worldinfo_cont");
		_parent=ParaUI.CreateUIObject("container","KidsUI_worldinfo_cont", "_ct",-width/2,-height/2,width, height);
		if(info.background~=nil) then
			_parent.background=info.background;
		else
			_parent.background=KidsUI.DefaultWorldBackGround;
		end	
		_parent:SetTopLevel(true);
		_parent:AttachToRoot();
		-- creator name
		left, top, width, height = 90,55,120,16;
		if(info.creator~=nil) then
			_this=ParaUI.CreateUIObject("text","t", "_lt",left, top, width, height);
			_parent:AddChild(_this);
			_this.text=L"world creator";
			
			_this=ParaUI.CreateUIObject("text","t", "_lt",left+width, top, 400, height);
			_parent:AddChild(_this);
			_this.text=info.creator;
			top = top+height+10;
		end	
		-- Date
		if(info.date~=nil) then
			_this=ParaUI.CreateUIObject("text","t", "_lt",left, top, width, height);
			_parent:AddChild(_this);
			_this.text=L"world date";
			
			_this=ParaUI.CreateUIObject("text","t", "_lt",left+width, top, 400, height);
			_parent:AddChild(_this);
			_this.text=info.date;
			top = top+height+10;
		end	
		local textwidth = 390
		-- copyright notice
		if(info.copyright~=nil) then
			_this=ParaUI.CreateUIObject("text","t", "_lt",left, top, width, height);
			_parent:AddChild(_this);
			_this.text=L"world copyright";
			top = top+height+10;
			
			_this=ParaUI.CreateUIObject("text","t", "_lt",left, top, textwidth, height);
			_parent:AddChild(_this);
			_this.text=info.copyright;
			top = top+height+10;
		end	
		-- world description 
		if(info.desc~=nil) then
			_this=ParaUI.CreateUIObject("text","t", "_lt",left, top, width, height);
			_parent:AddChild(_this);
			_this.text=L"world description";
			top = top+height+10;
			
			_this=ParaUI.CreateUIObject("container","c", "_lt",left, top, textwidth,200);
			_parent:AddChild(_this);
			_this.scrollable=true;
			_this.background="Texture/whitedot.png;0 0 0 0";
			local _cont = _this;
			
			_this=ParaUI.CreateUIObject("text","t", "_lt",0, 0, textwidth-20, height);
			_cont:AddChild(_this);
			_this.text=info.desc;
			_this:DoAutoSize();
			_cont:InvalidateRect();
		end	
		
		-- any mouse click to continue
		_this=ParaUI.CreateUIObject("button","b", "_lt",0,0,_parent.width,_parent.height);
		_parent:AddChild(_this);
		_this.background="Texture/whitedot.png;0 0 0 0";
		_this.onclick = ";KidsUI.ShowWorldInfo()";
			
		-- ok button to close this window
		_this=ParaUI.CreateUIObject("button","close", "_rb",-150,-40,80,30);
		_parent:AddChild(_this);
		_this.text=L"OK";
		_this.onclick = ";KidsUI.ShowWorldInfo()";
	end	
end

function KidsUI.EditWorldInfo(bShow)
	local _this,_parent;
	
	_parent=ParaUI.GetUIObject("KidsUI_worldinfo_cont");
	if(_parent:IsValid()==true) then
		return
	end
		
	local _this = ParaUI.GetUIObject("KidsUI_worldinfo_edit_cont")
	if(_this:IsValid() == false) then 
		if(bShow == false) then return	end
		
		if(not KidsUI.worldinfo) then 
			KidsUI.worldinfo = {}
		end
		local info = KidsUI.worldinfo;
		
		local left, top, width, height;
		width, height = 579, 440;
		ParaUI.Destroy("KidsUI_worldinfo_edit_cont");
		_parent=ParaUI.CreateUIObject("container","KidsUI_worldinfo_edit_cont", "_ct",-width/2,-height/2,width, height);
		if(info.background~=nil) then
			_parent.background=info.background;
		else
			_parent.background=KidsUI.DefaultWorldBackGround;
		end	
		_parent:SetTopLevel(true);
		_parent:AttachToRoot();
		-- creator name
		left, top, width, height = 90,55,120,16;
		_this=ParaUI.CreateUIObject("text","t", "_lt",left, top, width, height);
		_parent:AddChild(_this);
		_this.text=L"world creator";
		
		local textwidth = 270
		_this=ParaUI.CreateUIObject("imeeditbox","worldeditor_creator_editbox", "_lt",left+width, top, textwidth, 25);
		_parent:AddChild(_this);
		if(info.creator~=nil) then
			_this.text=info.creator;
		end	
		top = top+height+10;
		
		-- Date
		_this=ParaUI.CreateUIObject("text","t", "_lt",left, top, width, height);
		_parent:AddChild(_this);
		_this.text=L"world date";
		
		_this=ParaUI.CreateUIObject("imeeditbox","worldeditor_date_editbox", "_lt",left+width, top, textwidth, 25);
		_parent:AddChild(_this);
		if(info.date~=nil) then
			_this.text=info.date;
		end	
		top = top+height+10;
		
		textwidth = 390
		-- copyright notice
		_this=ParaUI.CreateUIObject("text","t", "_lt",left, top, width, height);
		_parent:AddChild(_this);
		_this.text=L"world copyright";
		top = top+height+10;
		
		_this=ParaUI.CreateUIObject("imeeditbox","worldeditor_copyright_editbox", "_lt",left, top, textwidth, 25);
		_parent:AddChild(_this);
		if(info.copyright~=nil) then
			_this.text=info.copyright;
		end	
		top = top+height+10;
		
		-- world description 
		_this=ParaUI.CreateUIObject("text","t", "_lt",left, top, width, height);
		_parent:AddChild(_this);
		_this.text=L"world description";
		top = top+height+10;
		
		_this=ParaUI.CreateUIObject("imeeditbox","worldeditor_addline_editbox", "_lt",left, top, textwidth, 25);
		_parent:AddChild(_this);
		_this.onchange=";KidsUI.OnWorldInfoAddlineChange();";
		
		top = top+height+10;
		
		_this=ParaUI.CreateUIObject("container","c", "_lt",left, top, textwidth,170);
		_parent:AddChild(_this);
		_this.scrollable=true;
		_this.background="Texture/whitedot.png;0 0 0 0";
		local _cont = _this;
		
		_this=ParaUI.CreateUIObject("text","worldeditor_desc", "_lt",0, 0, textwidth-20, height);
		_cont:AddChild(_this);
		if(info.desc~=nil) then
			_this.text=info.desc;
			_this:DoAutoSize();
			_cont:InvalidateRect();
		end	
		
		-- save button
		_this=ParaUI.CreateUIObject("button","close", "_rb",-150-90,-40,80,30);
		_parent:AddChild(_this);
		_this.text=L"Save";
		_this.onclick = ";KidsUI.OnSaveWorldInfo()";
			
		-- ok button to close this window
		_this=ParaUI.CreateUIObject("button","close", "_rb",-150,-40,80,30);
		_parent:AddChild(_this);
		_this.text=L"OK";
		_this.onclick = ";KidsUI.EditWorldInfo()";
	else
		if(bShow == nil) then
			if(_this.visible == true) then
				_this.visible = false;
			else
				_this.visible = true;
			end
		else
			_this.visible = bShow;
		end
	end
	if(_this.visible == true) then
		_this:SetTopLevel(true);
	end
end

function KidsUI.OnSaveWorldInfo()
	KidsUI.EditWorldInfo(false);
	if(not KidsUI.worldinfo) then 
		KidsUI.worldinfo = {}
	end
	local info = KidsUI.worldinfo;
	local temp;
	
	temp = ParaUI.GetUIObject("worldeditor_creator_editbox");
	if(temp:IsValid()==true) then
		if(temp.text~="") then
			info.creator = temp.text;
		else	
			info.creator = nil;
		end
	end
	
	temp = ParaUI.GetUIObject("worldeditor_date_editbox");
	if(temp:IsValid()==true) then
		if(temp.text~="") then
			info.date = temp.text;
		else	
			info.date = nil;
		end
	end
	
	temp = ParaUI.GetUIObject("worldeditor_copyright_editbox");
	if(temp:IsValid()==true) then
		if(temp.text~="") then
			info.copyright = temp.text;
		else	
			info.copyright = nil;
		end
	end
	
	temp = ParaUI.GetUIObject("worldeditor_desc");
	if(temp:IsValid()==true) then
		if(temp.text~="") then
			info.desc = temp.text;
		else	
			info.desc = nil;
		end
	end
		
	if(not info.creator and not info.date and not info.copyright and not info.desc) then
		local sOnLoadScript = ParaWorld.GetWorldDirectory().."onload.lua";
		if(ParaIO.DoesFileExist(sOnLoadScript)==true)then
			ParaIO.DeleteFile(sOnLoadScript);
		end
	else
		local sOnLoadScript = ParaWorld.GetWorldDirectory().."onload.lua";
		if(ParaIO.DoesFileExist(sOnLoadScript)==true)then
			ParaIO.BackupFile(sOnLoadScript);
			ParaIO.DeleteFile(sOnLoadScript);
		end
		local file = ParaIO.open(sOnLoadScript, "w");
		file:WriteString([[-- auto generated by Kids Movie Creator: worldinfoCtrl.lua
NPL.load("(gl)script/kids/ui/worldinfoCtrl.lua");
]]);
		file:WriteString("local worldinfo = ");
		local str = commonlib.serialize(info);
		file:WriteString(str);
		file:WriteString([[
local function activate()
	KidsUI.ShowWorldInfo(worldinfo);
end
NPL.this(activate);
		]]);
		file:close();
		
		_guihelper.MessageBox("world info has been successfully saved to \r\n"..sOnLoadScript);
	end
end

function KidsUI.OnWorldInfoAddlineChange()
	if(virtual_key == Event_Mapping.EM_KEY_RETURN or virtual_key == Event_Mapping.EM_KEY_NUMPADENTER) then
		local temp = ParaUI.GetUIObject("worldeditor_desc");
		if(temp:IsValid()==true) then
			local editbox = ParaUI.GetUIObject("worldeditor_addline_editbox");
			if(editbox:IsValid()==true) then
				temp.text = string.gsub(editbox.text, "\\n", "\n");
				temp:DoAutoSize();
				temp.parent:InvalidateRect();
			end
		end
	end
end

