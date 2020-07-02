--[[
Title: Esc popup window UI for 3D Map system
Author(s): WangTian
Date: 2007/8/30
Desc: Show the Esc popup window UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/EscPopup.lua");
Map3DSystem.UI.EscPopup.ToggleEscPopupUI();
------------------------------------------------------------
]]

NPL.activate("(gl)script/kids/ui/Load3DMapSystemUI.lua");
NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

function Map3DSystem.UI.EscPopup.ToggleEscPopupUI()

	local _cont = ParaUI.GetUIObject("Map3D_EscPopup");
	
	if(_cont:IsValid()==false) then
		local _width, _height = 370,150;
		local _this, _parent;
		_this=ParaUI.CreateUIObject("container","Map3D_EscPopup", "_fi",0,0,0,0);
		_this:AttachToRoot();
		_this.background="";
		_parent = _this;
		
		_this=ParaUI.CreateUIObject("container","Map3D_EscPopup_BG", "_ct",-_width/2,-_height/2-50,_width,_height);
		_parent:AddChild(_this);
		_this.background="Texture/msg_box.png";
		_this:SetTopLevel(true);
		_parent = _this;
		
		_this=ParaUI.CreateUIObject("text","Map3D_EscPopup_Text", "_lt",15,10,_width-30,20);
		_this.text = L"Are you sure you wanna quit to main menu?";
		_this.autosize=true;
		_this:DoAutoSize();
		_parent:InvalidateRect();
		_parent:AddChild(_this);
		
		_this=ParaUI.CreateUIObject("button","Map3D_EscPopup_Btn_OK", "_lt",_width-150,_height-25,64,16);
		_this.text = L"OK";
		_this.onclick = ";Map3DSystem.UI.EscPopup.OnClickOK();";
		_parent:AddChild(_this);
		
		_this=ParaUI.CreateUIObject("button","Map3D_EscPopup_Btn_Cancel", "_lt",_width-75,_height-25,64,16);
		_this.text = L"Cancel";
		_this.onclick = ";Map3DSystem.UI.EscPopup.OnClickCancel();";
		_parent:AddChild(_this);
		
	end
	_cont = ParaUI.GetUIObject("Map3D_EscPopup");
	
	if(Map3DSystem.UI.EscPopup.IsShowEscPopupUI == false) then
		_cont.visible = true;
		Map3DSystem.UI.EscPopup.IsShowEscPopupUI = true;
	elseif(Map3DSystem.UI.EscPopup.IsShowEscPopupUI == true) then
		_cont.visible = false;
		Map3DSystem.UI.EscPopup.IsShowEscPopupUI = false;
	else -- Map3DSystem.UI.EscPopup.IsShowEscPopupUI == nil
		_cont.visible = true;
		Map3DSystem.UI.EscPopup.IsShowEscPopupUI = true;
	end
	
end

function Map3DSystem.UI.EscPopup.OnClickOK()
	Map3DSystem.UI.EscPopup.ResetScene();
	--Map3DSystem.UI.SwitchToState("Startup");
	
	NPL.activate("(gl)script/kids/ui/Load3DMapSystemUI.lua", "TargetState = \"Startup\"");
end

function Map3DSystem.UI.EscPopup.OnClickCancel()
	local _cont = ParaUI.GetUIObject("Map3D_EscPopup");
	if(_cont:IsValid() == true) then
		_cont.visible = false;
	end
	Map3DSystem.UI.EscPopup.IsShowEscPopupUI = false;
end

function Map3DSystem.UI.EscPopup.ResetScene()
	ParaScene.Reset();
	ParaUI.ResetUI();
	ParaAsset.GarbageCollect();
	if(KidsUI.StartupTexSeq.asset~=nil)then
		KidsUI.StartupTexSeq.asset:UnloadAsset();
	end
	ParaGlobal.SetGameStatus("disable");
	if(_AI~=nil and _AI.temp_memory~=nil) then
		_AI.temp_memory = {}
	end
	KidsUI.ResetState();
	collectgarbage();
	log("scene has been reset\n");
end