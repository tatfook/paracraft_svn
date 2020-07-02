--[[
Title: 
Author(s): zhangruofei
Date: 2010/09/19
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/MoodPerDay.lua");
MyCompany.Aries.Quest.MoodPerDay.ShowMainWnd();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel8.lua");
NPL.load("(gl)script/apps/Aries/Quest/DailyWish.lua");
local MoodPerDay = commonlib.gettable("MyCompany.Aries.Quest.MoodPerDay");
 
 
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local Quest = MyCompany.Aries.Quest;

function MoodPerDay.ShowMainWnd()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	
	MoodPerDay.bIsDialy = false;
	MoodPerDay.select = 1;

    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Quest/MoodPerDay.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "MoodPerDay.ShowMainWnd", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
		enable_esc_key = true,
        directPosition = true,
            align = "_ct",
            x = -960/2,
            y = -560/2,
            width = 960,
            height = 560,
    });
end
 
function MoodPerDay.GrowupSort()
	MoodPerDay.showgrowup= {};

	local i;
	local tmp;
	for i=1, #(MoodPerDay.GrowupData) do
		tmp = MoodPerDay.GrowupData[i];

		if(tmp.state == 2)then
			tmp.oldindex = i;
			table.insert(MoodPerDay.showgrowup,tmp);
		end
	end

	for i=1, #(MoodPerDay.GrowupData) do
		tmp = MoodPerDay.GrowupData[i];

		if(tmp.state == 1)then
			tmp.oldindex = i;
			table.insert(MoodPerDay.showgrowup,tmp);
		end
	end

	for i=1, #(MoodPerDay.GrowupData) do
		tmp = MoodPerDay.GrowupData[i];

		if(tmp.state == 4)then
			tmp.oldindex = i;
			table.insert(MoodPerDay.showgrowup,tmp);
		end
	end

	for i=1, #(MoodPerDay.GrowupData) do
		tmp = MoodPerDay.GrowupData[i];

		if(tmp.state == 3)then
			tmp.oldindex = i;
			table.insert(MoodPerDay.showgrowup,tmp);
		end
	end
end

function MoodPerDay.SaveMood()
	local gsid = 50315;
	local bag = 30011;
	local scene = commonlib.gettable("MyCompany.Aries.Scene");
	ItemManager.GetItemsInBag(bag, "50315_DailyWishQuest", function(msg)
		local hasitem, guid = hasGSItem(gsid);
		if(hasitem)then
			local item = ItemManager.GetItemByGUID(guid);
			if(item)then
				local info = MoodPerDay.mood or "";
				local clientdata = commonlib.serialize_compact2(info);
				ItemManager.SetClientData( guid, clientdata, function(msg_setclientdata)
					
				end);
			end
		end
	end, "access plus 1 minutes");
end

