--[[
Title: Monster Hand Book 
Author(s): LiPeng
Date: 2012/6/27
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Pet/MonsterHandBook/MonsterHandBook.lua");
local MonsterHandBook = commonlib.gettable("MyCompany.Aries.Pet.MonsterHandBook");
MonsterHandBook.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/HaqiShop/ItemGuides.lua");
local ItemGuides = commonlib.gettable("MyCompany.Aries.ItemGuides");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");

local MonsterHandBook = commonlib.gettable("MyCompany.Aries.Pet.MonsterHandBook");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;

function MonsterHandBook.init()
	if(MonsterHandBook.is_inited) then
		return;
	end
	MonsterHandBook.is_inited = true;

	MonsterHandBook.monsterListTable = {};
    local monstXML = ParaXML.LuaXML_ParseFile("config/Aries/Others/monsterinformations.xml");
    local worldnode;
	local allmonsternumber = 0; -- 所有世界怪物数量

    for worldnode in commonlib.XPath.eachNode(monstXML,"/worlds/world") do
        local monsternode;
		local worldname = worldnode.attr.name;
		if(not MonsterHandBook.monsterListTable[worldname]) then
			MonsterHandBook.monsterListTable[worldname] = {};
		end
		local totalNum = 0; -- 当前世界怪物数量
        for monsternode in commonlib.XPath.eachNode(worldnode,"/monster") do
            if(monsternode.attr) then
				local attr = monsternode.attr;
				local path = attr.path;
				local gsid = tonumber(attr.gsid);
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
				if(gsItem) then
					attr.displayname = gsItem.template.name;
					attr.description = gsItem.template.description;
				end
				attr.school = ItemGuides.monsterInfo[path]["school"];
				attr.hp = ItemGuides.monsterInfo[path]["hp"];
				attr.attack = ItemGuides.monsterInfo[path]["attack"];
				attr.asset = ItemGuides.monsterInfo[path]["asset"];
				if(attr.cards) then
					local cardlist = attr.cards;
					attr.cards = {};
					local cardGSID;
					for cardGSID in string.gmatch(cardlist,"%d+") do
						table.insert(attr.cards,tonumber(cardGSID));
					end
				elseif(ItemGuides.monsterInfo[path]["cards"]) then
					attr.cards = ItemGuides.monsterInfo[path]["cards"];
				else
					attr.cards = {};
				end
				if(attr.position and attr.place) then
				else
					local k,v;
					for k,v in ipairs(QuestHelp.goal_list) do
						if(attr.path == v.path) then
								attr.position = v.position;
								attr.place = v.place;
						end
					end
				end
				if(attr.tooltip) then
					attr.tooltip = "page://script/apps/Aries/Pet/MonsterHandBook/MonsterTooltip.html?tooltip="..attr.tooltip;
					--attr.tooltip = "page://script/apps/Aries/Pet/MonsterHandBook/MonsterTooltip.html";
				else
					attr.tooltip = "page://script/apps/Aries/Pet/MonsterHandBook/MonsterTooltip.html"
				end
				totalNum = totalNum + 1;
				table.insert(MonsterHandBook.monsterListTable[worldname],attr);
            end
        end
		MonsterHandBook.monsterListTable[worldname].totalnumber = totalNum;
		allmonsternumber = allmonsternumber + totalNum;
    end
	MonsterHandBook.monsterListTable.totalnumber = allmonsternumber;
end

function MonsterHandBook.HasGotten()
	local worldname,monsterlist;
	local allkillnumber = 0; --所有世界击杀的怪物数量
	for worldname,monsterlist in pairs(MonsterHandBook.monsterListTable) do
		local i,node;
		local killedNum = 0; --当前世界击杀的怪物数量
		if(type(monsterlist) == "table") then
			for i,node in ipairs(monsterlist) do
				local gsid = tonumber(node.gsid);
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
				if(gsItem) then 
					node.haskill = hasGSItem(gsid) == true;
					if(node.haskill) then
						killedNum = killedNum + 1;
					end
				end;
			end
			monsterlist.killednumber = killedNum;
		end
		allkillnumber = allkillnumber + killedNum;
	end
	MonsterHandBook.monsterListTable.killednumber = allkillnumber;
end

function MonsterHandBook.ShowPage()
	local params = {
		url = "script/apps/Aries/Pet/MonsterHandBook/MonsterHandBook.html",
		name = "MonsterHandBook.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		directPosition = true,
			align = "_ct",
			x = -800/2,
			y = -500/2,
			width = 800,
			height = 500,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
end

function MonsterHandBook.OnInit()
	MonsterHandBook.init();
	MonsterHandBook.HasGotten();
	--echo(MonsterHandBook.monsterListTable);
	MonsterHandBook.curworldname = MonsterHandBook.curworldname or "61HaqiTown";
	MonsterHandBook.curworldList = MonsterHandBook.monsterListTable[MonsterHandBook.curworldname];
	MonsterHandBook.curitem = MonsterHandBook.curitem or MonsterHandBook.monsterListTable[MonsterHandBook.curworldname][1];
end

-- @worldname   目标世界name，如果为nil，则默认怪物在当前世界
-- @displayname 怪物名称，如果怪物在当前世界，且该参数不为nil，则按当前世界法阵列表求出跳转position来进行跳转。否则按照输入的position来跳转
-- @position    跳转的位置，如果displayname为nil或者worldname不是当前世界，按照输入的positon跳转，否则根据系统计算出来positon跳转
function MonsterHandBook.GoToMonsterPosition(worldname,displayname,position)
	if(worldname == "DarkForestIsland" and (not hasGSItem(20904))) then
		_guihelper.MessageBox("至少拥有1件S4装备，然后前往【沙漠岛】，找法斯特船长开启【沙漠岛】地图，才能前去冒险");
		return;
	end

	NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
	local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
	NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
    local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
	NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
    local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
	local BasicArena = commonlib.gettable("MyCompany.Aries.Quest.NPCs.BasicArena");
	local Player = commonlib.gettable("MyCompany.Aries.Player");	

	local pos = {};
	pos[4] = 0;
	local camPos = {};
	camPos[1] = 15;
	camPos[2] = 0.27;
	camPos[3] = -1.57;
	--local monsternode = MonsterHandBook.curitem;
	local current_world = WorldManager:GetCurrentWorld();
	if(not worldname) then
		worldname = current_world.name;
	end
	local goalWorldInfo = WorldManager:GetWorldInfo(worldname);
	if(position) then
		local _,_,x,y,z = string.find(position,"([+-]?%d+%.?%d+),([+-]?%d+%.?%d+),([+-]?%d+%.?%d+)");
		pos[1] = tonumber(x);
		pos[2] = tonumber(y);
		pos[3] = tonumber(z);
	else
		local born_pos = goalWorldInfo.born_pos;
		if(born_pos.x and born_pos.y and born_pos.z) then
			pos[1] = tonumber(born_pos.x);
			pos[2] = tonumber(born_pos.y);
			pos[3] = tonumber(born_pos.z);
		end
	end

	if(current_world.name == worldname and displayname) then
		local n_x,n_y,n_z = MsgHandler.Get_Highest_HP_mob_position(displayname);
		if(n_x and n_y and n_z)then
			x = n_x;
			y = n_y;
			z = n_z;
			NPL.load("(gl)script/ide/math/vector.lua");
			local vector3d = commonlib.gettable("mathlib.vector3d");
			local v = vector3d:new(x-pos[1],0,z-pos[3])
			local angle = vector3d.unit_x:angleAbsolute(v);
			facing = angle;
			pos[4] = facing;
			if (Player.GetLevel()<100) then
				-- tricky: when player level is smaller than 100, we will teleport to mob position which is very close to the mob so that the auto tip will appear.
				local vOrigin = vector3d:new(x,0,z);
				v:normalize();
				local radius = BasicArena.GetEnterCombatRadius();
				v:MulByFloat(radius + 3);
				local vJumpPos = vOrigin - v;
				pos[1] = vJumpPos[1];
				pos[2] = y;
				pos[3] = vJumpPos[3];
			end
			if(System.options.version == "kids") then
				QuestHelp.ActiveAreaTip(true,x,y,z);
			end
			
			camPos[3] = facing;
		end
	end
	WorldManager:GotoWorldPosition(worldname,pos,camPos, nil,function () end)
end