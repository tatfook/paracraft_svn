--[[
Title: 
Author(s): zrf
Date: 2011/1/12
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/FamilyServer/FamilyServerSet.teen.lua");

------------------------------------------------------------
]]
local FamilyServerSet = commonlib.gettable("MyCompany.Aries.FamilyServer.FamilyServerSet");

NPL.load("(gl)script/apps/Aries/FamilyServer/FamilyServerSelect.teen.lua");
NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local FamilyServerSelect = commonlib.gettable("MyCompany.Aries.FamilyServer.FamilyServerSelect");

--local world_canlogin = {};  
--local world_guest ={};

--function FamilyServerSet.InitWorldZones()
	--if(not FamilyServerSet.zone_inited) then
		--FamilyServerSet.zone_inited = true;
		--NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
		--local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
		--local regionconfig = ExternalUserModule:GetConfig();
		--local world_zones = regionconfig.world_zones;
		--local worldzone, worldtype;
		--for worldzone, worldtype in pairs(world_zones) do 
			--worldzone = tonumber(worldzone);
			--if (worldtype == "u")then
				--table.insert(world_canlogin,worldzone);
			--elseif (worldtype == "g") then
				--table.insert(world_guest,worldzone);
			--end
		--end
	--end
--end

function FamilyServerSet.IsMyWorldZone(zoneid)
	return FamilyServerSelect.IsMyWorldZone(zoneid)
	--FamilyServerSet.InitWorldZones();
	--for index, worldzone in ipairs(world_canlogin) do
		--if (world_canlogin[index]==zoneid) then
			--return true
		--end
	--end
	--return false
end

function FamilyServerSet.OnInit()
	-- System.User.nid

	FamilyServerSet.page = document:GetPageCtrl();

	if(IsOnInit) then
		do return end;
	end

	if(FamilyServerSet.dsAllWorlds == nil)then
		FamilyServerSet.OnViewAllWorld(0, 1000);
	elseif(MyCompany.Aries.Friends.familyworld and FamilyServerSet.familyworldindex==nil)then
		local world = FamilyServerSet.SearchWorldServer(MyCompany.Aries.Friends.familyworld);
		if(world)then
			FamilyServerSet.familyworldindex = world.index;
		end
	end
end

function FamilyServerSet.ShowPage()
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/FamilyServer/FamilyServerSet.teen.html", 
		name = "FamilyServerSet_ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		ToggleShowHide = true, 
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 2,
		enable_esc_key = true,
		directPosition = true,
			align = "_ct",
			x = -470/2,
			y = -470/2,
			width = 470,
			height = 470,
	});
end

function FamilyServerSet.GetFamilyWorldIndex()
	return FamilyServerSet.familyworldindex or -1;
end

function FamilyServerSet.GetSelectText()
	if(FamilyServerSet.familyworldindex)then
		local world = FamilyServerSet.dsAllWorlds[FamilyServerSet.familyworldindex];
		return string.format("%03d.  %s",world.id,world.text);
	else
		return "未选择";
	end
end

function FamilyServerSet.GetLastLoginWorld_text()
	local WorldServerName = commonlib.getfield("MyCompany.Aries.WorldServerName") or "";
	local zonename = FamilyServerSelect.GetZoneName(FamilyServerSelect.GetRecommendBigZone());
	local s="";
	if (WorldServerName) then
		s= zonename .. " - " .. WorldServerName;
	end
	return s
end

