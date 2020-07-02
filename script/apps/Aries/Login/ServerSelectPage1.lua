--[[
Title: Aries Server Select Page
Author(s): LiXizhi
Date: 2009/7/31
Desc:  script/apps/Aries/Login/ServerSelectPage1.html?page=0
Display recommended world server list. 
To display all world:
	script/apps/Aries/Login/ServerSelectPage1.html?allworld=true
To switch server from within the game:	
	script/apps/Aries/Login/ServerSelectPage1.html?from=setting

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/ServerSelectPage1.lua");
-------------------------------------------------------
]]
local ServerSelectPage = commonlib.gettable("MyCompany.Aries.ServerSelectPage")

local level,rookieYN;
rookieYN=false;

-- TODO: grab this table during start up. and then sort according to design rules. 
--ServerSelectPage.dsWorlds = {
	---- where gs_nid is the game server nid, and ws_id is the world server id, worldpath can be nil if default one is used.  
	--{ws_id="1", gs_nid="1001", id="001.", text="泡泡广场", people=2, type="", percentage=70},
	--{ws_id="2", gs_nid="1001", id="002.", text="生命之泉", people=1, type="", percentage=40},
	--{ws_id="3", gs_nid="1001", id="003.", text="龙源密境", people=1, type="", percentage=10},
	--{ws_id="4", gs_nid="1001", id="004.", text="", people=1, type="", percentage=70},
	--{ws_id="5", gs_nid="1001", id="005.", text="火焰山洞", people=1, type="", percentage=100},
	--{ws_id="6", gs_nid="1001", id="006.", text="龙龙乐园", people=1, type="", percentage=40},
	----{ws_id="7", gs_nid="1001", id="007.", text="通过测试", people=1, type="", percentage=10},
	----{ws_id="8", gs_nid="1001", id="008.", text="8月版存档", people=1, type="", percentage=10},
	----{ws_id="9", gs_nid="1001", id="009.", text="9月版存档", people=1, type="", percentage=10},
	----{ws_id="10", gs_nid="1001", id="010.", text="10月版存档", people=1, type="", percentage=40},
	----{ws_id="11", gs_nid="1001", id="011.", text="11月版存档", people=1, type="friend", percentage=40},
	----{ws_id="12", gs_nid="1001", id="012.", text="12月版存档", people=1, type="", percentage=70},
	----{ws_id="13", gs_nid="1001", id="013.", text="1月版存档", people=1, type="", percentage=60},
	----{ws_id="14", gs_nid="1001", id="014.", text="2月版存档", people=1, type="", percentage=80},
	----{ws_id="15", gs_nid="1001", id="015.", text="M4版存档", people=1, type="", percentage=40},
	----{ws_id="16", gs_nid="1001", id="016.", text="M5版存档", people=1, type="", percentage=60},
--}
-- The data source function. 
function ServerSelectPage.DS_Func(index, pageCtrl)
	if(index == nil) then
		if(ServerSelectPage.dsWorlds)then
			return #(ServerSelectPage.dsWorlds);
		end	
	else
		return ServerSelectPage.dsWorlds[index];
	end
end

-- The data source function. 
function ServerSelectPage.DS_AllWorld_Func(index, pageCtrl)
	if(index == nil) then
		if(ServerSelectPage.dsAllWorlds)then
			return #(ServerSelectPage.dsAllWorlds);
		end	
	else
		return ServerSelectPage.dsAllWorlds[index];
	end
end

-- The data source function. 
function ServerSelectPage.DS_Rookie_Func(index, pageCtrl)
	if(index == nil) then		
		if(ServerSelectPage.dsRookieWorlds)then
			return #(ServerSelectPage.dsRookieWorlds);
		end	
	else
		return ServerSelectPage.dsRookieWorlds[index];
	end
end
---------------------------------
-- page event handlers
---------------------------------
-- singleton page
local page;
local MainLogin = commonlib.gettable("MyCompany.Aries.MainLogin");
local IsOnInit = false;