function MoodPerDay.CreateQuest(type)
	local level = MyCompany.Aries.Player.GetDragonLevel();
	
	local index;
	local i=0;
	while true do
		index = math.random(1, #(MoodPerDay.MoodData[type]) );

		if( ( ( level < 5 and MoodPerDay.MoodData[type][index].level == -5 ) or
			level >= 5 or MoodPerDay.MoodData[type][index].level == -9999 ) and
			MoodPerDay.CanAcquireQuest(type,index) )then
			break;
		end

		i = i + 1;
		if( i >= 100)then
			return -1;
		end
	end

	return index;
end

function MoodPerDay.CleanMood()
	if( MoodPerDay.mood )then
		if(not MoodPerDay.MoodData)then return; end
		local _, mood;
		local data;
		local bhas, guid;

		for _,mood in ipairs(MoodPerDay.mood) do
			data = MoodPerDay.MoodData[mood.questtype][mood.questindex];
			
			bhas, guid = hasGSItem(data.rewards_gsid);

			if(bhas)then
				ItemManager.DestroyItem(guid, 1, function() end);
			end
		end
	end

	MoodPerDay.mood= {};
end
 
function MoodPerDay.NewQuest()
	MoodPerDay.CleanMood();

	local i;
	for i = 1, 5 do
		local questindex = MoodPerDay.CreateQuest(i);
		if(questindex~=-1)then
			local quest = { state=2,getgift=false,completed=false,questtype=i,questindex=questindex, };
			table.insert(MoodPerDay.mood,quest);
		end
	end
	for i = 1,5 do
		MoodPerDay.AcquireQuest(i);
	end
	local scene = commonlib.gettable("MyCompany.Aries.Scene");
	MoodPerDay.mood.date = scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	MoodPerDay.SaveMood();
	MoodPerDay.select = 1;
end

function MoodPerDay.LoadMood()
	local gsid = 50315;
	local bag = 30011;
	local scene = commonlib.gettable("MyCompany.Aries.Scene");

	ItemManager.GetItemsInBag(bag, "50315_DailyWishQuest", function(msg)
		local hasitem, guid = hasGSItem(gsid);

		if(hasitem)then
			local item = ItemManager.GetItemByGUID(guid);
			if(item)then

				local clientdata = item.clientdata;
				if( clientdata=="")then
					clientdata="{}";
				end
				clientdata = commonlib.LoadTableFromString(clientdata);

				if( clientdata and type(clientdata)=="table")then
					local date = clientdata.date;
					local today = scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");

					MoodPerDay.mood = clientdata;
					if(not(date and today==date))then
						MoodPerDay.NewQuest();
					else
						local i;
						for i = 1,#(MoodPerDay.mood) do
							MoodPerDay.RefreshStatus(i);
						end
					end 
					if(MoodPerDay.pagectrl)then
						MoodPerDay.pagectrl:Refresh(0.01);
					end
				end
			end
		end
	end, "access plus 20 minutes");
end

function MoodPerDay.LoadGrowupData()
	local DailyWish= commonlib.gettable("MyCompany.Aries.Quest.DailyWish");
	MoodPerDay.GrowupData = DailyWish.GetGrowData();
end

function MoodPerDay.GetGrowupTooltip(index)
	if(not index)then return; end
	if(not MoodPerDay.GrowupData or not MoodPerDay.showgrowup)then return; end
	index = tonumber(index);
	local idx = MoodPerDay.showgrowup[index].oldindex;
	local data = MoodPerDay.GrowupData[idx];
	local acquire_gsid = data.acquire_gsid;
	local finish_gsid = data.finish_gsid;
	local need_gsid = data.need_gsid;
	return "抱抱龙等级:" .. data.level .. "级";
end

function MoodPerDay.GetStateIconGrowup(index)
	if(not index)then return; end
	return "Texture/Aries/Quest/MoodPerDay/icon" .. index .. "_32bits.png; 0 0 35 36";
end

function MoodPerDay.DS_Func_Growup(index)
	if(not MoodPerDay.showgrowup)then return; end

	if(index == nil)then
		return #MoodPerDay.showgrowup;
	else
		return MoodPerDay.showgrowup[index];
	end
end

function MoodPerDay.GetGrowupMore()
	if(not MoodPerDay.GrowupData or not MoodPerDay.showgrowup)then return; end
	local idx = MoodPerDay.showgrowup[MoodPerDay.select].oldindex;
	local data = MoodPerDay.GrowupData[idx];
	local acquire_gsid = data.acquire_gsid;
	local finish_gsid = data.finish_gsid;
	local need_gsid = data.need_gsid;
	local has_gsid = data.has_gsid;
	local url = "";

	if(data.level == 8 or data.level == 9)then
		local a = not hasGSItem(data.acquire_gsid);
		local b = not hasGSItem(data.finish_gsid);
		local c = not hasGSItem(data.need_gsid);

		if(not a and b and c)then
			url = data.status_url2;
		elseif(not a and b and not c)then
			url = data.status_url;
		else
			url = data.status_url2;
		end
	else
		url = data.status_url;
	end

	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = url, 
        app_key = MyCompany.Aries.app.app_key, 
        name = "MoodPerDay.GetGrowupMore", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -820/2,
            y = -512/2,
            width = 820,
            height = 512,
    });
end

