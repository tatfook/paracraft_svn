--[[
Title: 
Author(s): Spring
Date: 2011/9/1
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/FamilyServer/FamilyServerSelect.teen.lua");

------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/ProfileManager.lua");
NPL.load("(gl)script/apps/Aries/Friends/Main.lua");

local FamilyServerSelect = commonlib.gettable("MyCompany.Aries.FamilyServer.FamilyServerSelect");
local level,rookieYN;
rookieYN=false;

FamilyServerSelect.LastLoginWorld = {};
FamilyServerSelect.dsRookieWorlds = {};
FamilyServerSelect.dsAllWorlds = {};
FamilyServerSelect.dsAllWorlds_all={};
FamilyServerSelect.world_canlogin = {};  
FamilyServerSelect.world_guest ={};

FamilyServerSelect.zoneid_current=nil;
FamilyServerSelect.IsAllworld = false;
FamilyServerSelect.SwitchSvr=0;

local bigzone={
	--{name="电信区",isnew=true,zoneid=0,recommend=true,},
	--{name="联通区",isnew=true,zoneid=1000,recommend=false,},
};

local zonename_recomm_default = "电信";
local IsOnInit = false;
local IsInitBigZone = false;

-- 针对版署检查用
if (System.options.isPubchk) then
	bigzone={
		{name="联通X区",isnew=true,zoneid=1001,recommend=true,},
	};
end

function FamilyServerSelect.InitBigZone()
	if (IsInitBigZone) then
		return
	end
	IsInitBigZone = true;

	local config_file="config/Aries/others/bigzone.teen.xml";
	
	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading bigzone config file: %s\n", config_file);
		return;
	end
		
	local xmlnode = "/bigzone/locale";
	
	local _locale = nil;	
	for _locale in commonlib.XPath.eachNode(xmlRoot, xmlnode) do	
		local _key = _locale.attr.key;
		if (_key) then
			if (System.options.locale == _key) then
				local _zone, i = nil, 1;
				bigzone={};
				for _zone in commonlib.XPath.eachNode(_locale, "/zone") do
					local _subzone = {};
					_subzone.name = _zone.attr.name;
					_subzone.isnew = _zone.attr.isnew;
					_subzone.zoneid = tonumber(_zone.attr.zoneid or "0");
					_subzone.isnew = _zone.attr.recommend;
					_subzone.ipname = _zone.attr.ipname;
					table.insert(bigzone,_subzone);
					if (i==1) then
						zonename_recomm_default = _subzone.ipname;
					end
					i = i + 1;
				end
			end
		end
	end
end

function FamilyServerSelect.InitWorldZones()
	if(not FamilyServerSelect.zone_inited) then
		FamilyServerSelect.zone_inited = true;
		NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
		local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
		local regionconfig = ExternalUserModule:GetConfig();
		local world_zones = regionconfig.world_zones;
		local worldzone, worldtype;
		for worldzone, worldtype in pairs(world_zones) do 
			worldzone = tonumber(worldzone);
			if (worldtype == "u")then
				table.insert(FamilyServerSelect.world_canlogin,worldzone);
			elseif (worldtype == "g") then
				table.insert(FamilyServerSelect.world_guest,worldzone);
			end
		end
		--commonlib.echo("=============world_canlogin: ")
		--commonlib.echo(world_zones)	
		--commonlib.echo(FamilyServerSelect.world_canlogin)	
	end

end

function FamilyServerSelect.GetLastLoginBigZone()
	local world = MyCompany.Aries.app:ReadConfig(System.App.profiles.ProfileManager.GetNID().."LastLoggedinWorldServer", {});	
	if (next(world)~=nil) then
		return world.zoneid
	else
		return nil;
	end
end

function FamilyServerSelect.GetCurrentBigZone()
	FamilyServerSelect.InitBigZone();
	if (FamilyServerSelect.zoneid_current) then
		return FamilyServerSelect.zoneid_current;
	end
end

function FamilyServerSelect.GetRecommendBigZone()
	FamilyServerSelect.InitBigZone();
	local z_id = FamilyServerSelect.GetCurrentBigZone();
	if (z_id) then
		return z_id;
	end
	
	local whereipfrom = System.options.force_ipfrom or System.options.whereipfrom;

	local zonename=if_else(whereipfrom~="联通", zonename_recomm_default, "联通");
	local i;
	local zid=0;
	for i = 1, #(bigzone) do
		if (string.match(bigzone[i].name,zonename))then
			zid=1;	
			return bigzone[i].zoneid
		end
	end
	if (zid==0) then
		return bigzone[1].zoneid
	end
end

function FamilyServerSelect.IsRecommendBigZone(zoneid)
	local z_id = FamilyServerSelect.GetRecommendBigZone()
	if(not z_id or not zoneid) then
		return true;
	elseif(z_id == zoneid) then
		return true;
	elseif( type(z_id) == "number" and type(zoneid) =="number" and (z_id <1000 and  zoneid<1000) or (z_id >=1000 and  zoneid>=1000) ) then
		return true
	else
		return false
	end
end


function FamilyServerSelect.IsMyWorldZone(zoneid)
	local z_id=tonumber(zoneid);

	FamilyServerSelect.InitWorldZones();
	local index, worldzone;
	for index, worldzone in ipairs(FamilyServerSelect.world_canlogin) do
		local w_zid=tonumber(FamilyServerSelect.world_canlogin[index]);
		if (w_zid==z_id) then
			return true
		end
	end
	return false
end

function FamilyServerSelect.DS_Func(index, pageCtrl)
	if(index == nil) then
		if(FamilyServerSelect.dsWorlds)then
			return #(FamilyServerSelect.dsWorlds);
		end	
	else
		return FamilyServerSelect.dsWorlds[index];
	end
end

-- The data source function. 
function FamilyServerSelect.DS_AllWorld_Func(index, pageCtrl)
	if(index == nil) then
		if(FamilyServerSelect.dsAllWorlds)then
			return #(FamilyServerSelect.dsAllWorlds);
		end	
	else
		return FamilyServerSelect.dsAllWorlds[index];
	end
end


-- The data source function. 
function FamilyServerSelect.DS_Rookie_Func(index, pageCtrl)
	if(index == nil) then		
		if (FamilyServerSelect.dsRookieWorlds) then
			return #(FamilyServerSelect.dsRookieWorlds);
		end	
	else		
		return FamilyServerSelect.dsRookieWorlds[index];
	end
end

function FamilyServerSelect.DS_Func_BigZone(index)
	if(index == nil) then
		if(bigzone)then
			return #(bigzone);
		end	
	else
		return bigzone[index];
	end
end
---------------------------------
-- page event handlers
---------------------------------
-- singleton page
local page;
local MainLogin = commonlib.gettable("MyCompany.Aries.MainLogin");

function FamilyServerSelect.AllowWebUpdate()
	IsOnInit = false;
end

function FamilyServerSelect.SwitchBigZone(zoneid,page)
	IsOnInit = false;
	FamilyServerSelect.zoneid_current=zoneid;
	FamilyServerSelect.OnInit(page)
end

-- init
function FamilyServerSelect.OnInit(PageCtrl)

	--FamilyServerSelect.page = document:GetPageCtrl();
	--page = document:GetPageCtrl();
	FamilyServerSelect.page = PageCtrl;
	page = PageCtrl;
	if (FamilyServerSelect.SwitchSvr == 1) then
		FamilyServerSelect.SwitchSvr = 2;
		IsOnInit = false;
	end
	if(IsOnInit) then
		do return end;
	end
	--commonlib.echo("===============FamilyServerSelect.OnInit")
	--commonlib.echo(IsOnInit)
	--commonlib.echo(FamilyServerSelect.SwitchSvr)
	--commonlib.echo("+++++++++++++++++++++++++++")
	IsOnInit = true;

	FamilyServerSelect.InitBigZone();
	local iShow=0;
	local IsShow ={};	
	
	FamilyServerSelect.dsRookieWorlds = {};

	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		level = bean.combatlel or 1;
	else
		level = 1;
	end
	--if (level <10) then
		--rookieYN=true;
	--else
		--rookieYN=false;
	--end

	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
	local region_id = ExternalUserModule:GetRegionID();

	if (rookieYN or region_id~=0) then
	-- retrieve all servers 新用户取全部服务器
		FamilyServerSelect.OnViewAllWorld(0, 1000);
	else
	-- 非新用户取推荐服务器
		local id,zoneid;
		local world = MyCompany.Aries.app:ReadConfig(System.App.profiles.ProfileManager.GetNID().."LastLoggedinWorldServer", {});
		
		-- mark last loggedin world server with type "last"
		local ws_id_last = world.ws_id;
		local gs_nid_last = world.gs_nid;

		paraworld.WorldServers.GetRecommend({}, "FamilyServerSelect", function (msg)
			--LOG.std(nil, "system", "selectpage", "msg.items:%s", commonlib.serialize_compact(msg.items));
			iShow = iShow + 1;
			--commonlib.log("in get recommend,iShow=%s\n", iShow);
			FamilyServerSelect.dsWorlds = {};
			local index,world;
			for index, world in ipairs(msg.items) do 
				local _, _, ws_id,gs_nid = string.find(msg.items[index].id,"%((%w+)%)(%w+)");
				id = string.format("(%s)%s",ws_id,gs_nid);
				zoneid = tonumber(msg.items[index].zoning);

				local _id = string.format("%03d.",msg.items[index].vid);
				local _seqno = msg.items[index].vid;
				local _percentage = (100 * msg.items[index].cur) / msg.items[index].max;
				local _people = msg.items[index].level;

				local rookie_id = string.find(msg.items[index].name,"(.*)%(.*%)");

				if (ws_id == ws_id_last and gs_nid == gs_nid_last) then					
					local _text="";
					if (rookie_id) then
						_text = string.match(msg.items[index].name,"(.*)%(.*%)");
					else
						_text = msg.items[index].name;
					end	
					FamilyServerSelect.LastLoginWorld = {id=_id, seqno=_seqno, ws_id=ws_id, gs_nid=gs_nid, zoneid=zoneid, text=_text, percentage=_percentage, people=_people, type="last", };
				end

				if(IsShow[id] == nil and FamilyServerSelect.IsMyWorldZone(zoneid) and (FamilyServerSelect.IsRecommendBigZone(zoneid))) then
					FamilyServerSelect.dsWorlds[iShow] = {};
					FamilyServerSelect.dsWorlds[iShow].id = _id;
					FamilyServerSelect.dsWorlds[iShow].seqno = _seqno;
					FamilyServerSelect.dsWorlds[iShow].ws_id = ws_id;
					FamilyServerSelect.dsWorlds[iShow].gs_nid = gs_nid;
					FamilyServerSelect.dsWorlds[iShow].zoneid = zoneid;	

					if (rookie_id) then
						FamilyServerSelect.dsWorlds[iShow].text = string.match(msg.items[index].name,"(.*)%(.*%)");
					else
						FamilyServerSelect.dsWorlds[iShow].text = msg.items[index].name;
					end					
					FamilyServerSelect.dsWorlds[iShow].percentage = _percentage;				
					FamilyServerSelect.dsWorlds[iShow].people =  _people;
					local _type ="";
					if	(_percentage >= 100) then
						_type = "full";
					end
					FamilyServerSelect.dsWorlds[iShow].type = _type;
					IsShow[id] = "yes";
					--if(iShow >=  6 ) then
						--break;				
					--end;
					iShow = iShow + 1;
				end	
			end

			-- get all friend world server and game server id, mark the server with type "friend"
			-- NOTE 2009/11/6: only online friend world server and game server ids are fetched through jabber roster message
			--		with the modual "mod_private" enabled on jabber server
			local count = MyCompany.Aries.Friends.GetFriendCountInMemory()
			-- LOG.std("", "system", "serverselect", "friend count=%d", count);
			local i;
			for i = 1, count do
				local nid = MyCompany.Aries.Friends.GetFriendNIDByIndexInMemory(i)
				local ws_id, gs_nid = MyCompany.Aries.Friends.GetUserGSAndWorldIDInMemory(nid);
				local i;
			
				if(nid == nil) then nid=0 end;
				if(ws_id == nil) then ws_id="0" end;
				if(gs_nid == nil) then gs_nid="0" end;
			
				local dsWorlds = FamilyServerSelect.dsWorlds;
				local worldname = "";
				local i;
				for i = 1, #(dsWorlds) do
					if(dsWorlds[i].ws_id == ws_id and dsWorlds[i].gs_nid == gs_nid) then
						dsWorlds[i].type = "friend";
						break;
					end
				end
			end
		
			-- if last login world in recommended worlds,remove it.
			local dsWorlds = FamilyServerSelect.dsWorlds;
			for i = 1, #(dsWorlds) do
				if(dsWorlds[i].ws_id == ws_id_last and dsWorlds[i].gs_nid_last == gs_nid) then
					table.remove(FamilyServerSelect.dsWorlds,i);
					break;
				end
			end	
		
			-- sort the table according to the id, set the last logged in server to the highest priority
			table.sort(FamilyServerSelect.dsWorlds, function(a, b)
				--if(a.ws_id == ws_id and a.gs_nid == gs_nid) then
					--return true;
				--end
				--if(b.ws_id == ws_id and b.gs_nid == gs_nid) then
					--return false;
				--end
				return (a.id < b.id);
			end);

			--if (next(FamilyServerSelect.dsWorlds)~= nil) then
				--if (next(FamilyServerSelect.dsWorlds[1])~= nil) then
					---- 如果排名第一服务器是上次登录服务器
					--if (FamilyServerSelect.dsWorlds[1].ws_id==ws_id and FamilyServerSelect.dsWorlds[1].gs_nid==gs_nid) then
						--FamilyServerSelect.LastLoginWorld = commonlib.deepcopy(FamilyServerSelect.dsWorlds[1]);
						---- table.remove(FamilyServerSelect.dsWorlds,1);
					--end
				--end
			--end

			-- 如果推荐服务器数量< 8 则默认显示全部服务器
			--commonlib.echo("===========#(FamilyServerSelect.dsWorlds)")
			--commonlib.echo(#(FamilyServerSelect.dsWorlds))
			if (#(FamilyServerSelect.dsWorlds)< 8 ) then
				FamilyServerSelect.IsAllworld = true;
			end
			IsOnInit = true;
			page:Refresh(0.01);			
		end, nil, 30000, function()
			-- TODO: some time out handler
			log("error: paraworld.WorldServers.GetRecommend timed out.\n");
		end)
	
		-- retrieve all servers
		FamilyServerSelect.OnViewAllWorld(0, 1000);
	end
end

-- @param world_id_or_name: it can be string of ws_id or text
-- @return the the world server table like {ws_id="16", id="016.", text="M5版测试", people=3, type=""}
function FamilyServerSelect.SearchWorldServer(world_id_or_name,bnotshowmsg)

	world_id_or_name = string.gsub(world_id_or_name, "^0*", "")
	world_id_or_name = string.gsub(world_id_or_name, "%.$", "")
	local index, world
	for index, world in ipairs(FamilyServerSelect.dsAllWorlds_all) do 
		if(world.seqno == tonumber(world_id_or_name) or world.text==world_id_or_name) then
			return world;
		end
	end
	
	--search world from db server.	
	if(type(world_id_or_name) == "string") then
		if(world_id_or_name == "paraengine") then
			world_id_or_name = '(pe)(1)(1010)';
		elseif(world_id_or_name == "paraengine1") then
			world_id_or_name = '(pe)(2)(1010)';
		elseif(world_id_or_name == "paraengine2") then
			world_id_or_name = '(pe)(1)(1001)';
		end
		local ws_id, gs_id = string.match(world_id_or_name, "^%(pe%)%((%d+)%)%((%d+)%)$");
		if(ws_id and gs_id) then
			local world = {};
			local _;
			world.ws_id = ws_id;
			world.gs_nid = gs_id;
			world.text = "秘密基地";
			world.type = "";
			world.id = -007;
			world.percentage = (100*0)/100;
			--FamilyServerSelect.SwitchWorldServer(world);
			return world;
		end
	end
	
	if(tonumber(world_id_or_name) == nil) then
		paraworld.WorldServers.GetByName({name=world_id_or_name}, "test", function (msg)
			if(not msg.errorcode) then
				local zoneid = tonumber(msg.zoning);
				if (FamilyServerSelect.IsMyWorldZone(zoneid)) then
					local world = {};
					local _;
					_, _, world.ws_id,world.gs_nid = string.find(msg.id,"%((%w+)%)(%w+)");
					world.text = msg.name;
					world.type = "";
					world.id = string.format("%03d.", msg.vid);
					world.percentage = (100*msg.cur)/msg.max;
					--FamilyServerSelect.SwitchWorldServer(world);
					return world;
				else
					_guihelper.MessageBox([[<div style="margin-left:30px;margin-top:30px;">当前运营商该服务器不存在，请重新输入。</div>]])
				end;
			elseif(bnotshowmsg~=true)then
				_guihelper.MessageBox([[<div style="margin-left:30px;margin-top:30px;">该服务器不存在，请重新输入。</div>]])
			end
		end)
	else
		paraworld.WorldServers.GetByVID({vid=tonumber(world_id_or_name)}, "test", function (msg)
			--commonlib.log("recv get by vid\n");
			--commonlib.echo(msg);
			if(not msg.errorcode) then
				local zoneid = tonumber(msg.zoning);
				if (FamilyServerSelect.IsMyWorldZone(zoneid)) then
					local world = {};
					local _;
					_, _, world.ws_id,world.gs_nid = string.find(msg.id,"%((%w+)%)(%w+)");
					world.text = msg.name;
					world.type = "";
					world.id = string.format("%03d.", msg.vid);
					world.percentage = (100*msg.cur)/msg.max;
					--FamilyServerSelect.SwitchWorldServer(world);
					return world;
				else
					_guihelper.MessageBox([[<div style="margin-left:30px;margin-top:30px;">当前运营商该服务器不存在，请重新输入。</div>]])
				end;
			elseif(bnotshowmsg~=true)then
				_guihelper.MessageBox([[<div style="margin-left:30px;margin-top:30px;">该服务器不存在，请重新输入。</div>]])
			end
		end)
	end
end

function FamilyServerSelect.SearchWorldServerEx(world_id_or_name)
	world_id_or_name = string.gsub(world_id_or_name, "^0*", "")
	world_id_or_name = string.gsub(world_id_or_name, "%.$", "")
	local index, world
	for index, world in ipairs(FamilyServerSelect.dsAllWorlds_all) do 
		--LOG.std("", "system", "serverselect", "compare in dsAllWorlds: index=%s,seqno=%s,text=%s", index,world.seqno,world.text);
		if(world.seqno == tonumber(world_id_or_name) or world.text==world_id_or_name) then
			return world;
		end
	end
end
-- user selected a given world.
function FamilyServerSelect.OnSelectWorld(ws_id)
	-- LOG.std("", "system", "serverselect", "select ws_id=%s", tostring(ws_id));
	local world = FamilyServerSelect.SearchWorldServerEx(ws_id)
	if(world) then
		FamilyServerSelect.SwitchWorldServer(world);
	else
		_guihelper.MessageBox([[<div style="margin-left:30px;margin-top:30px;">该服务器不存在，请重新输入。</div>]])
	end
end

-- on click event handler. 
function FamilyServerSelect.OnClickSelectWorld()
	local world_name = page:GetValue("world_name");
	-- commonlib.log("begin to do OnClickSelectWorld!world_name=%s\n", world_name);
	if(type(world_name) ~= "string" or world_name=="") then
		_guihelper.MessageBox([[<div style="margin-left:60px;margin-top:30px;">请输入服务器ID或名称</div>]])
	else
		local world = FamilyServerSelect.SearchWorldServer(world_name)
		if(world) then
			FamilyServerSelect.SwitchWorldServer(world);
		--else
			--_guihelper.MessageBox("您输入的服务器不存在, 请输入服务器ID或名称")
		end
	end
end

-- enter the world server
function FamilyServerSelect.SwitchWorldServer(world, oncemore, callbackFunc)
	if(not world) then return end
	local can_enter_world = true;
	if(world.type == "full" or world.percentage>=100) then
		can_enter_world = false;
	end
	NPL.load("(gl)script/apps/Aries/VIP/main.lua");
	local VIP = commonlib.gettable("MyCompany.Aries.VIP");
	if(VIP.IsActivated() and VIP.IsVIP() and world.percentage<=150) then
		-- LOG.std("", "system", "serverselect", "vip user enter world!");
		can_enter_world = true;
	end
	if(can_enter_world == false) then
		_guihelper.MessageBox("这台服务器太拥挤了, 暂时无法进入, 试试没有满员的服务器吧!")
		if(callbackFunc) then
			callbackFunc(false);
		end
	else
		-- LOG.std("", "system", "serverselect", "user selected"..commonlib.serialize(world));
		if(page) then
			page:CloseWindow();
		end
		
		-- write the world server config for each nid
		MyCompany.Aries.app:WriteConfig(System.App.profiles.ProfileManager.GetNID().."LastLoggedinWorldServer", world);
		
		local is_switching_from_game;
		local from;
		if(page) then
			from = page:GetRequestParam("from");
			if(from and from=="setting") then
				is_switching_from_game = true;
			end
		end

		-- post switch world server log
		paraworld.PostLog({action = "user_switch_to_worldserver", 
				gs_nid = world.gs_nid, 
				ws_id = world.ws_id,
				ws_text = world.text,
				ws_seqid = world.id,
			}, "user_switch_to_worldserver", function(msg)
		end);
		
		-- go to next step after we have an authenticated connection.
		local function GotoNextStep()
			NPL.load("(gl)script/apps/GameServer/GSL.lua");
			Map3DSystem.GSL_client:Reset();
			
			if(callbackFunc) then
				callbackFunc(true);
			end

			-- go to next step
			MainLogin:next_step({
				IsWorldServerSelected = true, 
				IsLoadMainWorldRequested=true, 
				load_world_params = {
					worldpath = world.worldpath,
					gs_nid = world.gs_nid, 
					ws_id = world.ws_id,
					ws_text = world.text,
					ws_seqid = world.id,
				},
			});
		end
		
		local function ConnectFail(reasonText)
			commonlib.applog(string.format("failed to connect to %s", world.gs_nid));
			
			if(not is_switching_from_game) then
				Map3DSystem.App.MiniGames.SwfLoadingBarPage.UpdateText(nil);
				Map3DSystem.App.MiniGames.SwfLoadingBarPage.ClosePage();
				_guihelper.MessageBox(reasonText or "无法连接这台服务器, 请试试其他服务器")
				
				MyCompany.Aries.MainLogin:next_step(state or {IsLoginStarted = false});
			else
				_guihelper.MessageBox(reasonText or "无法连接这台服务器, 请重新登录并试试其他服务器", function()
					Map3DSystem.App.Commands.Call("Profile.Aries.Restart", {method="soft"});
				end)
			end	

			if(callbackFunc) then
				callbackFunc(false);
			end
		end
		
		----------------------------
		-- switch game server and authenticate using old account
		----------------------------
		if(not is_switching_from_game) then
			local rest_client = GameServer.rest.client;
			if(rest_client:get_current_server_nid() == world.gs_nid) then
				-- if user selects the same server as we logged in, use it. 
				GotoNextStep();
			else
				Map3DSystem.App.MiniGames.SwfLoadingBarPage.ShowPage({ top = -50 });
				Map3DSystem.App.MiniGames.SwfLoadingBarPage.Update(0.2);
				Map3DSystem.App.MiniGames.SwfLoadingBarPage.UpdateText("正在切换服务器...");
			
				-- if user selects a different game server, diconnect old and connect to the new one and sign in using the same account. 
				GameServer.rest.client:connect({nid=world.gs_nid, world_id=world.ws_id,}, timeout, function(msg) 
					if(msg.connected) then
						commonlib.applog(string.format("connection with world server %s is established", world.gs_nid))
						Map3DSystem.App.MiniGames.SwfLoadingBarPage.Update(0.5);
						Map3DSystem.App.MiniGames.SwfLoadingBarPage.UpdateText("连接成功, 正在验证用户身份...");
						if(msg.is_switch_connection) then
							-- authenticate again with the new game server using existing account. 
							paraworld.auth.AuthUser(System.User.last_login_msg or {username = tostring(System.User.username), password = System.User.Password,}, "login", function (msg)
								if(msg==nil) then
									ConnectFail("这台服务器无法认证, 请试试其他服务器");
								elseif(msg.issuccess) then	
									FamilyServerSelect.LastLoginWorld = {id=world.id, seqno=world.seqno, ws_id=world.ws_id, gs_nid=world.gs_nid, zoneid=world.zoneid, text=world.text, percentage=world.percentage, people=world.people, type="last", };
									Map3DSystem.App.MiniGames.SwfLoadingBarPage.UpdateText(nil);
									Map3DSystem.App.MiniGames.SwfLoadingBarPage.ClosePage();
									GotoNextStep();
								else
									ConnectFail("服务器认证失败了, 请重新登录");
								end
							end, nil, 20000, function(msg)
								-- timeout request
								commonlib.applog("Proc_Authentication timed out")
								ConnectFail("用户验证超时了, 可能服务器太忙了, 或者您的网络质量不好.");
							end);
						end
					else
						ConnectFail("无法连接这台服务器, 请试试其他服务器");
					end
				end)
			end
		else
			local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
			local address = WorldManager:GetWorldAddress() or {};
			-- we are switching after the user has signed in. 
			paraworld.ShowMessage("正在切换服务器...", nil, _guihelper.MessageBoxButtons.Nothing);

			local function LoadWorld_()
				System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {
							gs_nid = world.gs_nid,-- force using the game server nid
							ws_id = world.ws_id, -- force using the world server id
							ws_seqid = world.id;
							ws_text = world.text;
							name = address.name,
							PosX = address.x,
							PosY = address.y,
							PosZ = address.z,
						});
			end

			----------------------------
			-- switch game server and authenticate using old account
			----------------------------
			local rest_client = GameServer.rest.client;
			Map3DSystem.GSL_client:LogoutServer();
			-- disconnect first
			Map3DSystem.GSL_client:Disconnect();
			GameServer.rest.client:disconnect();

			-- here we will wait 5 seconds before proceeding. 
			-- if target is on a different game server, diconnect old and connect to the new one and sign in using the same account. 
			local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
				GameServer.rest.client:connect({nid=world.gs_nid, world_id=world.ws_id,}, nil, function(msg) 
					if(msg.connected) then
						LOG.std(nil, "system", "ServerSelect", "connection with game server %s is established", world.gs_nid)
					
						-- authenticate again with the new game server using existing account. 
						paraworld.auth.AuthUser(System.User.last_login_msg or {username = tostring(System.User.username), password = System.User.Password,}, "login", function (msg)
							if(msg==nil) then
								ConnectFail("这台服务器无法认证, 请试试其他服务器");
							elseif(msg.issuccess) then	
								FamilyServerSelect.LastLoginWorld = {id=world.id, seqno=world.seqno, ws_id=world.ws_id, gs_nid=world.gs_nid, zoneid=world.zoneid, text=world.text, percentage=world.percentage, people=world.people, type="last", };
								LoadWorld_();
							else
								ConnectFail("服务器认证失败了, 请重新登录");
							end
						end, nil, 20000, function(msg)
							-- timeout request
							commonlib.applog("Proc_Authentication timed out")
							ConnectFail("用户验证超时了, 可能服务器太忙了, 或者您的网络质量不好.");
						end);
					else
						ConnectFail("无法连接这台服务器, 请试试其他服务器");
					end
				end)
			end})
			mytimer:Change(5000,nil);
		end
	end	
end

-- view all
function FamilyServerSelect.OnViewAllWorld(pageIndex, pageSize)
	if(pageIndex == nil) then
		pageIndex = 0;
	end
	if(pageSize == nil) then
		pageSize = 10;
	end

	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
	local region_id = ExternalUserModule:GetRegionID();
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		level = bean.combatlel or 1;
	else
		level = 1;
	end
	--if (level <10) then
		--rookieYN=true;
	--else
		--rookieYN=false;
	--end

	if (region_id~=0) then
		FamilyServerSelect.dsWorlds={};
	end
	paraworld.WorldServers.Get({pageIndex=pageIndex,pageSize=pageSize}, "RetrieveAllWorldServers", function (msg)
		LOG.std(nil, "system", "selectpage", "pages:%s", commonlib.serialize_compact(msg.items));
		
		FamilyServerSelect.dsAllWorlds = {}; -- 当前大区的 allworlds
		FamilyServerSelect.dsAllWorlds_all = {}; -- 所有大区的 allworlds

		local lastworld = MyCompany.Aries.app:ReadConfig(System.App.profiles.ProfileManager.GetNID().."LastLoggedinWorldServer", {});
		local rookie_ws_seq=1;
		local allrookie_ws_seq = 1;
		local allRookieWorlds={};
		local tmpLeastpeople,tmpLeastWorld,tmpLastWorld=5,{},{};

		local id,zoneid,index,world;
		local windex=1;
		for index, world in ipairs(msg.items) do 
			local _, _, ws_id,gs_nid = string.find(msg.items[index].id,"%((%w+)%)(%w+)");
			id = string.format("(%s)%s",ws_id,gs_nid);
			zoneid = tonumber(msg.items[index].zoning);

			local _wid = string.format("%03d.",msg.items[index].vid);
			local _wseqno = msg.items[index].vid;
			FamilyServerSelect.dsAllWorlds_all[index] = {};
			FamilyServerSelect.dsAllWorlds_all[index].id = _wid;
			FamilyServerSelect.dsAllWorlds_all[index].seqno = _wseqno;
			FamilyServerSelect.dsAllWorlds_all[index].ws_id = ws_id;
			FamilyServerSelect.dsAllWorlds_all[index].gs_nid = gs_nid;
			FamilyServerSelect.dsAllWorlds_all[index].zoneid = zoneid;
			
			-- rookie svr name like "泡泡广场(新手村)"
			local rookie_id = string.find(msg.items[index].name,"(.*)%(.*%)");

			if (rookie_id) then
				if (rookieYN) then
					local worldname = string.match(msg.items[index].name,"(%(.*%))");
					FamilyServerSelect.dsAllWorlds_all[index].text = string.match(worldname,"%((.*)%)");
				else
					FamilyServerSelect.dsAllWorlds_all[index].text = string.match(msg.items[index].name,"(.*)%(.*%)");
				end
			else
				FamilyServerSelect.dsAllWorlds_all[index].text = msg.items[index].name;				
			end
			FamilyServerSelect.dsAllWorlds_all[index].percentage = (100 * msg.items[index].cur) / msg.items[index].max;				
			FamilyServerSelect.dsAllWorlds_all[index].people = msg.items[index].level;
			if(FamilyServerSelect.dsAllWorlds_all[index].percentage >= 100) then
				FamilyServerSelect.dsAllWorlds_all[index].type = "full";
			else
				FamilyServerSelect.dsAllWorlds_all[index].type = "";
			end

			if (FamilyServerSelect.IsMyWorldZone(zoneid) and (FamilyServerSelect.IsRecommendBigZone(zoneid))) then
				FamilyServerSelect.dsAllWorlds[windex] = {};
				FamilyServerSelect.dsAllWorlds[windex].id = _wid;
				FamilyServerSelect.dsAllWorlds[windex].seqno = _wseqno;
				FamilyServerSelect.dsAllWorlds[windex].ws_id = ws_id;
				FamilyServerSelect.dsAllWorlds[windex].gs_nid = gs_nid;
				FamilyServerSelect.dsAllWorlds[windex].zoneid = zoneid;
				
				if (region_id~=0) then
					FamilyServerSelect.dsWorlds[windex] = {};
					FamilyServerSelect.dsWorlds[windex].id = _wid;
					FamilyServerSelect.dsWorlds[windex].seqno = msg.items[index].vid;
					FamilyServerSelect.dsWorlds[windex].ws_id = ws_id;
					FamilyServerSelect.dsWorlds[windex].gs_nid = gs_nid;
					FamilyServerSelect.dsWorlds[windex].zoneid = zoneid;
				end
				
				local worldname;

				if (rookie_id) then
					if (rookieYN) then
						-- worldname = string.match(msg.items[index].name,"(%(.*%))");
						worldname = string.match(msg.items[index].name,"(.*)%(.*%)");
						-- FamilyServerSelect.dsAllWorlds[windex].text = string.match(worldname,"%((.*)%)");
						FamilyServerSelect.dsAllWorlds[windex].text = worldname;
						local tmpRookie_ws_seq = rookie_ws_seq;
						if (next(lastworld) ~= nil) then
							if (ws_id == lastworld.ws_id and gs_nid == lastworld.gs_nid) then
								tmpLastWorld.id = _wid;
								tmpLastWorld.seqno = _wseqno;
								tmpLastWorld.ws_id = ws_id;
								tmpLastWorld.gs_nid = gs_nid;
								tmpLastWorld.zoneid = zoneid;
								--tmpLastWorld.text = string.match(worldname,"%((.*)%)");
								tmpLastWorld.text = worldname;
								tmpLastWorld.percentage = (100 * msg.items[index].cur) / msg.items[index].max;				
								tmpLastWorld.people = msg.items[index].level;
								if(tmpLastWorld.percentage >= 100) then
									tmpLastWorld.type = "full";
								else
									tmpLastWorld.type = "";
								end
								tmpLastWorld.is_rookie=tmpRookie_ws_seq;		
							end	
						end
						-- get less than 3 stars worldsvr to rookie svr list
						if (msg.items[index].level <=3 and rookie_ws_seq<=10) then
							FamilyServerSelect.dsRookieWorlds[tmpRookie_ws_seq] = {};
							FamilyServerSelect.dsRookieWorlds[tmpRookie_ws_seq].id = _wid;
							FamilyServerSelect.dsRookieWorlds[tmpRookie_ws_seq].seqno = _wseqno;
							FamilyServerSelect.dsRookieWorlds[tmpRookie_ws_seq].ws_id = ws_id;
							FamilyServerSelect.dsRookieWorlds[tmpRookie_ws_seq].gs_nid = gs_nid;
							FamilyServerSelect.dsRookieWorlds[tmpRookie_ws_seq].zoneid = zoneid;
							-- FamilyServerSelect.dsRookieWorlds[tmpRookie_ws_seq].text = string.match(worldname,"%((.*)%)");
							FamilyServerSelect.dsRookieWorlds[tmpRookie_ws_seq].text = worldname;
							FamilyServerSelect.dsRookieWorlds[tmpRookie_ws_seq].percentage = (100 * msg.items[index].cur) / msg.items[index].max;				
							FamilyServerSelect.dsRookieWorlds[tmpRookie_ws_seq].people = msg.items[index].level;
							if(FamilyServerSelect.dsRookieWorlds[tmpRookie_ws_seq].percentage >= 100) then
								FamilyServerSelect.dsRookieWorlds[tmpRookie_ws_seq].type = "full";
							else
								FamilyServerSelect.dsRookieWorlds[tmpRookie_ws_seq].type = "";
							end							
							rookie_ws_seq = rookie_ws_seq + 1;
						
						-- get other rookie svr (more than 3 stars) to allRookieWorlds
						elseif (msg.items[index].level >3) then
							allRookieWorlds[allrookie_ws_seq] = {};
							allRookieWorlds[allrookie_ws_seq].id = _wid;
							allRookieWorlds[allrookie_ws_seq].seqno = _wseqno;
							allRookieWorlds[allrookie_ws_seq].ws_id = ws_id;
							allRookieWorlds[allrookie_ws_seq].gs_nid = gs_nid;
							allRookieWorlds[allrookie_ws_seq].zoneid = zoneid;
							-- allRookieWorlds[allrookie_ws_seq].text = string.match(worldname,"%((.*)%)");
							allRookieWorlds[allrookie_ws_seq].text = worldname;
							allRookieWorlds[allrookie_ws_seq].percentage = (100 * msg.items[index].cur) / msg.items[index].max;				
							allRookieWorlds[allrookie_ws_seq].people = msg.items[index].level;
							if(allRookieWorlds[allrookie_ws_seq].percentage >= 100) then
								allRookieWorlds[allrookie_ws_seq].type = "full";
							else
								allRookieWorlds[allrookie_ws_seq].type = "";
							end	
							allrookie_ws_seq = allrookie_ws_seq+1;
						end
					else
						FamilyServerSelect.dsAllWorlds[windex].text = string.match(msg.items[index].name,"(.*)%(.*%)");
						if (region_id~=0) then
							FamilyServerSelect.dsWorlds[windex].text = string.match(msg.items[index].name,"(.*)%(.*%)");
						end
					end  -- if (rookieYN) then
				else
					-- 如果10级以下用户，上次进入服务器为普通服务器
					local tmpRookie_ws_seq = rookie_ws_seq;
					if (next(lastworld) ~= nil) then
						if (ws_id == lastworld.ws_id and gs_nid == lastworld.gs_nid) then
							tmpLastWorld.id = _wid;
							tmpLastWorld.seqno = _wseqno;
							tmpLastWorld.ws_id = ws_id;
							tmpLastWorld.gs_nid = gs_nid;
							tmpLastWorld.zoneid = zoneid;
							tmpLastWorld.text = msg.items[index].name;
							tmpLastWorld.percentage = (100 * msg.items[index].cur) / msg.items[index].max;				
							tmpLastWorld.people = msg.items[index].level;
							if(tmpLastWorld.percentage >= 100) then
								tmpLastWorld.type = "full";
							else
								tmpLastWorld.type = "";
							end	
							tmpLastWorld.is_rookie=0;
						end
					end
					FamilyServerSelect.dsAllWorlds[windex].text = msg.items[index].name;
					if (region_id~=0) then
						FamilyServerSelect.dsWorlds[windex].text = msg.items[index].name;
					end
				end  -- if (rookie_id) then
			
				FamilyServerSelect.dsAllWorlds[windex].percentage = (100 * msg.items[index].cur) / msg.items[index].max;				
				FamilyServerSelect.dsAllWorlds[windex].people = msg.items[index].level;
				if(FamilyServerSelect.dsAllWorlds[windex].percentage >= 100) then
					FamilyServerSelect.dsAllWorlds[windex].type = "full";
				else
					FamilyServerSelect.dsAllWorlds[windex].type = "";
				end

				if (region_id~=0) then
					FamilyServerSelect.dsWorlds[windex].percentage = (100 * msg.items[index].cur) / msg.items[index].max;				
					FamilyServerSelect.dsWorlds[windex].people = msg.items[index].level;
					if(FamilyServerSelect.dsWorlds[windex].percentage >= 100) then
						FamilyServerSelect.dsWorlds[windex].type = "full";
					else
						FamilyServerSelect.dsWorlds[windex].type = "";
					end
				end
		
				-- 取普通服务器人数最少的服务器, 并且不是上次登录服务器
				if ((not rookie_id) and (tmpLeastpeople>msg.items[index].level) and (not(ws_id == lastworld.ws_id and gs_nid == lastworld.gs_nid))) then
					tmpLeastpeople = msg.items[index].level;
					tmpLeastWorld = commonlib.deepcopy(FamilyServerSelect.dsAllWorlds[windex]);
					--commonlib.echo("==========tmpLeastWorld:");
					--commonlib.echo(tmpLeastWorld);
				end
				windex = windex+1;
			end -- if (FamilyServerSelect.IsMyWorldZone(zoneid))
		end -- for index, world in ipairs(msg.items)

		if (rookieYN) then			
			-- sort allRookieWorlds by people 
			table.sort(allRookieWorlds, function(a, b)
				return (a.people < b.people);
			end);

			-- if rookie svr list not full, append from allRookieWorlds one by one.
			if (rookie_ws_seq<=8) then
				local i,j;
				-- 如果新手村人数都是 5星，则最多补到第9个服务器，剩下一个选普通服务器人数最少的
				if (allrookie_ws_seq > 1) then
					if  (allRookieWorlds[1].people>=4) then
						if ((7 - rookie_ws_seq ) > allrookie_ws_seq ) then
							j = allrookie_ws_seq;
						else
							j = 7 - rookie_ws_seq;
						end		
					else
						if ((8 - rookie_ws_seq ) > allrookie_ws_seq ) then
							j = allrookie_ws_seq;
						else
							j = 8 - rookie_ws_seq;
						end		
					end								
					for i=0,j-1 do
						FamilyServerSelect.dsRookieWorlds[rookie_ws_seq+i] = commonlib.deepcopy(allRookieWorlds[i+1]);
					end
					-- 如果新手村人数都是 5星，则最多补到第9个服务器，剩下一个选普通服务器人数最少的
					if (allRookieWorlds[1].people>=4) then
						FamilyServerSelect.dsRookieWorlds[rookie_ws_seq+j] = commonlib.deepcopy(tmpLeastWorld);
					end
				else
					if (next(tmpLeastWorld)~=nil) then
						FamilyServerSelect.dsRookieWorlds[rookie_ws_seq] = commonlib.deepcopy(tmpLeastWorld);
					end
				end
			end -- if (rookie_ws_seq<=8) 
			
			if (next(FamilyServerSelect.dsRookieWorlds)~=nil) then
				if (next(tmpLastWorld)~=nil) then				
					FamilyServerSelect.LastLoginWorld = commonlib.deepcopy(tmpLastWorld);
					if (tmpLastWorld.is_rookie~=0) then
						table.remove(FamilyServerSelect.dsRookieWorlds,tmpLastWorld.is_rookie);
					end
				end
			end

			-- 如果新手服务器推荐 < 8 ,则显示全部服务器
			if (#(FamilyServerSelect.dsRookieWorlds)<8) then
				FamilyServerSelect.IsAllworld = true;
			end
			--commonlib.echo("=============FamilyServerSelect.LastLoginWorld");
			--commonlib.echo(FamilyServerSelect.LastLoginWorld);			
			--commonlib.echo("==========dsRookieWorlds:");
			--commonlib.echo(FamilyServerSelect.dsRookieWorlds);
		else
			if (region_id~=0) then
			-- sort allRookieWorlds by people 
				table.sort(FamilyServerSelect.dsWorlds, function(a, b)
					return (a.people < b.people);
				end);
				-- get all friend world server and game server id, mark the server with type "friend"
				-- NOTE 2009/11/6: only online friend world server and game server ids are fetched through jabber roster message
				--		with the modual "mod_private" enabled on jabber server
				local count = MyCompany.Aries.Friends.GetFriendCountInMemory()
				-- LOG.std("", "system", "serverselect", "friend count=%d", count);
				local i;
				for i = 1, count do
					local nid = MyCompany.Aries.Friends.GetFriendNIDByIndexInMemory(i)
					local ws_id, gs_nid = MyCompany.Aries.Friends.GetUserGSAndWorldIDInMemory(nid);
					local i;
			
					if(nid == nil) then nid=0 end;
					if(ws_id == nil) then ws_id="0" end;
					if(gs_nid == nil) then gs_nid="0" end;
			
					local dsWorlds = FamilyServerSelect.dsWorlds;
					for i = 1, #(dsWorlds) do
						if(dsWorlds[i].ws_id == ws_id and dsWorlds[i].gs_nid == gs_nid) then
							dsWorlds[i].type = "friend";
							break;
						end
					end
				end
		
				-- read the world server config for each nid
				local world = MyCompany.Aries.app:ReadConfig(System.App.profiles.ProfileManager.GetNID().."LastLoggedinWorldServer", {});
		
				-- mark last loggedin world server with type "last"
				local ws_id = world.ws_id;
				local gs_nid = world.gs_nid;
				local dsWorlds = FamilyServerSelect.dsWorlds;
				local i;
				for i = 1, #(dsWorlds) do
					if(dsWorlds[i].ws_id == ws_id and dsWorlds[i].gs_nid == gs_nid) then
						dsWorlds[i].type = "last";
						break;
					end
				end
		
				-- sort the table according to the id, set the last logged in server to the highest priority
				table.sort(FamilyServerSelect.dsWorlds, function(a, b)
					if(a.ws_id == ws_id and a.gs_nid == gs_nid) then
						return true;
					end
					if(b.ws_id == ws_id and b.gs_nid == gs_nid) then
						return false;
					end
					return (a.id < b.id);
				end);

				--if (next(world) ~= nil) then
				if (next(FamilyServerSelect.dsWorlds)~= nil) then
					if (next(FamilyServerSelect.dsWorlds[1])~= nil) then
						FamilyServerSelect.LastLoginWorld = commonlib.deepcopy(FamilyServerSelect.dsWorlds[1]);
				--		table.remove(FamilyServerSelect.dsWorlds,1);
					end
				end

			end -- if (region_id~=0)

		end -- if (rookieYN) (upper line of sort allRookieWorlds)
		IsOnInit = true;
		FamilyServerSelect.page:Refresh(0.01);		
	end)
end

function FamilyServerSelect.HasFamilyServer()
	if(MyCompany.Aries.Friends.familyworld and MyCompany.Aries.Friends.familyworld ~="")then
		local world = FamilyServerSelect.SearchWorldServerEx(MyCompany.Aries.Friends.familyworld,true);
		if (world) then
			return true;
		else
			return false;
		end
	else
		return false;
	end
end

function FamilyServerSelect.GetFamilyPeople()
	if(FamilyServerSelect.dsAllWorlds_all)then
		if(MyCompany.Aries.Friends.familyworld and MyCompany.Aries.Friends.familyworld ~="")then
			local world = FamilyServerSelect.SearchWorldServerEx(MyCompany.Aries.Friends.familyworld,true);
			if(world)then
				return world.people;
			end
		end
	end

	return 0;
end

function FamilyServerSelect.GetFamilySeqno()
	if(FamilyServerSelect.dsAllWorlds_all)then

		if(MyCompany.Aries.Friends.familyworld and MyCompany.Aries.Friends.familyworld ~="")then
			local world = FamilyServerSelect.SearchWorldServerEx(MyCompany.Aries.Friends.familyworld,true);
			if(world)then
				return world.seqno;
			end
		end
	end
	return 0;
end

function FamilyServerSelect.GetFamilyType()
	if(FamilyServerSelect.dsAllWorlds_all)then

		if(MyCompany.Aries.Friends.familyworld and MyCompany.Aries.Friends.familyworld ~="")then
			local world = FamilyServerSelect.SearchWorldServerEx(MyCompany.Aries.Friends.familyworld,true);
			if(world)then
				return world.type;
			end
		end
	end
	return "";
end

function FamilyServerSelect.GetFamilyText()
	if(MyCompany.Aries.Friends.familyworld and FamilyServerSelect.dsAllWorlds_all)then
		local world = FamilyServerSelect.SearchWorldServerEx(MyCompany.Aries.Friends.familyworld,true);
		if(world)then	
			local zonename = FamilyServerSelect.GetZoneName(world.zoneid);
			FamilyServerSelect.familyworldname = world.text;
			local s = zonename .. " - " .. world.text;
			return s;
		else
			return "维护中...";
		end
	else
		return "";
	end
end

function FamilyServerSelect.GetZoneName(zoneid)
	local i;
	for i = 1, #(bigzone) do
		if (zoneid==bigzone[i].zoneid)then
			return bigzone[i].name
		end
	end
end

function FamilyServerSelect.GetLastLoginWorld_nid()
	local world=FamilyServerSelect.LastLoginWorld;
	if (next(world) ~= nil) then
		return world.gs_nid or "";
	end
	return "";
end

function FamilyServerSelect.GetLastLoginWorld_people()
	local world=FamilyServerSelect.LastLoginWorld;
	if (next(world) ~= nil) then
				return world.people;
	end
	return 0;
end

function FamilyServerSelect.GetLastLoginWorld_seqno()
	local world=FamilyServerSelect.LastLoginWorld;
	if (next(world) ~= nil) then
				return world.seqno;
	end
	return 0;
end

function FamilyServerSelect.GetLastLoginWorld_type()
	local world=FamilyServerSelect.LastLoginWorld;
	if (next(world) ~= nil) then
				return world.type;
	end
	return "";
end

function FamilyServerSelect.GetLastLoginWorld_text()
	local world=FamilyServerSelect.LastLoginWorld;
	if (next(world) ~= nil) then
		local zonename = FamilyServerSelect.GetZoneName(world.zoneid);
		local s="";
		if (zonename) then
			s= zonename .. " - " .. world.text;
		end
		return s;
	end
	return "";
end

function FamilyServerSelect.RefreshFamilyServerInfo()
	
	--Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nil, "", function (msg)
		--if(msg and msg.users and msg.users[1]) then
			--local user = msg.users[1];
			--local family = user.family;
			--if(family and family ~= "")then
				--local msg2 = {idorname = family,};
				--paraworld.Family.Get(msg2, "Aries_MiJiuHuLu_OnClickAward", function(msg2)
					--if(msg2 and not msg2.errorcode)then
						--if(msg2.familyworld and familyworld ~= "")then
							--MyCompany.Aries.Friends.familyworld = msg2.familyworld;
							--local world = FamilyServerSelect.SearchWorldServer(MyCompany.Aries.Friends.familyworld);
							--if(world)then
								--FamilyServerSelect.familyworldname = world.text;
							--end
						--end
					--end
				--end);				
			--end
		--end
	--end);
end