function FamilyServerSet.OnClickOK()
	if(FamilyServerSet.familyworldindex==nil or FamilyServerSet.familyworldindex < 1)then
		_guihelper.Custom_MessageBox("请选择一个服务器来作为你的家族服务器!",function(result)
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
	else
		local str = "";
		
		if(MyCompany.Aries.Friends.familyworld and MyCompany.Aries.Friends.familyworld ~= "" )then
			str = "本次更换家族服务器需要消耗99金币，你确定要换吗？";
		else
			local world0 = FamilyServerSet.dsAllWorlds[FamilyServerSet.familyworldindex];
			str = string.format([[首次选定家族服务器免费，后续更换需要消耗金币，你确定"%s"为你的家族服务器吗？]], world0.text);			
		end
		
		_guihelper.Custom_MessageBox( str, function(result)
			
			if(result == _guihelper.DialogResult.Yes)then				
				Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nil, "", function (msg)

					if(msg and msg.users and msg.users[1]) then						
						local user = msg.users[1];
						local family = user.family;

						if(family and family ~="")then
							local msg2 = {idorname = family,}; 						
							paraworld.Family.Get(msg2, "Aries_FamilyServerSet_OnClickOK", function(msg2)

								if(msg2 and not msg2.errorcode)then
									local world = FamilyServerSet.dsAllWorlds[FamilyServerSet.familyworldindex];								
									local msg3 = {
										nid = Map3DSystem.App.profiles.ProfileManager.GetNID(),
										worldid=world.id,
										familyid=msg2.id,
									};
									paraworld.Family.SetFamilyWorld(msg3, "Aries_FamilyServerSet_OnClickOK", function(msg2)
										if(msg2 and not msg2.errorcode)then
											_guihelper.Custom_MessageBox("家族服务器设置成功!",function(result)
												end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
											if(FamilyServerSet.page)then
												FamilyServerSet.page:CloseWindow();
											end

											MyCompany.Aries.Friends.familyworld = world.id;
											FamilyServerSelect.familyworldname = world.text;
											FamilyServerSet.familyworldindex = nil;
											ItemManager.GetItemsInBag(0, "FamilyServerSet_OnClickOK", function()
											end, "access plus 0 day");

											Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nil, "", function (msg)
											end, "access plus 0 day");
										elseif(msg2 and msg2.errorcode and msg2.errorcode == 427)then
											if(FamilyServerSet.page)then
												FamilyServerSet.page:CloseWindow();
											end
											_guihelper.Custom_MessageBox("金币不足,无法更换家族服务器!",function(result)
												end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
											
										end							
									end);								
								end
							end);
						else
							_guihelper.Custom_MessageBox("你还没有家族,不能设置家族服务器哦!",function(result)
								end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
						end
					end
				end);

			end
		end,_guihelper.MessageBoxButtons.YesNo);	
	end
end

function FamilyServerSet.OnClickServer(index)
	index = tonumber(index);
	FamilyServerSet.familyworldindex = index;
	if(FamilyServerSet.page)then
		FamilyServerSet.page:Refresh(0);
	end
end

-- view all
function FamilyServerSet.OnViewAllWorld(pageIndex, pageSize)
	if(pageIndex == nil) then
		pageIndex = 0;
	end
	if(pageSize == nil) then
		pageSize = 10;
	end

	paraworld.WorldServers.GetAllFamily({}, "RetrieveAllWorldServers", function (msg)
		LOG.std(nil, "system", "selectpage", "pages:%s", commonlib.serialize_compact(msg.items));
		FamilyServerSet.dsAllWorlds = {};
		local idx = 1;
		local id,zoneid;
		for index, world in ipairs(msg.items) do 
			
			_, _, ws_id,gs_nid = string.find(msg.items[index].id,"%((%w+)%)(%w+)");
			id = string.format("(%s)%s",ws_id,gs_nid);
			zoneid = tonumber(msg.items[index].zoning);

			if (FamilyServerSet.IsMyWorldZone(zoneid) and (FamilyServerSelect.GetRecommendBigZone()==zoneid)) then  -- 只列出本区的家族服务器
				local worldname = string.match(msg.items[index].name,"(.*)%(.*%)");
				if ( not worldname ) then
					worldname = msg.items[index].name;
				end
				FamilyServerSet.dsAllWorlds[idx] = {};
				FamilyServerSet.dsAllWorlds[idx].id = string.format("%03d.",msg.items[index].vid);
				FamilyServerSet.dsAllWorlds[idx].index = idx;
				FamilyServerSet.dsAllWorlds[idx].seqno = msg.items[index].vid;
				FamilyServerSet.dsAllWorlds[idx].ws_id = ws_id;
				FamilyServerSet.dsAllWorlds[idx].gs_nid = gs_nid;
				FamilyServerSet.dsAllWorlds[idx].text = worldname;
				FamilyServerSet.dsAllWorlds[idx].percentage = (100 * msg.items[index].cur) / msg.items[index].max;				
				FamilyServerSet.dsAllWorlds[idx].people = msg.items[index].level;
				if(FamilyServerSet.dsAllWorlds[idx].percentage >= 100) then
					FamilyServerSet.dsAllWorlds[idx].type = "full";
				else
					FamilyServerSet.dsAllWorlds[idx].type = "";
				end

				idx = idx + 1;
			end -- if (FamilyServerSet.IsMyWorldZone(zoneid))
		end
		if(FamilyServerSet.page)then
			FamilyServerSet.page:Refresh(0.1);
		end
	end)
end


-- @param world_id_or_name: it can be string of ws_id or text
-- @return the the world server table like {ws_id="16", id="016.", text="M5版测试", people=3, type=""}
function FamilyServerSet.SearchWorldServer(world_id_or_name)
	LOG.std("", "system", "serverselect", "SearchWorldServer: world_id_or_name=%s", world_id_or_name);
	world_id_or_name = string.gsub(world_id_or_name, "^0*", "")
	world_id_or_name = string.gsub(world_id_or_name, "%.$", "")
	local index, world
	for index, world in ipairs(FamilyServerSet.dsAllWorlds) do 
		LOG.std("", "system", "serverselect", "compare in dsAllWorlds: index=%s,seqno=%s,text=%s", index,world.seqno,world.text);
		if(world.seqno == tonumber(world_id_or_name) or world.text==world_id_or_name) then
			return world;
		end
	end
end

function FamilyServerSet.DS_Func(index)
	if(index == nil) then
		if(FamilyServerSet.dsAllWorlds)then
			return #(FamilyServerSet.dsAllWorlds);
		end	
	else
		return FamilyServerSet.dsAllWorlds[index];
	end
end