function MoodPerDay.Acquire(index)
	if(not MoodPerDay.GrowupData or not MoodPerDay.showgrowup)then return; end
	index = tonumber(index);
	local idx = MoodPerDay.showgrowup[index].oldindex;
	local data = MoodPerDay.GrowupData[idx];
	local acquire_gsid = data.acquire_gsid;
	local finish_gsid = data.finish_gsid;
	local need_gsid = data.need_gsid;

	ItemManager.PurchaseItem(acquire_gsid, 1, function(msg) end, function(msg)
		if(msg and msg.issuccess) then
			MoodPerDay.RefreshGrowup(idx);
		end
	end);
end

function MoodPerDay.RefreshGrowup(index,needrefresh)
	if(not MoodPerDay.GrowupData)then return; end
	index = tonumber(index);
	local data = MoodPerDay.GrowupData[index];
	local acquire_gsid = data.acquire_gsid;
	local finish_gsid = data.finish_gsid;
	local need_gsid = data.need_gsid;
	local bean = MyCompany.Aries.Pet.GetBean();
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	local level = MyCompany.Aries.Player.GetDragonLevel();

	if(data.rewards_gsid and hasGSItem(data.rewards_gsid))then
		data.getgift = false;
	else
		data.getgift = true;
	end

	data.completed = false;
	if(level < data.level)then
		data.state = 4;
	elseif(data.level == 8)then
		local a = not hasGSItem(data.acquire_gsid);
		local b = not hasGSItem(data.finish_gsid);
		local c = not hasGSItem(data.need_gsid);

		if(a and b)then
			data.state = 1;
		elseif(not a and b and c)then
			MoodPerDay.RegisterGrowup(index);
			data.state = 2;
		elseif(not a and b and not c)then
			MoodPerDay.RegisterGrowup(index);
			-- create the hearts if not created in haqi town only
			local current_worlddir = ParaWorld.GetWorldDirectory();
			if(current_worlddir == "worlds/MyWorlds/61HaqiTown/") then
				MyCompany.Aries.Quest.NPCs.WishLevel8.CreateHeartNPCs();
			end
			data.state = 2;
		elseif(not a and not b)then
			MoodPerDay.UnRegisterGrowup(index);
			MyCompany.Aries.Quest.NPCs.WishLevel8.DeleteHeartNPCs();
			
			data.completed = true;
			if(data.getgift)then
				data.state = 3;
			else
				data.state = 2;
			end
		else
			data.state = 4;
		end
	elseif(data.level == 9)then
		local a = not hasGSItem(data.acquire_gsid);
		local b = not hasGSItem(data.finish_gsid);
		local c = not hasGSItem(data.need_gsid);

		if(a and b)then
			data.state = 1;
		elseif(not a and b and c)then
			MoodPerDay.RegisterGrowup(index);
			data.state = 2;
		elseif(not a and b and not c)then
			MoodPerDay.RegisterGrowup(index);
			data.state = 2;
		elseif(not a and not b)then
			MoodPerDay.UnRegisterGrowup(index);
			data.completed = true;
			if(data.getgift)then
				data.state = 3;
			else
				data.state = 2;
			end
		else
			data.state = 4;
		end
	else
		
		local c;
		if(data.need_gsid)then
			c = hasGSItem(data.need_gsid);
		else
			c = true;
		end

		local a = not hasGSItem(data.acquire_gsid);
		local b = not hasGSItem(data.finish_gsid);

		if( a and b and c)then
			data.state = 1;
		elseif(not a and b)then
			MoodPerDay.RegisterGrowup(index);
			data.state = 2;
		elseif(not a and not b)then
		
			MoodPerDay.UnRegisterGrowup(index);
			data.completed = true;
			if(data.getgift)then
				data.state = 3;
			else
				data.state = 2;
			end
		else
			data.state = 4;
		end
	end

	if(needrefresh == nil)then
		needrefresh = true;
	end

	MoodPerDay.GrowupSort();
	if(needrefresh)then
		if(MoodPerDay.pagectrl)then
			MoodPerDay.pagectrl:Refresh(0.01);
		end
	end
end