function ServerSelectPage.AllowWebUpdate()
	IsOnInit = false;
end

-- init
function ServerSelectPage.OnInit()
	-- System.User.nid
	page = document:GetPageCtrl();
	
	if(IsOnInit) then
		do return end;
	end
	
	--commonlib.echo("ServerSelectPage.OnInit Begin!\n");
		
	local iShow=0;
	IsShow ={};		

	ServerSelectPage.dsRookieWorlds = {};
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		level = bean.combatlel or 1;
	end
	--if (level <10) then
		--rookieYN=true;
	--else
		--rookieYN=false;
	--end


	if (rookieYN) then
	-- retrieve all servers
		ServerSelectPage.OnViewAllWorld(0, 1000);
	else
		paraworld.WorldServers.GetRecommend({}, "test", function (msg)
			--commonlib.echo(msg.items);
			LOG.std(nil, "system", "selectpage", "msg.items:%s", commonlib.serialize_compact(msg.items));
			iShow = iShow + 1;
			--commonlib.log("in get recommend,iShow=%s\n", iShow);
			ServerSelectPage.dsWorlds = {};
			for index, world in ipairs(msg.items) do 
				_, _, ws_id,gs_nid = string.find(msg.items[index].id,"%((%w+)%)(%w+)");
				--xx,yy = string.match("(5)1002","%((%d+)%)(%d+)");
				--commonlib.log("xx= %d, yy=%s\n", ws_id, gs_nid);
				id = string.format("(%s)%s",ws_id,gs_nid);
				if(IsShow[id] == nil) then
					ServerSelectPage.dsWorlds[iShow] = {};
					--ServerSelectPage.dsWorlds[iShow].id = string.format("%03d.",iShow);			local rookie_id=string.find(msg.items[index].name,"%d\-%d");

					ServerSelectPage.dsWorlds[iShow].id = string.format("%03d.",msg.items[index].vid);
					ServerSelectPage.dsWorlds[iShow].seqno = msg.items[index].vid;
					ServerSelectPage.dsWorlds[iShow].ws_id = ws_id;
					ServerSelectPage.dsWorlds[iShow].gs_nid = gs_nid;

					local rookie_id = string.find(msg.items[index].name,"(.*)%(.*%)");
					if (rookie_id) then
						ServerSelectPage.dsWorlds[iShow].text = string.match(msg.items[index].name,"(.*)%(.*%)");
					else
						ServerSelectPage.dsWorlds[iShow].text = msg.items[index].name;
					end

					ServerSelectPage.dsWorlds[iShow].percentage = (100 * msg.items[index].cur) / msg.items[index].max;				
					ServerSelectPage.dsWorlds[iShow].people = msg.items[index].level;
					if(ServerSelectPage.dsWorlds[iShow].percentage >= 100) then
						ServerSelectPage.dsWorlds[iShow].type = "full";
					else
						ServerSelectPage.dsWorlds[iShow].type = "";
					end
					--if(ws_id ~= 1 and ws_id ~= "1") then
						--ServerSelectPage.dsWorlds[iShow].people = -1;
					--end
					IsShow[id] = "yes";

					if(iShow >=  8 ) then
						break;				
					end;
					iShow = iShow + 1;
				end	
			end
			--commonlib.echo("!!:ServerSelectPage.OnInit");
			--commonlib.echo(ServerSelectPage.dsWorlds);
		
			
			-- get all friend world server and game server id, mark the server with type "friend"
			-- NOTE 2009/11/6: only online friend world server and game server ids are fetched through jabber roster message
			--		with the modual "mod_private" enabled on jabber server
			local count = MyCompany.Aries.Friends.GetFriendCountInMemory()
			LOG.std("", "system", "serverselect", "friend count=%d", count);
			local i;
			for i = 1, count do
				local nid = MyCompany.Aries.Friends.GetFriendNIDByIndexInMemory(i)
				local ws_id, gs_nid = MyCompany.Aries.Friends.GetUserGSAndWorldIDInMemory(nid);
				local i;
			
				if(nid == nil) then nid=0 end;
				if(ws_id == nil) then ws_id="0" end;
				if(gs_nid == nil) then gs_nid="0" end;
				LOG.std("", "system", "serverselect", "friend nid=%s,ws_id=%s,gs_nid=%s", tostring(nid), ws_id,gs_nid);
			
				local dsWorlds = ServerSelectPage.dsWorlds;
				local worldname = "";
				local i;
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
			local dsWorlds = ServerSelectPage.dsWorlds;
			local i;
			for i = 1, #(dsWorlds) do
				if(dsWorlds[i].ws_id == ws_id and dsWorlds[i].gs_nid == gs_nid) then
					dsWorlds[i].type = "last";
					break;
				end
			end
		
			-- sort the table according to the id, set the last logged in server to the highest priority
			table.sort(ServerSelectPage.dsWorlds, function(a, b)
				if(a.ws_id == ws_id and a.gs_nid == gs_nid) then
					return true;
				end
				if(b.ws_id == ws_id and b.gs_nid == gs_nid) then
					return false;
				end
				return (a.id < b.id);
			end);

			page:Refresh();
			IsOnInit = true;
		
			-- 2010/5/5 instant login 
			-- if the following file exist the login process will use the username and password in the file to process instant login
			if(ParaIO.DoesFileExist("temp/instant_login/use_2_game_world", true) == true) then
				ServerSelectPage.SwitchWorldServer({
				  gs_nid="1001",
				  id="002.",
				  people=1,
				  percentage=0,
				  seqno=15,
				  text="泡泡广场",
				  type="",
				  ws_id="2" 
				})
			elseif(ParaIO.DoesFileExist("temp/instant_login/use_15_game_world", true) == true) then
				ServerSelectPage.SwitchWorldServer({
				  gs_nid="1002",
				  id="015.",
				  people=1,
				  percentage=0,
				  seqno=15,
				  text="七色丛林",
				  type="",
				  ws_id="2" 
				})
			end
		end, nil, 30000, function()
			-- TODO: some time out handler
			log("error: paraworld.WorldServers.GetRecommend timed out.\n");
		end)

	-- retrieve all servers
		ServerSelectPage.OnViewAllWorld(0, 1000);

	end
