--[[
Title: kid ui left container
Author(s): LiXizhi, Liuweili
Date: 2006/7/7
Desc: CommonCtrl.CKidLeftContainer displays the left container of the ui

Revised: WangTian
Desc: CCS menu support 
Date: 2007/7/17

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/ui/left_container.lua");
CommonCtrl.CKidLeftContainer.Initialize();
------------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/gui_helper.lua");
local L = CommonCtrl.Locale("KidsUI");

-- define a new control in the common control libary

-- default member attributes
local CKidLeftContainer = {
	-- normal window size
	state="environment", -- "object" or "environment"
	obj_btn_width=30,
	name = "kidleftcontainer",
	filterindex = 0;
	filters = {
		[1] = { name = "anyobject", background = L"bk_object", text=L"l_object", tooltip = L"select object only"},
		[2] = { name = "global", background = L"bk_explore", text=L"l_light", tooltip = L"explore the scene"},
		[3] = { name = "light", background = L"bk_light", text=L"l_explore", tooltip = L"select light only"},
	};
	contName="kidui_left_container",
}

CommonCtrl.CKidLeftContainer = CKidLeftContainer;

CommonCtrl.AddControl(CKidLeftContainer.name, CKidLeftContainer);

-- switch to a new state
function CKidLeftContainer.SwitchUI(sName)
	local self = CommonCtrl.GetControl("kidleftcontainer");
	if(self==nil)then
		log("err getting control kidleftcontainer\r\n");
		return;
	end
	if(self.state ~= sName) then
		self.state=sName;
		self.Update();
	end
end

-- update the state, 
--@param newState: if this is nil, the current state is being updated.
function CKidLeftContainer.Update(newState)
	local self = CommonCtrl.GetControl("kidleftcontainer");
	if(self==nil)then
		log("err getting control kidleftcontainer\r\n");
		return;
	end
	if(newState~=nil) then
		self.state=newState;
	end
	
	local _this;
	if (self.state=="object")then
		ParaUI.GetUIObject(self.contName.."obj").visible=true;
		ParaUI.GetUIObject("kidui_l_objectdisplay").visible=true;
		ParaUI.GetUIObject(self.contName.."env").visible=false;
		
		ParaUI.GetUIObject("kidui_l_delete_btn").visible=true;
		ParaUI.GetUIObject("kidui_l_filter_btn").visible=false;
		
	elseif(self.state=="environment") then
		ParaUI.GetUIObject(self.contName.."obj").visible=false;
		ParaUI.GetUIObject("kidui_l_objectdisplay").visible=false;
		ParaUI.GetUIObject(self.contName.."env").visible=true;
		
		ParaUI.GetUIObject("kidui_l_delete_btn").visible=false;
		ParaUI.GetUIObject("kidui_l_filter_btn").visible=true;
	else
		log("leftcontainer: Unsupport state.\r\n");
	end
end

-- create all controls
function CKidLeftContainer.Initialize()
	local self = CommonCtrl.GetControl("kidleftcontainer");
	if(self==nil)then
		log("err getting control kidleftcontainer\r\n");
		return;
	end
	local _this,_parent,_parenv,_parobj,left,top, _texture;
	_parent=ParaUI.GetUIObject(self.contName);
	if(_parent:IsValid()) then
		return;
	end
	
	self.state="environment";
	self.filterindex = 0;
--background images 
	_this=ParaUI.CreateUIObject("container",self.contName.."bg","_lb",0,-256,256,256);
	_this:AttachToRoot();
	_this.enabled = false;
	_this.background="Texture/kidui/left/bg_normal.png";

--environment	
	--[[ TODO: should be the environment photo here.how about using the same control as 3d object display. 3D modeling. 
	_parenv.background="Texture/kidui/left/bg_environment.png";]]
	
	_parenv=ParaUI.CreateUIObject("container",self.contName.."env","_lb",128,-128,68,128);
	_parenv:AttachToRoot();
	_parenv.background="Texture/whitedot.png;0 0 0 0";
	--_parenv.background="Texture/alphadot.png";
	_parenv.visible=false;
	
	local obj_btn_width = 32;
	left, top = 2,9;
	_this=ParaUI.CreateUIObject("button","kidui_l_sky_btn","_lt",left, top, obj_btn_width, obj_btn_width);
	_parenv:AddChild(_this);
	_this.background="Texture/kidui/left/btn_bgsky.png";
	_this.text=L"l_sky";
	_this.tooltip=L"l_sky_tips";
	_this.onclick=[[;if(kids_db.User.CheckRight("Sky")) then CommonCtrl.CKidMiddleContainer.SwitchUI("sky") end]]
	
	CKidLeftContainer.SetButtonStyle(_this);
	
	left, top = 2, 54;
	_this=ParaUI.CreateUIObject("button","kidui_l_water_btn","_lt",left, top,obj_btn_width,obj_btn_width);
	_parenv:AddChild(_this);
	_this.background="Texture/kidui/left/btn_bgwater.png";
	_this.text=L"l_ocean";
	_this.tooltip=L"l_ocean_tips"
	_this.onclick=[[;if(kids_db.User.CheckRight("Ocean")) then CommonCtrl.CKidMiddleContainer.SwitchUI("water") end]]
	CKidLeftContainer.SetButtonStyle(_this);
	
	left,top = 26, 92;
	_this=ParaUI.CreateUIObject("button","kidui_l_terrain_btn","_lt",left, top,obj_btn_width,obj_btn_width);
	_parenv:AddChild(_this);
	_this.background="Texture/kidui/left/btn_bgterrain.png";
	_this.text=L"l_terrain";
	_this.tooltip=L"l_terrain_tips";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.SwitchUI(\"terrain\");";
	CKidLeftContainer.SetButtonStyle(_this);

	left,top = 66,91;	
	_this=ParaUI.CreateUIObject("button","kidui_l_filter_btn","_lb",91, -151,obj_btn_width,obj_btn_width);
	_this:AttachToRoot();
	local fatt = CKidLeftContainer.GetFilter();
	_this.background = fatt.background;
	_this.text=fatt.text;
	_this.tooltip = fatt.tooltip;
	_this.onclick=";CommonCtrl.CKidLeftContainer.OnFilterChange();";
	_this.visible = false;
	CKidLeftContainer.SetButtonStyle(_this);
	
-- 3D/2D canvas	
	top = 10;
	_this=ParaUI.CreateUIObject("3dcanvas","kidui_l_objectdisplay","_lb",17,-117,100,100);
	_this:AttachToRoot();
	_this.canvasindex=0;--test	
	_this.background="Texture/kidui/left/display_bg.png";
	_texture=_this:GetTexture("background");
	_texture.color="255 255 255";
	-- test: remove high light.
	--_this.highlightstyle="4outsideArrow";
	_this.visible=false;
	--local canvas = ParaScene.Get3DCanvas(0);
	--canvas:SetMaskTexture("Texture/kidui/left/display_bg.png");
	
--object
	_parobj=ParaUI.CreateUIObject("container",self.contName.."obj","_lb",128,-128,68,128);
	_parobj:AttachToRoot();
	_parobj.background="Texture/whitedot.png;0 0 0 0";
	_parobj.visible=false;
	
	left, top = 2,9;
	_this=ParaUI.CreateUIObject("button","kidui_l_switchto_btn","_lt",left, top,obj_btn_width,obj_btn_width);
	_parobj:AddChild(_this);
	_this.background="Texture/kidui/left/btn_bgswitchto.png";
	_this.text=L"l_Impersonate";
	_this.tooltip=L"l_Impersonate_tips";
	_this.onclick=";CommonCtrl.CKidLeftContainer.OnSwitchToObject();";
	CKidLeftContainer.SetButtonStyle(_this);
	
	left, top = 2, 55;
	_this=ParaUI.CreateUIObject("button","kidui_l_modify_btn","_lt",left, top,obj_btn_width,obj_btn_width);
	_parobj:AddChild(_this);
	_this.background="Texture/kidui/left/btn_bgmodify.png";
	_this.text=L"l_modify";
	_this.tooltip=L"l_modify_tips";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.SwitchUI(\"modify\");";
	_this.onclick=";CommonCtrl.CKidLeftContainer.OnShowObjModify();";
	CKidLeftContainer.SetButtonStyle(_this);
	
	left,top = 25, 92;
	_this=ParaUI.CreateUIObject("button","kidui_l_property_btn","_lt",left, top,obj_btn_width,obj_btn_width);
	_parobj:AddChild(_this);
	_this.background="Texture/kidui/left/btn_bgproperty.png";
	_this.text=L"l_property";
	_this.tooltip=L"l_property_tips";
	_this.onclick=";CommonCtrl.CKidLeftContainer.OnShowObjProperty();";
	CKidLeftContainer.SetButtonStyle(_this);
	
	
	_this=ParaUI.CreateUIObject("button","kidui_l_delete_btn","_lb",91, -150,obj_btn_width,obj_btn_width);
	_this:AttachToRoot();
	_this.background="Texture/kidui/left/btn_bgdelete.png";
	_this.text=L"l_delete";
	_this.tooltip=L"l_delete_tips";
	_this.onclick=";CommonCtrl.CKidLeftContainer.OnClickDeleteObject();";
	_this.visible = false;
	CKidLeftContainer.SetButtonStyle(_this);
	
	--[[
--parent container
	_parent=ParaUI.CreateUIObject("container",self.contName,self.alignment,self.left,self.top,self.width,self.height);
	_parent:AttachToRoot();
	_parent.background="Texture/whitedot.png;0 0 0 0";	

	]]
	CKidLeftContainer.Update();
end

-- get the current filter name used during mouse picking. 
function CKidLeftContainer.GetFilterName()
	return CKidLeftContainer.filters[CKidLeftContainer.filterindex+1].name;
end

-- return the text to be displayed on the filter button.
function CKidLeftContainer.GetFilter()
	return CKidLeftContainer.filters[CKidLeftContainer.filterindex+1];
end 

function CKidLeftContainer.OnClickDeleteObject()
	if(not kids_db.User.CheckRight("Delete")) then return end
	local obj = ObjEditor.GetCurrentObj();
	if(obj~=nil and obj:IsValid()==true) then
		if(obj:IsCharacter()) then
			if(mouse_button == "left") then
				-- only ask confirmation if user click left button
				_guihelper.MessageBox(L"Are you sure you want to delete the selected character?", function ()
					CommonCtrl.CKidLeftContainer.OnDeleteObject();
				end);
				return;
			end
		end	
	end	
	CKidLeftContainer.OnDeleteObject(obj);
end

-- delete the currently selected object or character. 
-- obj: if nil, the current object will be deleted
function CKidLeftContainer.OnDeleteObject(obj)
	-- TODO: build an UNDO stack. 
	if(not obj)then
		obj = ObjEditor.GetCurrentObj();
	end	
	if(obj~=nil and obj:IsValid()==true) then
		local nServerState = ParaWorld.GetServerState();
		if(nServerState == 0 or obj:IsCharacter()==true) then
			-- this is a standalone computer or a character. 
			ObjEditor.DelObject(obj);
		elseif(nServerState == 1) then
			-- this is a server. 
			if(obj:IsOPC()==false) then
				server.BroadcastObjectDelete(obj);
			else
				-- TODO: kick out the given user.
			end	
		elseif(nServerState == 2) then
			-- this is a client. 
			if(obj:IsOPC()==false) then
				client.RequestObjectDelete(obj);
			else
				_guihelper.MessageBox(L"You can not delete other player");		
			end	
		end	
		CommonCtrl.CKidMiddleContainer.SwitchUI("text");
		CommonCtrl.CKidLeftContainer.SwitchUI("environment");
	end
end

-- Take control of the currently selected character.
function CKidLeftContainer.OnSwitchToObject()
	local player = ObjEditor.GetCurrentObj();
	if((player:IsGlobal() ==true) and (player:IsCharacter() == true) and (player:IsOPC()==false)) then
		ParaCamera.FollowObject(player);
	else
		_guihelper.MessageBox(L"You can not take control of this character");
	end
end

-- filter changes.
function CKidLeftContainer.OnFilterChange()
	-- cycle through the three filters.
	CKidLeftContainer.filterindex = math.mod(CKidLeftContainer.filterindex+1, 3);

	-- update the UI.	
	local _this=ParaUI.GetUIObject("kidui_l_filter_btn");
	
	local fatt = CKidLeftContainer.GetFilter();
	_this.background = fatt.background;
	_this.text=fatt.text;
	_this.tooltip = fatt.tooltip;
		
	if(CKidLeftContainer.GetFilterName() == "light") then
		ParaScene.GetAttributeObject():SetField("ShowLights", true);
	else
		ParaScene.GetAttributeObject():SetField("ShowLights", false);
	end
end

-- called whenever the property is changed. 
function CKidLeftContainer.OnShowObjProperty()
	-- TODO: remove the property control in release mode. 
	if(ParaEngine.IsEditing()==true or ParaEngine.IsDebugging()==true) then
		ObjEditor.ShowObjProperty(nil, true);	
	end
	CommonCtrl.CKidMiddleContainer.SwitchUI("property");
end


-- NOTE: WangTian 2007.7.17
-- Show object modify menu, if object is character change to ccs menu
function CKidLeftContainer.OnShowObjModify()
	local obj = ObjEditor.GetCurrentObj();
		if(obj:IsCharacter()==true and KidsMovie_FunctionSet_CCS == true) then
		--if(obj:IsCharacter()==true and obj:ToCharacter():IsCustomModel()==true) then
			CommonCtrl.CKidMiddleContainer.SwitchUI("CCSMenu");
		else
			CommonCtrl.CKidMiddleContainer.SwitchUI("modify");
		end
end

-- 
-- @param button is a ParaUIObject
function CKidLeftContainer.SetButtonStyle(button)
	local texture;
	button:SetCurrentState("highlight");
	texture=button:GetTexture("background");
	texture.color="200 200 200";
	button:SetCurrentState("pressed");
	texture=button:GetTexture("background");
	texture.color="160 160 160";
	button:SetCurrentState("normal");
	texture=button:GetTexture("background");
	texture.color="255 255 255";
end