function MoodPerDay.CompleteGrowup1(index,msg)
	if(not MoodPerDay.GrowupData)then return; end
	index = tonumber(index);
	local data = MoodPerDay.GrowupData[index];
	local acquire_gsid = data.acquire_gsid;
	local finish_gsid = data.finish_gsid;
	local need_gsid = data.need_gsid;

	if(hasGSItem(acquire_gsid))then
		if(data.exid)then
	
			ItemManager.ExtendedCost(data.exid, nil, nil, function(msg)end, function(msg)

				if(msg and msg.issuccess == true)then
					MoodPerDay.RefreshGrowup(index);
					MyCompany.Aries.Desktop.QuestArea.FlashQuestDragonIcon();
				end
			end);
		else
			local i;
			for i = index, #(MoodPerDay.GrowupData) do
				MoodPerDay.RefreshGrowup(i);
			end
			MoodPerDay.CalcShowCount();
			MyCompany.Aries.Desktop.QuestArea.FlashQuestDragonIcon();
		end
	end
end

function MoodPerDay.GetResultGrowup()
	if( not MoodPerDay.GrowupData)then return; end
	local data = MoodPerDay.GrowupData[MoodPerDay.select];
	if(data)then
		return data.rewards_desc;
	end
end

function MoodPerDay.UnRegisterGrowup(index)
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "GrowupRec_" .. index, 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end