end

-- @param world_id_or_name: it can be string of ws_id or text
-- @return the the world server table like {ws_id="16", id="016.", text="M5版测试", people=3, type=""}
function ServerSelectPage.SearchWorldServer(world_id_or_name)
	LOG.std("", "system", "serverselect", "SearchWorldServer: world_id_or_name=%s", world_id_or_name);
	world_id_or_name = string.gsub(world_id_or_name, "^0*", "")
	world_id_or_name = string.gsub(world_id_or_name, "%.$", "")
	--LOG.std("", "system", "serverselect", "result: world_id_or_name=%s\n", world_id_or_name);
	--commonlib.echo(ServerSelectPage.dsWorlds);
	local index, world
	if (rookieYN) then
		for index, world in ipairs(ServerSelectPage.dsRookieWorlds) do 
			LOG.std("", "system", "serverselect", "compare in dsRookieWorlds: index=%s,seqno=%s,text=%s", index,world.seqno,world.text);
			if(world.seqno == tonumber(world_id_or_name) or world.text==world_id_or_name) then
				return world;
			end
		end
	else
		for index, world in ipairs(ServerSelectPage.dsWorlds) do 
			LOG.std("", "system", "serverselect", "compare in dsWorlds: index=%s,seqno=%s,text=%s", index,world.seqno,world.text);
			if(world.seqno == tonumber(world_id_or_name) or world.text==world_id_or_name) then
				return world;
			end
		end
		local index, world
		for index, world in ipairs(ServerSelectPage.dsAllWorlds) do 
			LOG.std("", "system", "serverselect", "compare in dsAllWorlds: index=%s,seqno=%s,text=%s", index,world.seqno,world.text);
			if(world.seqno == tonumber(world_id_or_name) or world.text==world_id_or_name) then
				return world;
			end
		end
	end	
	--search world from db server.
	--LOG.std("", "system", "serverselect", "result: world_id_or_name=%d\n", tonumber(world_id_or_name));
	
	if(type(world_id_or_name) == "string") then
		if(world_id_or_name == "paraengine") then
			world_id_or_name = '(pe)(1)(1010)';
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
			ServerSelectPage.SwitchWorldServer(world);
			return;
		end
	end
	
	if(tonumber(world_id_or_name) == nil) then
		paraworld.WorldServers.GetByName({name=world_id_or_name}, "test", function (msg)
			-- LOG.std("", "system", "serverselect", "recv get by name\n");
			-- commonlib.echo(msg);
			if(not msg.errorcode) then
				local world = {};
				local _;
				_, _, world.ws_id,world.gs_nid = string.find(msg.id,"%((%w+)%)(%w+)");
				world.text = msg.name;
				world.type = "";
				world.id = string.format("%03d.", msg.vid);
				world.percentage = (100*msg.cur)/msg.max;
				ServerSelectPage.SwitchWorldServer(world);
			else
				_guihelper.MessageBox([[<div style="margin-left:30px;margin-top:30px;">该服务器不存在，请重新输入。</div>]])
			end
		end)
	else
		paraworld.WorldServers.GetByVID({vid=tonumber(world_id_or_name)}, "test", function (msg)
			--commonlib.log("recv get by vid\n");
			--commonlib.echo(msg);
			if(not msg.errorcode) then
				local world = {};
				local _;
				_, _, world.ws_id,world.gs_nid = string.find(msg.id,"%((%w+)%)(%w+)");
				world.text = msg.name;
				world.type = "";
				world.id = string.format("%03d.", msg.vid);
				world.percentage = (100*msg.cur)/msg.max;
				ServerSelectPage.SwitchWorldServer(world);
			else
				_guihelper.MessageBox([[<div style="margin-left:30px;margin-top:30px;">该服务器不存在，请重新输入。</div>]])
			end
		end)
	end
