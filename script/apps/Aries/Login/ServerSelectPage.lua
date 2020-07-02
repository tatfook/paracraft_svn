--[[
Title: Aries Server Select Page
Author(s): LiXizhi
Date: 2009/7/31
Desc:  script/apps/Aries/Login/ServerSelectPage.html?page=0
Display recommended world server list. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/ServerSelectPage.lua");
-------------------------------------------------------
]]
local ServerSelectPage = {};
commonlib.setfield("MyCompany.Aries.ServerSelectPage", ServerSelectPage)

-- TODO: grab this table during start up. and then sort according to design rules. 
ServerSelectPage.dsWorlds = {
	-- where gs_nid is the game server nid, and ws_id is the world server id, worldpath can be nil if default one is used.  
	{ws_id="1", gs_nid="1001", id="001.", text="泡泡广场", people=3, type="last", percentage=0.7},
	{ws_id="2", gs_nid="1001", id="002.", text="生命之泉", people=1, type="friend", percentage=0.4},
	{ws_id="3", gs_nid="1001", id="003.", text="龙源密境", people=1, type="", percentage=0.1},
	{ws_id="4", gs_nid="1001", id="004.", text="魔法密林", people=1, type="", percentage=0.7},
	{ws_id="5", gs_nid="1001", id="005.", text="火焰山洞", people=1, type="", percentage=1},
	{ws_id="6", gs_nid="1001", id="006.", text="龙龙乐园", people=1, type="", percentage=0.4},
	--{ws_id="7", gs_nid="1001", id="007.", text="通过测试", people=1, type="", percentage=0.1},
	--{ws_id="8", gs_nid="1001", id="008.", text="8月版存档", people=1, type="", percentage=0.1},
	--{ws_id="9", gs_nid="1001", id="009.", text="9月版存档", people=1, type="", percentage=0.1},
	--{ws_id="10", gs_nid="1001", id="010.", text="10月版存档", people=1, type="", percentage=0.4},
	--{ws_id="11", gs_nid="1001", id="011.", text="11月版存档", people=1, type="", percentage=0.4},
	--{ws_id="12", gs_nid="1001", id="012.", text="12月版存档", people=1, type="", percentage=0.7},
	--{ws_id="13", gs_nid="1001", id="013.", text="1月版存档", people=1, type="", percentage=0.6},
	--{ws_id="14", gs_nid="1001", id="014.", text="2月版存档", people=1, type="", percentage=0.8},
	--{ws_id="15", gs_nid="1001", id="015.", text="M4版存档", people=1, type="", percentage=0.4},
	--{ws_id="16", gs_nid="1001", id="016.", text="M5版存档", people=1, type="", percentage=0.6},
}
-- The data source function. 
function ServerSelectPage.DS_Func(index, pageCtrl)
	if(index == nil) then
		return #(ServerSelectPage.dsWorlds);
	else
		return ServerSelectPage.dsWorlds[index];
	end
end

---------------------------------
-- page event handlers
---------------------------------
-- singleton page
local page;
local MainLogin = commonlib.gettable("MyCompany.Aries.MainLogin");

-- init
function ServerSelectPage.OnInit()
	page = document:GetPageCtrl();
	--local self = document:GetPageCtrl();
	--local name = self:GetRequestParam("name")
	--self:SetNodeValue("fileName", name);
	
end

-- @param world_id_or_name: it can be string of ws_id or text
-- @return the the world server table like {ws_id="16", id="016.", text="M5版测试", people=3, type=""}
function ServerSelectPage.SearchWorldServer(world_id_or_name)
	world_id_or_name = string.gsub(world_id_or_name, "^0*", "")
	world_id_or_name = string.gsub(world_id_or_name, "%.$", "")
	local index, world
	for index, world in ipairs(ServerSelectPage.dsWorlds) do 
		if(world.ws_id == world_id_or_name or world.text==world_id_or_name) then
			return world;
		end
	end
end

-- user selected a given world.
function ServerSelectPage.OnSelectWorld(ws_id)
	local world = ServerSelectPage.SearchWorldServer(ws_id)
	if(world) then
		ServerSelectPage.SwitchWorldServer(world);
	else
		_guihelper.MessageBox("服务器不存在, 请尝试其他服务器")
	end
end

-- on click event handler. 
function ServerSelectPage.OnClickSelectWorld()
	local world_name = page:GetValue("world_name");
	if(type(world_name) ~= "string" or world_name=="") then
		_guihelper.MessageBox("请输入服务器ID或名称")
	else
		local world = ServerSelectPage.SearchWorldServer(world_name)
		if(world) then
			ServerSelectPage.SwitchWorldServer(world);
		else
			_guihelper.MessageBox("您输入的服务器不存在, 请输入服务器ID或名称")
		end
	end
end

-- enter the world server
function ServerSelectPage.SwitchWorldServer(world)
	if(not world) then return end
	if(world.type == "full" or world.percentage>=0.99) then
		_guihelper.MessageBox("这台服务器太拥挤了, 暂时无法进入, 试试没有满员的服务器吧!")
	else
		commonlib.applog("user selected"..commonlib.serialize(world));
		
		page:CloseWindow();
		MainLogin:next_step({
				IsWorldServerSelected = true, 
				IsLoadMainWorldRequested=true, 
				load_world_params = {
					worldpath = world.worldpath,
					gs_nid = world.gs_nid, 
					ws_id = world.ws_id,
				},
			});
	end	
end