function MoodPerDay.RegisterGrowup(index)
	if(not MoodPerDay.GrowupData)then return; end
	index = tonumber(index);
	local data = MoodPerDay.GrowupData[index];
	local acquire_gsid = data.acquire_gsid;
	local finish_gsid = data.finish_gsid;
	local need_gsid = data.need_gsid;
	local has_gsid = data.has_gsid;

	local aries_types = {};
	local aries_type;
	for aries_type in string.gfind(data.aries_type, "([%w_]+),") do 
		if(aries_type and aries_type~="")then
			table.insert(aries_types,aries_type);
		end
	end
	-- map of all aries_types that we are interested in, we will only continue processing when type exceed. 
	local hooked_aries_types = {};
	local aries_type;
	for aries_type in string.gfind(data.aries_type, "([%w_]+),") do 
		hooked_aries_types[aries_type] = true;
	end

	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(not hooked_aries_types[msg.aries_type or ""]) then
				return nCode;
			end
			if( not has_gsid or (has_gsid == msg.gsid) )then
				local _, i;
				local has, guid;
				local clientdata = "";
				local flag;
				local flags = {};
				if((#aries_types) > 1 )then
					has, guid = hasGSItem(data.acquire_gsid);
					if(has)then
						local item = ItemManager.GetItemByGUID(guid);
						if(item)then
							clientdata = item.clientdata;
							if(clientdata~="")then
								for flag in string.gfind(clientdata, "([%w_]+)," ) do
									if( flag and flag~="")then
										table.insert(flags,flag);
									end
								end
							end
						end
					end
				end

				local tick = 0;
				for _,i in ipairs(aries_types) do
					local j;
					local b = false;
					tick = tick + 1;
					for i = 1, #flags do
						if(flags[i] == tick)then
							b = true;
							break;
						end
					end
					if( not b and msg.aries_type == i )then
						if((#aries_types) > 1 )then
							clientdata = clientdata .. tick .. ",";
							ItemManager.SetClientData(guid, clientdata, function(msg_setclientdata)
										end, nil, nil, nil, true);
						end

						if( (#aries_types) <= ( #flags + 1 ) )then
							MoodPerDay.CompleteGrowup1(index,msg);
						end
						break;
					end
				end
			end

			return nCode;
		end, 
		hookName = "GrowupRec_" .. index, appName = "Aries", wndName = "main"});
end

function MoodPerDay.ShowAcceptGrowup()
	if(not MoodPerDay.GrowupData or not MoodPerDay.showgrowup)then return; end
	local idx = MoodPerDay.showgrowup[MoodPerDay.select].oldindex;
	local data = MoodPerDay.GrowupData[idx];
	return data.state == 1;
end

function MoodPerDay.ShowGiftGrowup()
	if(not MoodPerDay.GrowupData or not MoodPerDay.showgrowup)then return; end
	local idx = MoodPerDay.showgrowup[MoodPerDay.select].oldindex;
	local data = MoodPerDay.GrowupData[idx];
	return data.state == 2 and not data.getgift and data.completed;
end

function MoodPerDay.GetGiftGrowup()
	if(not MoodPerDay.GrowupData or not MoodPerDay.showgrowup)then return; end
	local idx = MoodPerDay.showgrowup[MoodPerDay.select].oldindex;
	local data = MoodPerDay.GrowupData[idx];
	local acquire_gsid = data.acquire_gsid;
	local finish_gsid = data.finish_gsid;
	local need_gsid = data.need_gsid;
	local has_gsid = data.has_gsid;

    local bHas, guid, _, copy = hasGSItem(data.rewards_gsid);
    if(bHas and guid) then
	
        local item = ItemManager.GetItemByGUID(guid);
	    if(item and item.guid > 0) then
            item:OnClick("left", function()
				MoodPerDay.RefreshGrowup(MoodPerDay.select);
			end);
	    end
    end
end

function MoodPerDay.AcceptGrowup()
	MoodPerDay.Acquire(MoodPerDay.select);
end

function MoodPerDay.GetDescGrowup()
	if(not MoodPerDay.GrowupData or not MoodPerDay.showgrowup)then return; end
	local idx = MoodPerDay.showgrowup[MoodPerDay.select].oldindex;
	local data = MoodPerDay.GrowupData[idx];
	return data.begin_desc;
end

function MoodPerDay.CalcShowCount()
	MoodPerDay.ShowCount = 0;
	for i = 1,#(MoodPerDay.GrowupData) do
		if(MoodPerDay.GrowupData[i].state == 2)then
			MoodPerDay.ShowCount = MoodPerDay.ShowCount + 1;
		end
	end
	MyCompany.Aries.Desktop.QuestArea.ShowDragonCount(MoodPerDay.ShowCount);
end

function MoodPerDay.Init()
	if(document)then
		MoodPerDay.pagectrl = document:GetPageCtrl();
	end
	MoodPerDay.select = MoodPerDay.select or 1;

	if(not MoodPerDay.MoodData)then
		local DailyWish= commonlib.gettable("MyCompany.Aries.Quest.DailyWish");
		MoodPerDay.MoodData = DailyWish.GetData();
	end
	if(not MoodPerDay.GrowupData)then
		MoodPerDay.LoadGrowupData();
	end

	for i = 1,#(MoodPerDay.GrowupData) do
		MoodPerDay.RefreshGrowup(i,false);
	end

	MoodPerDay.CalcShowCount();
	 
	if(not MoodPerDay.mood)then
		MoodPerDay.LoadMood();
	end
end

function MoodPerDay.DS_Func(index)
	if(not MoodPerDay.mood)then return; end

	if(index == nil)then
		return #MoodPerDay.mood;
	else

		local tmp= MoodPerDay.mood[index];
		if(tmp)then
			return MoodPerDay.MoodData[tmp.questtype][tmp.questindex];
		end
	end
end

function MoodPerDay.onClick(index)
	MoodPerDay.select = index;
	if(MoodPerDay.pagectrl)then
		MoodPerDay.pagectrl:Refresh(0.01);
	end
end

function MoodPerDay.ShowSelect(index)
	return tonumber(index)==MoodPerDay.select;
end

function MoodPerDay.GetStateIcon(index)
	if(not MoodPerDay.mood)then return; end
	local tmp= MoodPerDay.mood[tonumber(index)];
	if(tmp)then
		return "Texture/Aries/Quest/MoodPerDay/icon" .. tmp.state .. "_32bits.png; 0 0 35 36";
	end
end

function MoodPerDay.GetDesc()
	if(not MoodPerDay.mood)then return; end
	local mood = MoodPerDay.mood[MoodPerDay.select];
	if(mood)then
		local data = MoodPerDay.MoodData[mood.questtype][mood.questindex];
		if(mood.state==3)then
			return data.finish_desc;
		else
			return data.begin_desc;
		end
	end
end

function MoodPerDay.GetResult()
	if( not MoodPerDay.mood)then return; end
	local mood = MoodPerDay.mood[MoodPerDay.select];
	if(mood)then
		local data = MoodPerDay.MoodData[mood.questtype][mood.questindex];
		return data.rewards_desc;
	end
end

function MoodPerDay.CanAcquireQuest(type,dataindex)
	type = tonumber(type);
	dataindex = tonumber(dataindex);

	local quest = MoodPerDay.MoodData[type][dataindex];
	local acquire_gsid = quest.acquire_gsid;
	local has_gsid = quest.has_gsid;
	local status_pg = quest.status_pg;

	local isnot = true;
	if(has_gsid)then
		has_gsid = tonumber(has_gsid);
		
		if(has_gsid<0)then
			isnot = false;
			has_gsid = has_gsid * -1;
		end
	end

	local a = not hasGSItem(acquire_gsid);
	local b;

	if(type == 1 or type == 2 or type == 4 or type == 5 )then
		-- 贪吃洗做 玩游戏 热心

		if(a)then
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(acquire_gsid);
			local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(acquire_gsid);

			if( gsItem and gsObtain )then
				local count = (gsItem.maxdailycount or 1000) - (gsObtain.inday or 0);
				if( count > 0 )then
					return true;
				end
			else
				return true;
			end
		else
			return true;
		end

		return false;
	elseif(type == 3)then
		--宠物系列
		if(isnot)then
			b = not hasGSItem(has_gsid);
		else
			b = hasGSItem(has_gsid);
		end

		if(b)then
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(acquire_gsid);
			local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(acquire_gsid);

			if( gsItem and gsObtain )then
				local count = (gsItem.maxdailycount or 1000) - (gsObtain.inday or 0);
				if( count > 0 )then
					return true;
				end
			else
				return true;
			end
		end

		return false;
	else

		if(not has_gsid)then
			b = true;
		elseif(isnot)then
			b = not hasGSItem(has_gsid);
		else
			b = hasGSItem(has_gsid);
		end

		if( a and b )then
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(acquire_gsid);
			local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(acquire_gsid);
			if(gsItem and gsObtain) then
				local remainingDailyCount = (gsItem.maxdailycount or 1000) - (gsObtain.inday or 0);
				if(remainingDailyCount > 0) then
					return true;
				end
			else
				return true;
			end
		end

	end
end

function MoodPerDay.Complete(dialyindex)
	dialyindex = tonumber(dialyindex);
	local mood = MoodPerDay.mood[dialyindex];
	local quest = MoodPerDay.MoodData[mood.questtype][mood.questindex];
	local acquire_gsid = quest.acquire_gsid;
	local has_gsid = quest.has_gsid;
	local status_pg = quest.status_pg;
	local bhas, guid = hasGSItem(quest.acquire_gsid);

	if(bhas)then
		ItemManager.ExtendedCost(quest.exid, nil, nil, function(msg)
			local exid = quest.exid;
			local name = "";
			local template = ItemManager.GetExtendedCostTemplateInMemory(exid);
			if(template)then
				name = template.exname or "";
			end
			if(msg.issuccess == true)then
				MoodPerDay.RefreshStatus(dialyindex);
				MyCompany.Aries.Desktop.QuestArea.FlashQuestDragonIcon();
				MoodPerDay.SaveMood();
			end
		end);
	end
end

function MoodPerDay.RegisterHook(dialyindex)
	dialyindex = tonumber(dialyindex);
	local mood = MoodPerDay.mood[dialyindex];
	local quest = MoodPerDay.MoodData[mood.questtype][mood.questindex];
	local acquire_gsid = quest.acquire_gsid;
	local has_gsid = quest.has_gsid;
	local status_pg = quest.status_pg;
	local rewards_gsid = quest.rewards_gsid;

	local aries_types = {};
	local aries_type;
	for aries_type in string.gfind(quest.aries_type, "([%w_]+),") do 
		if(aries_type and aries_type~="")then
			table.insert(aries_types,aries_type);
		end
	end

	-- map of all aries_types that we are interested in, we will only continue processing when type exceed. 
	local hooked_aries_types = {};
	local aries_type;
	for aries_type in string.gfind(quest.aries_type, "([%w_]+),") do 
		hooked_aries_types[aries_type] = true;
	end

	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(not hooked_aries_types[msg.aries_type or ""]) then
				return nCode;
			end
			if( ( msg.score and msg.score > 0 ) or
				( has_gsid and has_gsid > 0 and has_gsid == msg.gsid ) or
				( msg.nid and msg.nid ~= System.App.profiles.ProfileManager.GetNID() ) or
				( not msg.score and not(has_gsid and has_gsid > 0) and not msg.nid ) )then

				local _, i;
				for _,i in ipairs(aries_types) do
					if( msg.aries_type == i)then
						MoodPerDay.Complete(dialyindex);

						if(MoodPerDay.pagectrl)then
							MoodPerDay.pagectrl:Refresh(0.01);
						end
						break;
					end
				end
			end
			return nCode;
		end, 
		hookName = "MoodPerDay_" .. dialyindex, appName = "Aries", wndName = "main"});
end

function MoodPerDay.UnregisterHook(dialyindex)
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "MoodPerDay_" .. dialyindex, 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end

function MoodPerDay.IsDialy()
	return MoodPerDay.bIsDialy;
end

function MoodPerDay.AcquireQuest(dialyindex)
	dialyindex = tonumber(dialyindex);
	local mood = MoodPerDay.mood[dialyindex];
	local quest = MoodPerDay.MoodData[mood.questtype][mood.questindex];
	local acquire_gsid = quest.acquire_gsid;
	local has_gsid = quest.has_gsid;
	local status_pg = quest.status_pg;

	if(hasGSItem(acquire_gsid))then
		MoodPerDay.RefreshStatus(dialyindex);
		if(MoodPerDay.pagectrl)then
			MoodPerDay.pagectrl:Refresh(0.01);
		end
	else
		ItemManager.PurchaseItem(acquire_gsid, 1, function(msg) end, function(msg)
			if(msg)then
				if(msg.issuccess == true and status_pg )then
					MoodPerDay.RefreshStatus(dialyindex);
					MoodPerDay.SaveMood();
					if(MoodPerDay.pagectrl)then
						MoodPerDay.pagectrl:Refresh(0.01);
					end
				end
			end
		end);
	end
end

function MoodPerDay.RefreshStatus(dialyindex)
	dialyindex = tonumber(dialyindex);
	local mood = MoodPerDay.mood[dialyindex];
	local quest = MoodPerDay.MoodData[mood.questtype][mood.questindex];
	local acquire_gsid = quest.acquire_gsid;
	local has_gsid = quest.has_gsid;
	local status_pg = quest.status_pg;
	local rewards_gsid = quest.rewards_gsid;

	if( not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie() )then 
		_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		return; 
	end

	local QuestArea = MyCompany.Aries.Desktop.QuestArea;

	local bHas, guid = hasGSItem(acquire_gsid);
	mood.completed = false;

	if(mood.questtype == 1)then	--贪吃洗做
		
		if(bHas)then
			mood.state = 2;
			MoodPerDay.RegisterHook(dialyindex);
		else
			MoodPerDay.UnregisterHook(dialyindex);
			mood.completed = true;


			if( rewards_gsid and hasGSItem(rewards_gsid) )then
				mood.getgift = false;
				mood.state = 2;
			else
				mood.state = 3;
				mood.getgift = true;
			end
		end
	elseif(mood.questtype == 3)then		-- 宠物
		if(bHas)then
			if(has_gsid and hasGSItem(has_gsid))then
				
				if(guid)then
					ItemManager.DestroyItem(guid, 1, function(msg) end, function(msg)
						MoodPerDay.RefreshStatus(dialyindex);
					end);
				end
			else
				
			end
			mood.state = 2;
			MoodPerDay.RegisterHook(dialyindex);
		else
			MoodPerDay.UnregisterHook(dialyindex);
			mood.completed = true;


			if( rewards_gsid and hasGSItem(rewards_gsid) )then
				mood.getgift = false;
				mood.state = 2;
			else
				mood.state = 3;
				mood.getgift = true;
			end
		end
	elseif(mood.questtype == 5)then

		if(bHas)then
			MoodPerDay.RegisterHook(dialyindex);
			mood.state = 2;
		else

			MoodPerDay.UnregisterHook(dialyindex);
			mood.completed = true;

			if( rewards_gsid and hasGSItem(rewards_gsid) )then
				mood.getgift = false;
				mood.state = 2;
			else
				mood.state = 3;
				mood.getgift = true;
			end
		end
	else

		if(bHas)then

			if(has_gsid)then
				if(hasGSItem(has_gsid))then

					ItemManager.DestroyItem(guid, 1, function(msg) end, function(msg)
						
						MoodPerDay.RefreshStatus(dialyindex);
					end);
				end
			end 

			MoodPerDay.RegisterHook(dialyindex);
			mood.state = 2;
		else

			MoodPerDay.UnregisterHook(dialyindex);
			mood.completed = true;


			if( rewards_gsid and hasGSItem(rewards_gsid) )then
				mood.getgift = false;
				mood.state = 2;
			else
				mood.state = 3;
				mood.getgift = true;
			end
		end
	end
end

function MoodPerDay.onDialyPageClick()
	if(not MoodPerDay.bIsDialy)then
		MoodPerDay.select = 1;
		MoodPerDay.bIsDialy = true;
		if(MoodPerDay.pagectrl)then
			MoodPerDay.pagectrl:Refresh(0.01);
		end
	end
end

function MoodPerDay.onGrowPageClick()
	if(MoodPerDay.bIsDialy)then
		MoodPerDay.select = 1;
		MoodPerDay.bIsDialy = false;
		if(MoodPerDay.pagectrl)then
			MoodPerDay.pagectrl:Refresh(0.01);
		end
	end
end

function MoodPerDay.ShowAccept()
	if(not MoodPerDay.mood)then return; end
	local mood = MoodPerDay.mood[MoodPerDay.select];
	return mood.state == 1 and MoodPerDay.CanAcquireQuest(MoodPerDay.select);
end

function MoodPerDay.SendFeedMsg(gsid,type,count)
	count = count or 0;
	local msg = { aries_type = type, gsid = gsid, wndName = "main", count = count,};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
end

function MoodPerDay.ShowGift()
	if(not MoodPerDay.mood)then return; end
	local mood = MoodPerDay.mood[MoodPerDay.select];
	return mood.state == 2 and ( not mood.getgift ) and mood.completed;
end

function MoodPerDay.ShowHasGift()
	if(not MoodPerDay.mood)then return; end
	local mood = MoodPerDay.mood[MoodPerDay.select];
	return mood.state == 3 and mood.getgift;
end

function MoodPerDay.ShowHasGiftGrowup()
	if(not MoodPerDay.GrowupData or not MoodPerDay.showgrowup)then return; end
	index = tonumber(index);
	local idx = MoodPerDay.showgrowup[MoodPerDay.select].oldindex;
	local data = MoodPerDay.GrowupData[idx];
	return data.state == 3 and data.getgift;
end

function MoodPerDay.GetGift()
	if(not MoodPerDay.mood)then return; end
	local mood = MoodPerDay.mood[MoodPerDay.select];	
	local quest = MoodPerDay.MoodData[mood.questtype][mood.questindex];
	local bhas, guid = hasGSItem(quest.rewards_gsid);
	
	if(bhas and guid)then

		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid> 0 )then
			item:OnClick("left");
			mood.getgift = true;
			mood.state = 3;
			MoodPerDay.SaveMood();
			if(MoodPerDay.pagectrl)then
				MoodPerDay.pagectrl:Refresh(0.01);
			end
		end
	end
end
 
function MoodPerDay.ShowDialyIcon()
	if(not MoodPerDay.mood)then return; end
	local mood = MoodPerDay.mood[MoodPerDay.select];	
	local count = 0;
	local i;
	for i=1,(mood.questtype-1) do
		count = count + #(MoodPerDay.MoodData[i]);
	end
	count = count + mood.questindex - 1;

	return "Texture/Aries/Quest/MoodPerDay/icon/" .. count .. "_32bits.png;0 0 106 106";
end

function MoodPerDay.GetPage()
	if(MoodPerDay.bIsDialy == true)then
		return 1;
	else
		return 2;
	end
end