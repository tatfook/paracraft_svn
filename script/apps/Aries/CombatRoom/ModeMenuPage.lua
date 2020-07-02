--[[
Title: 
Author(s): leio
Date: 2012/11/14
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatRoom/ModeMenuPage.lua");
local ModeMenuPage = commonlib.gettable("MyCompany.Aries.CombatRoom.ModeMenuPage");
------------------------------------------------------------
]]
local ModeMenuPage = commonlib.gettable("MyCompany.Aries.CombatRoom.ModeMenuPage");
function ModeMenuPage.ShowPage(worldname,mode_list,candidate_rooms,quest_track_mode_world,selectedCallbackFunc)
	if(not worldname or not mode_list or not candidate_rooms)then
		return
	end
	ModeMenuPage.worldname = worldname;
	ModeMenuPage.mode_list = mode_list;
	ModeMenuPage.native_candidate_rooms = candidate_rooms;
	ModeMenuPage.quest_track_mode_world = quest_track_mode_world;
	ModeMenuPage.selectedCallbackFunc = selectedCallbackFunc;
	local url = "script/apps/Aries/CombatRoom/Teen/ModeMenuPage.teen.html";
	local params = {
			url = url, 
			name = "ModeMenuPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			enable_esc_key = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -400/2,
				y = -300/2,
				width = 400,
				height = 300,
		};
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
	ModeMenuPage.mode_index = 1;
	ModeMenuPage.CheckTrackedQuest();
	ModeMenuPage.DoClick(ModeMenuPage.mode_index);
end
function ModeMenuPage.OnInit()
	ModeMenuPage.page = document:GetPageCtrl();
end
function ModeMenuPage.GetNodeByMode(mode)
    if(mode and ModeMenuPage.worldname and ModeMenuPage.quest_track_mode_world)then
        local k,v;
        for k,v in ipairs(ModeMenuPage.quest_track_mode_world) do
            if(mode == v.mode and ModeMenuPage.worldname == v.worldname_location)then
                return v;         
            end
        end
    end
end
function ModeMenuPage.CheckTrackedQuest()
	if(ModeMenuPage.mode_list and ModeMenuPage.worldname and ModeMenuPage.quest_track_mode_world)then
		local k,v;
        for k,v in ipairs(ModeMenuPage.quest_track_mode_world) do
            if(ModeMenuPage.worldname == v.worldname_location and v.is_tracking)then
				local kk,vv;
				for kk,vv in ipairs(ModeMenuPage.mode_list) do
					if(vv.mode == v.mode)then
						ModeMenuPage.mode_index = kk;
						return
					end
				end
            end
        end
	end
end
function ModeMenuPage.DoCreate(need_broadcast)
	local item = ModeMenuPage.mode_list[ModeMenuPage.mode_index];
	local mode = item.mode;
	ModeMenuPage.NeedBroadcastWhenCreateRoom(need_broadcast);
	if(ModeMenuPage.selectedCallbackFunc)then
		local args = {
			state = "create",
			mode = mode,
			need_broadcast = ModeMenuPage.need_broadcast,
		}
		ModeMenuPage.selectedCallbackFunc(args);
		ModeMenuPage.worldname = nil;
		ModeMenuPage.mode_list = nil;
		ModeMenuPage.native_candidate_rooms = nil;
		ModeMenuPage.quest_track_mode_world = nil;
		ModeMenuPage.selectedCallbackFunc = nil;
	end
end
function ModeMenuPage.DoJoin()
	if(ModeMenuPage.Has_candidate_rooms())then
		local len = #ModeMenuPage.candidate_rooms;
		local index = math.random(1,len);
		local room_index = ModeMenuPage.candidate_rooms[index];
		local args = {
			state = "join",
			room_index = room_index,
		}
		ModeMenuPage.selectedCallbackFunc(args);
		ModeMenuPage.worldname = nil;
		ModeMenuPage.mode_list = nil;
		ModeMenuPage.native_candidate_rooms = nil;
		ModeMenuPage.quest_track_mode_world = nil;
		ModeMenuPage.selectedCallbackFunc = nil;
	end
end
function ModeMenuPage.DoClick(index)
	ModeMenuPage.mode_index = index;
	local item = ModeMenuPage.mode_list[ModeMenuPage.mode_index];
	local mode = item.mode;
	ModeMenuPage.candidate_rooms = {};
	local k,v;

	for k,v in ipairs(ModeMenuPage.native_candidate_rooms) do
		if(v.mode == mode)then
			table.insert(ModeMenuPage.candidate_rooms,k);
		end
	end
	if(ModeMenuPage.page)then
		ModeMenuPage.page:Refresh(0);
	end
end
function ModeMenuPage.Has_candidate_rooms()
	if(ModeMenuPage.candidate_rooms and #ModeMenuPage.candidate_rooms > 0)then
		return true;
	end
end
function ModeMenuPage.DS_Func_Items(index)
	if(not ModeMenuPage.mode_list)then return 0 end
	if(index == nil) then
		return #(ModeMenuPage.mode_list);
	else
		return ModeMenuPage.mode_list[index];
	end
end

function ModeMenuPage.NeedBroadcastWhenCreateRoom(b)
	ModeMenuPage.need_broadcast = b;
end