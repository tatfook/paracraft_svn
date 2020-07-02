--[[
Title: Load world server
Author(s): LiXizhi
Date: 2007/7/31
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/gameserver_mainUI.lua");
GameServer.ShowMainUI()
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("IDE");
NPL.load("(gl)script/network/ClientServerIncludes.lua");
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/gui_helper.lua");

-- network: Kids UI library 
if(not GameServer) then GameServer={}; end

-- load the personal world associated with the user name and make it a game server. 
function GameServer.ShowMainUI()
	local _this, _parent;
	
	_this=ParaUI.CreateUIObject("container","gameserverMainUI_cont", "_lt",0,0,640,480);
	_this.background="Texture/whitedot.png;0 0 0 0";
	_this:AttachToRoot();
	_parent=_this;
	
	_this=ParaUI.CreateUIObject("button","s", "_lt",0, 0, 100, 25);
	_this.onclick = ";ParaEngine.ForceRender();"
	_this.text = "Force Render";
	_parent:AddChild(_this);
	
	_this=ParaUI.CreateUIObject("text","s", "_lt",10, 30, 400, 20);
	_parent:AddChild(_this);
	_this.text = "Game Server Mode\n Click to render";
end

