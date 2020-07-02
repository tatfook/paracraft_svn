--[[
Title: kid ui right container
Author(s): LiXizhi, Liuweili
Date: 2006/7/7
Desc: CommonCtrl.CKidRightContainer displays the right container of the ui
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/ui/right_container.lua");
CommonCtrl.CKidRightContainer.Initialize();
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("KidsUI");
-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/ui/Settings.lua");

-- if true, a tips icon will be displayed at the bottom right corner. 
--KidsUI.bShowTipsIcon = true;

-- define a new control in the common control libary

-- default member attributes
local CKidRightContainer = {
	-- normal window size
	obj_btn_width=32,
	name = "kidrightcontainer",
	contName="kidui_right_container",
	LastItemIndex = -1,
}
CommonCtrl.CKidRightContainer = CKidRightContainer;
CommonCtrl.AddControl(CKidRightContainer.name, CKidRightContainer);

function CKidRightContainer.Update()
	local self = CommonCtrl.GetControl("kidrightcontainer");
	if(self==nil)then
		log("err getting control kidrightcontainer\r\n");
		return;
	end
	self.Initialize();
end

function CKidRightContainer.Initialize()
	local self = CommonCtrl.GetControl("kidrightcontainer");
	if(self==nil)then
		log("err getting control kidrightcontainer\r\n");
		return;
	end
	local _this,_parent;
	_parent=ParaUI.GetUIObject(self.contName);
	if(_parent:IsValid()) then
		return;
	end
	
	self.LastItemIndex = -1;
--background images 	
	_this=ParaUI.CreateUIObject("container",self.contName.."bg","_rb",-256,-256,256,256);
	_this:AttachToRoot();
	_this.enabled = false;
	_this.background="Texture/kidui/right/bg.png";

--parent container
	_parent=ParaUI.CreateUIObject("container",self.contName,"_rb",-260,-134,258,130);
	_parent:AttachToRoot();
	_parent.background="Texture/whitedot.png;0 0 0 0";
	--_parent.background="Texture/alphadot.png";
	--_parent.receivedrag = true;
	
	NPL.load("(gl)script/kids/kids_db.lua");
	
	local left,top=4,4;
	local cords = {
		{22,96},
		{35,60},
		{62,32},
		{96,16},
		{135,16},
		{172,31},
		{197,60},
		{209,96},
	};
	local nSize = 32;
	local nIndex;
	for nIndex=1,8 do
		_this=ParaUI.CreateUIObject("button","kidui_r_btn"..nIndex,"_lt",cords[nIndex][1],cords[nIndex][2],nSize,nSize);
		_parent:AddChild(_this);
		local asset = ObjEditor.assets[nIndex];
		-- text
		if(asset.text~=nil) then
			_this.text = asset.text;
		elseif(asset.name~=nil) then	
			_this.text = asset.name;
		end	
		-- tooltip
		if(asset.tooltip==nil or asset.tooltip=="") then
			-- no tooltip
		else
			_this.tooltip=asset.tooltip;
		end
		-- background icon
		if(asset.icon==nil or asset.icon=="") then
			_this.background="Texture/kidui/main/button.png";
		else
			_this.background=asset.icon;
		end
		--_this.background=string.format([[Texture/kidui/right/btn_bg%d.png]],nIndex);
		
		--_this.animstyle = 12; -- use button animation. 
		local texture;
		_this:SetCurrentState("normal");
		texture=_this:GetTexture("background");
		texture.color="255 255 255";
		_this:SetCurrentState("highlight");
		texture=_this:GetTexture("background");
		texture.color="200 200 200";
		_this:SetCurrentState("pressed");
		texture=_this:GetTexture("background");
		texture.color="160 160 160";
		
		_this.onclick=string.format([[;CommonCtrl.CKidRightContainer.OnItemClick(%s);]],nIndex-1);
	end	
	
	_this=ParaUI.CreateUIObject("button","kidui_r_setup_btn","_lt",65,98,nSize,nSize);
	_parent:AddChild(_this);
	_this.tooltip=L"system settings";
	_this.background="Texture/kidui/right/btn_setup.png";
	_this.onclick=";KidsUI.ShowSettings();";
	
	_this=ParaUI.CreateUIObject("button","kidui_r_save_btn","_lt",92,65,nSize,nSize);
	_parent:AddChild(_this);
	_this.tooltip=L"save current world";
	_this.background="Texture/kidui/right/btn_save.png";
	_this.onclick="(gl)script/kids/saveworld.lua;";
	
	_this=ParaUI.CreateUIObject("button","kidui_r_return_btn","_lt",139,65,nSize,nSize);
	_parent:AddChild(_this);
	_this.tooltip=L"back one level\npress ESC key";
	_this.background="Texture/kidui/right/btn_return.png";
	--_this.onclick=[[;_guihelper.MessageBox("]]..L"Do you wish to restart the game?"..[[","KidsUI.restart();");]];
	_this.onclick=";KidsUI.OnEscKey()";
	
	_this=ParaUI.CreateUIObject("button","kidui_r_quit_btn","_lt",167,103,nSize,nSize);
	_parent:AddChild(_this);
	_this.tooltip=L"exit application";
	_this.background="Texture/kidui/right/btn_quit.png";
	_this.onclick=[[;_guihelper.MessageBox("]]..L"Do you wish to end the game?"..[[","KidsUI.OnExit();");]];
	
	if(KidsUI.bShowTipsIcon == true) then
		NPL.load("(gl)script/kids/ui/Help.lua");
		KidsUI.ShowTipsIcon(true);
	end	
end

--[[call back: when the 8 item button is pressed.
@param nItemIndex: 0..n]]
function CKidRightContainer.OnItemClick(nItemIndex)
	local self = CommonCtrl.GetControl("kidrightcontainer");
	if(self==nil)then
		log("err getting control kidrightcontainer\r\n");
		return;
	end
	ParaAudio.PlayUISound("Btn3");
	if(self.LastItemIndex == nItemIndex) then
		-- show or hide item bar
		if(CommonCtrl.CKidItemsContainer.visible == true) then
			CommonCtrl.CKidItemsContainer.show(false);
		else
			CommonCtrl.CKidItemsContainer.show(true);
		end
	else
		self.LastItemIndex = nItemIndex;
		-- update and show item bar
		CommonCtrl.CKidItemsContainer.ItemType = nItemIndex;
		CommonCtrl.CKidItemsContainer.ItemPage = 0;
		CommonCtrl.CKidItemsContainer.Update();
		CommonCtrl.CKidItemsContainer.show(true);
	end
end


-- Set the right container visibility
function CKidRightContainer.SetVisible(bVisible)
	local self = CommonCtrl.GetControl("kidrightcontainer");
	if(self==nil)then
		log("err getting control kidrightcontainer\r\n");
		return;
	end
	
	local _this,_parent;
	_parent=ParaUI.GetUIObject(self.contName);
	if(not _parent:IsValid()) then
		log("err kidrightcontainer not initialized\r\n");
		return;
	end
	
	_this = ParaUI.GetUIObject(self.contName.."bg");
	_this.visible = bVisible;

	_this = ParaUI.GetUIObject(self.contName);
	_this.visible = bVisible;
end