end

-- user selected a given world.
function ServerSelectPage.OnSelectWorld(ws_id)
	LOG.std("", "system", "serverselect", "select ws_id=%s", tostring(ws_id));
	local world = ServerSelectPage.SearchWorldServer(ws_id)
	if(world) then
		ServerSelectPage.SwitchWorldServer(world);
	else
		_guihelper.MessageBox([[<div style="margin-left:30px;margin-top:30px;">该服务器不存在，请重新输入。</div>]])
	end
end

-- on click event handler. 
function ServerSelectPage.OnClickSelectWorld()
	local world_name = page:GetValue("world_name");
	-- commonlib.log("begin to do OnClickSelectWorld!world_name=%s\n", world_name);
	if(type(world_name) ~= "string" or world_name=="") then
		_guihelper.MessageBox([[<div style="margin-left:60px;margin-top:30px;">请输入服务器ID或名称</div>]])
	else
		local world = ServerSelectPage.SearchWorldServer(world_name)
		if(world) then
			ServerSelectPage.SwitchWorldServer(world);
		--else
			--_guihelper.MessageBox("您输入的服务器不存在, 请输入服务器ID或名称")
		end
	end
end

-- enter the world server
function ServerSelectPage.SwitchWorldServer(world)
	if(not world) then return end
	local can_enter_world = true;
	if(world.type == "full" or world.percentage>=100) then
		can_enter_world = false;
	end
	NPL.load("(gl)script/apps/Aries/VIP/main.lua");
	local VIP = commonlib.gettable("MyCompany.Aries.VIP");
	if(VIP.IsActivated() and VIP.IsVIP() and world.percentage<=150) then
		LOG.std("", "system", "serverselect", "vip user enter world!");
		can_enter_world = true;
	end
	if(can_enter_world == false) then
			_guihelper.MessageBox("这台服务器太拥挤了, 暂时无法进入, 试试没有满员的服务器吧!")
	else
		LOG.std("", "system", "serverselect", "user selected"..commonlib.serialize(world));
		
		page:CloseWindow();
		
		-- write the world server config for each nid
		MyCompany.Aries.app:WriteConfig(System.App.profiles.ProfileManager.GetNID().."LastLoggedinWorldServer", world);
		
		local from = page:GetRequestParam("from");
		local is_switching_from_game;
		if(from and from=="setting") then
			is_switching_from_game = true;
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
		end
		
		----------------------------
		-- switch game server and authenticate using old account
		----------------------------
		local rest_client = GameServer.rest.client;
		if(rest_client:get_current_server_nid() == world.gs_nid) then
			-- if user selects the same server as we logged in, use it. 
			GotoNextStep();
		else
			Map3DSystem.App.MiniGames.SwfLoadingBarPage.ShowPage({ top = -50 });
			Map3DSystem.App.MiniGames.SwfLoadingBarPage.Update(0.2);
			Map3DSystem.App.MiniGames.SwfLoadingBarPage.UpdateText("正在切换服务器...");
			
			-- if user selects a different game server, diconnect old and connect to the new one and sign in using the same account. 
			GameServer.rest.client:connect({nid=world.gs_nid, world_id=world.ws_id,}, nil, function(msg) 
				if(msg.connected) then
					commonlib.applog(string.format("connection with world server %s is established", world.gs_nid))
					Map3DSystem.App.MiniGames.SwfLoadingBarPage.Update(0.5);
					Map3DSystem.App.MiniGames.SwfLoadingBarPage.UpdateText("连接成功, 正在验证用户身份...");
					if(msg.is_switch_connection) then
						-- authenticate again with the new game server using existing account. 
						paraworld.auth.AuthUser(Map3DSystem.User.last_login_msg or {username = tostring(System.User.username), password = System.User.Password,}, "login", function (msg)
							if(msg==nil) then
								ConnectFail("这台服务器无法认证, 请试试其他服务器");
							elseif(msg.issuccess) then	
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
	end	
end

-- view all
function ServerSelectPage.OnViewAllWorld(pageIndex, pageSize)
	if(pageIndex == nil) then
		pageIndex = 0;
	end
	if(pageSize == nil) then
		pageSize = 10;
	end
	paraworld.WorldServers.Get({pageIndex=pageIndex,pageSize=pageSize}, "RetrieveAllWorldServers", function (msg)

		--commonlib.echo(msg);
		LOG.std(nil, "system", "selectpage", "pages:%s", commonlib.serialize_compact(msg.items));
		ServerSelectPage.dsAllWorlds = {};

		local lastworld = MyCompany.Aries.app:ReadConfig(System.App.profiles.ProfileManager.GetNID().."LastLoggedinWorldServer", {});
		local rookie_ws_seq=1;
		local allrookie_ws_seq = 1;
		--commonlib.echo("======lastworld:");
		--commonlib.echo(lastworld);

		local allRookieWorlds={};
		local tmpLeastpeople,tmpLeastWorld,tmpLastWorld=5,{},{};
		for index, world in ipairs(msg.items) do 
			_, _, ws_id,gs_nid = string.find(msg.items[index].id,"%((%w+)%)(%w+)");
			id = string.format("(%s)%s",ws_id,gs_nid);
			
			ServerSelectPage.dsAllWorlds[index] = {};
			ServerSelectPage.dsAllWorlds[index].id = string.format("%03d.",msg.items[index].vid);
			ServerSelectPage.dsAllWorlds[index].seqno = msg.items[index].vid;
			ServerSelectPage.dsAllWorlds[index].ws_id = ws_id;
			ServerSelectPage.dsAllWorlds[index].gs_nid = gs_nid;

			local worldname;
			-- rookie svr name like "泡泡广场(新手村)"
			local rookie_id = string.find(msg.items[index].name,"(.*)%(.*%)");
			if (rookie_id) then
				if (rookieYN) then
					worldname = string.match(msg.items[index].name,"(%(.*%))");
					ServerSelectPage.dsAllWorlds[index].text = string.match(worldname,"%((.*)%)");
					-- get less than 3 stars worldsvr to rookie svr list
					if (msg.items[index].level <=2 and rookie_ws_seq<=8) then
						local tmpRookie_ws_seq = rookie_ws_seq;
						if (next(lastworld) ~= nil) then
							if (ws_id == lastworld.ws_id and gs_nid == lastworld.gs_nid) then								
								tmpLastWorld.id = string.format("%03d.",msg.items[index].vid);
								tmpLastWorld.seqno = msg.items[index].vid;
								tmpLastWorld.ws_id = ws_id;
								tmpLastWorld.gs_nid = gs_nid;
								tmpLastWorld.text = string.match(worldname,"%((.*)%)");
								tmpLastWorld.percentage = (100 * msg.items[index].cur) / msg.items[index].max;				
								tmpLastWorld.people = msg.items[index].level;
								if(tmpLastWorld.percentage >= 100) then
									tmpLastWorld.type = "full";
								else
									tmpLastWorld.type = "";
								end									;
							end
						end
						--commonlib.echo("======tmpRookie_ws_seq:"..tmpRookie_ws_seq);

						ServerSelectPage.dsRookieWorlds[tmpRookie_ws_seq] = {};
						ServerSelectPage.dsRookieWorlds[tmpRookie_ws_seq].id = string.format("%03d.",msg.items[index].vid);
						ServerSelectPage.dsRookieWorlds[tmpRookie_ws_seq].seqno = msg.items[index].vid;
						ServerSelectPage.dsRookieWorlds[tmpRookie_ws_seq].ws_id = ws_id;
						ServerSelectPage.dsRookieWorlds[tmpRookie_ws_seq].gs_nid = gs_nid;
						ServerSelectPage.dsRookieWorlds[tmpRookie_ws_seq].text = string.match(worldname,"%((.*)%)");
						ServerSelectPage.dsRookieWorlds[tmpRookie_ws_seq].percentage = (100 * msg.items[index].cur) / msg.items[index].max;				
						ServerSelectPage.dsRookieWorlds[tmpRookie_ws_seq].people = msg.items[index].level;
						if(ServerSelectPage.dsRookieWorlds[tmpRookie_ws_seq].percentage >= 100) then
							ServerSelectPage.dsRookieWorlds[tmpRookie_ws_seq].type = "full";
						else
							ServerSelectPage.dsRookieWorlds[tmpRookie_ws_seq].type = "";
						end	
						rookie_ws_seq = rookie_ws_seq + 1;
					-- get other rookie svr (more than 2 stars) to allRookieWorlds
					elseif (msg.items[index].level >2) then
						allRookieWorlds[allrookie_ws_seq] = {};
						allRookieWorlds[allrookie_ws_seq].id = string.format("%03d.",msg.items[index].vid);
						allRookieWorlds[allrookie_ws_seq].seqno = msg.items[index].vid;
						allRookieWorlds[allrookie_ws_seq].ws_id = ws_id;
						allRookieWorlds[allrookie_ws_seq].gs_nid = gs_nid;
						allRookieWorlds[allrookie_ws_seq].text = string.match(worldname,"%((.*)%)");
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
					ServerSelectPage.dsAllWorlds[index].text = string.match(msg.items[index].name,"(.*)%(.*%)");
				end
			else
				-- 如果10级以下用户，上次进入服务器为普通服务器
				local tmpRookie_ws_seq = rookie_ws_seq;
				if (next(lastworld) ~= nil) then
					if (ws_id == lastworld.ws_id and gs_nid == lastworld.gs_nid) then
						tmpLastWorld.id = string.format("%03d.",msg.items[index].vid);
						tmpLastWorld.seqno = msg.items[index].vid;
						tmpLastWorld.ws_id = ws_id;
						tmpLastWorld.gs_nid = gs_nid;
						tmpLastWorld.text = msg.items[index].name;
						tmpLastWorld.percentage = (100 * msg.items[index].cur) / msg.items[index].max;				
						tmpLastWorld.people = msg.items[index].level;
						if(tmpLastWorld.percentage >= 100) then
							tmpLastWorld.type = "full";
						else
							tmpLastWorld.type = "";
						end									
					end
				end
				ServerSelectPage.dsAllWorlds[index].text = msg.items[index].name;
			end
			ServerSelectPage.dsAllWorlds[index].percentage = (100 * msg.items[index].cur) / msg.items[index].max;				
			ServerSelectPage.dsAllWorlds[index].people = msg.items[index].level;
			if(ServerSelectPage.dsAllWorlds[index].percentage >= 100) then
				ServerSelectPage.dsAllWorlds[index].type = "full";
			else
				ServerSelectPage.dsAllWorlds[index].type = "";
			end			
			-- 取普通服务器人数最少的服务器, 并且不是上次登录服务器
			if ((not rookie_id) and (tmpLeastpeople>msg.items[index].level) and (not(ws_id == lastworld.ws_id and gs_nid == lastworld.gs_nid))) then
				tmpLeastpeople = msg.items[index].level;
				tmpLeastWorld = commonlib.deepcopy(ServerSelectPage.dsAllWorlds[index]);
				--commonlib.echo("==========tmpLeastWorld:");
				--commonlib.echo(tmpLeastWorld);
			end

		end
		
		if (rookieYN) then
			if ((next(lastworld)~=nil) and (next(tmpLastWorld)~=nil)) then
				table.insert(ServerSelectPage.dsRookieWorlds,1,tmpLastWorld);
			end

			-- sort allRookieWorlds by people 
			table.sort(allRookieWorlds, function(a, b)
				return (a.people < b.people);
			end);

			-- if rookie svr list not full, append from allRookieWorlds one by one.
			if (rookie_ws_seq<=8) then
				local i,j;
				-- 如果新手村人数都是 5星，则最多补到第9个服务器，剩下一个选普通服务器人数最少的
				if (allrookie_ws_seq > 1) then
					if  (allRookieWorlds[1].people>=5) then
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
						ServerSelectPage.dsRookieWorlds[rookie_ws_seq+i] = commonlib.deepcopy(allRookieWorlds[i+1]);
					end
					-- 如果新手村人数都是 5星，则最多补到第7个服务器，剩下一个选普通服务器人数最少的
					if (allRookieWorlds[1].people>=5) then
						if (next(tmpLeastWorld) ~= nil) then
							ServerSelectPage.dsRookieWorlds[rookie_ws_seq+j] = commonlib.deepcopy(tmpLeastWorld);
						end
					end
				else
					if (next(tmpLeastWorld) ~= nil) then
						ServerSelectPage.dsRookieWorlds[rookie_ws_seq] = commonlib.deepcopy(tmpLeastWorld);
					end
				end
			end
			
			--commonlib.echo("==========dsRookieWorlds:");
			--commonlib.echo(ServerSelectPage.dsRookieWorlds);
			page:Refresh();
			IsOnInit = true;
		end

	end, nil, 30000, function()
		-- TODO: some time out handler
		log("error: paraworld.WorldServers.RetrieveAllWorldServers timed out.\n");
	end)

end