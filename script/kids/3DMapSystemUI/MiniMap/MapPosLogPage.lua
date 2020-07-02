--[[
Title: MapPosLogPage.html
Author(s): LiXizhi
Date: 2008/9/2
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/MapPosLogPage.lua");
Map3DSystem.App.MiniMap.MapPosLogPage.Show()
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/MiniMapWnd.lua");

-- create class
local MapPosLogPage = {};
commonlib.setfield("Map3DSystem.App.MiniMap.MapPosLogPage", MapPosLogPage);

-- on init show the current avatar in pe:avatar
function MapPosLogPage.OnInit()
	local self = document:GetPageCtrl();
	local x, y, z = ParaScene.GetPlayer():GetPosition();
	self:SetNodeValue("pos_x", string.format("%d", x));
	self:SetNodeValue("pos_y", string.format("%d", z));
end

-- click to goto a position
function MapPosLogPage.OnClickGotoPos(name, values) 
	MapPosLogPage.GotoPos(values["pos_x"], values["pos_y"])
end

-- goto a position
function MapPosLogPage.GotoPos(x, y)
	x = tonumber(x)
	y = tonumber(y)
	if(x and y) then
		Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x=x, z=y});
	end
end

-- TODO: create a new pos
function MapPosLogPage.OnClickCreatePos(name, values)
	-- values.pos_x, values.pos_y, values.pos_x, values.pos_name
	local x, y, z = ParaScene.GetPlayer():GetPosition();
	_guihelper.MessageBox(string.format("此功能暂时不可用， 请记在纸上吧: 当前位置\n x=%d, y=%d", x, z));
end