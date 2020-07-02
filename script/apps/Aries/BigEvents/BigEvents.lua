--[[
Title: 
Author(s): spring
Date: 2011/5/18
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/BigEvents/BigEvents.lua");
MyCompany.Aries.BigEvents.BigEventsListMain.ShowMainWnd();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatProfile.lua");
local BigEventsListMain = commonlib.gettable("MyCompany.Aries.BigEvents.BigEventsListMain");

BigEventsListMain.event = BigEventsListMain.event or {};
BigEventsListMain.curEvent = BigEventsListMain.curEvent or 1;
BigEventsListMain.chapters = BigEventsListMain.chapters or {};
BigEventsListMain.chapter = BigEventsListMain.chapter or {};
BigEventsListMain.curChapter = BigEventsListMain.curChapter or 1;

BigEventsListMain.AllEvents = BigEventsListMain.AllEvents or {};

function BigEventsListMain.Init()
	local self = BigEventsListMain;
	self.page = document:GetPageCtrl();
	
	if (next(self.AllEvents) ~= nil) then
	else
		local config_file="config/Aries/BigEvents/bigevents.xml";
		local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
		if(not xmlRoot) then
			commonlib.log("warning: failed loading mentor config file: %s\n", config_file);
			return;
		end
		
		local xmlnode="/BigEvents/bigevent"

		local each_event;

		self.AllEvents={}; -- 初始化 event 
	
		for each_event in commonlib.XPath.eachNode(xmlRoot, xmlnode) do
			local event={};
			
			event.eventname = "["..each_event.attr.entrylevel.."] "..each_event.attr.title;
			event.isnew = tonumber(each_event.attr.isnew);
			event.eventindex = tonumber(each_event.attr.index);

			local each_chapter;	
			event.chapter = {};
				
		-- chapter
			for each_chapter in commonlib.XPath.eachNode(each_event, "/chapter") do
				local chapter={};
				chapter.chaptername = "["..each_chapter.attr.entrylevel.."] "..each_chapter.attr.title;
				chapter.chapterisnew = tonumber(each_chapter.attr.isnew);			
				chapter.chapterindex = tonumber(each_chapter.attr.index);				
				chapter.entrylevel = tonumber(each_chapter.attr.entrylevel);
				chapter.isopen = tonumber(each_chapter.attr.isopen);

				chapter.drama = {};				
				local each_drama=nil;	
				for each_drama in commonlib.XPath.eachNode(each_chapter, "/drama") do
					local drama={};
					drama.imgdesc = each_drama.attr.img;
					drama.scriptdesc = each_drama.attr.scriptdesc;
					table.insert(chapter.drama,drama);
				end
			
				local each_detail=nil;		
				chapter.detail = {};	
				for each_detail in commonlib.XPath.eachNode(each_chapter, "/detail") do
					local detail={};		
					detail.needlvl = each_detail.attr.needlvl;
					detail.needplayer = tonumber(each_detail.attr.needplayer);
					detail.world = each_detail.attr.world;
					detail.rewardexp = tonumber(each_detail.attr.rewardexp);
					detail.chapterdesc = each_detail.attr.chapterdesc;
					table.insert(chapter.detail,detail);
				end

				local each_reward=nil;		
				chapter.reward = {};	
				for each_reward in commonlib.XPath.eachNode(each_chapter, "/reward") do
					local reward ={};
					reward.gsid = tonumber(each_reward.attr.gsid);			
					reward.num = tonumber(each_reward.attr.num);			
					local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(tonumber(reward.gsid));
					if(gsItem)then		
						reward.name = gsItem.template.name;	
					end 
					table.insert(chapter.reward,reward);
				end

				table.insert(event.chapter,chapter);
			end
		
			table.insert(self.AllEvents,event);			
		end
		
		BigEventsListMain.curEvent = BigEventsListMain.AllEvents[1].eventindex;
		BigEventsListMain.event = commonlib.deepcopy(BigEventsListMain.AllEvents[1]);
		BigEventsListMain.chapters = commonlib.deepcopy(BigEventsListMain.event.chapter);
		BigEventsListMain.chapter = commonlib.deepcopy(BigEventsListMain.chapters[1]);
		BigEventsListMain.curChapter = BigEventsListMain.chapter.chapterindex;					
	end 

	--commonlib.echo("===========initevent==")
	--commonlib.echo(BigEventsListMain.AllEvents)
end

function BigEventsListMain.GetCurEvent()
	return BigEventsListMain.curEvent;
end

function BigEventsListMain.GetCurChapter()
	return BigEventsListMain.curChapter;
end

function BigEventsListMain.ChangeEvent(index)
	index = tonumber(index);
	BigEventsListMain.curEvent = tonumber(BigEventsListMain.AllEvents[index].eventindex);	
	local curEvent=BigEventsListMain.curEvent;

	BigEventsListMain.event = commonlib.deepcopy(BigEventsListMain.AllEvents[curEvent]);
	BigEventsListMain.chapters = commonlib.deepcopy(BigEventsListMain.event.chapter);
	BigEventsListMain.chapter = commonlib.deepcopy(BigEventsListMain.chapters[1]);
	BigEventsListMain.curChapter = BigEventsListMain.chapter.chapterindex;	
	if(BigEventsListMain.page)then
		-- this ensures that the first page is shown when switching chapters. added by LiXizhi
		BigEventsListMain.page:CallMethod("BigEventsListMain_Drama", "Reset");
		BigEventsListMain.page:Refresh(0.01);
	end
end

function BigEventsListMain.ChangeChapter(index)
	BigEventsListMain.curChapter = tonumber(index);	
	BigEventsListMain.chapter = commonlib.deepcopy(BigEventsListMain.chapters[index]);
	
	--commonlib.echo("========chapter drama===");
	--commonlib.echo(BigEventsListMain.chapter.drama);
	BigEventsListMain.curChapter = BigEventsListMain.chapter.chapterindex;
	
	if(BigEventsListMain.page)then
		-- this ensures that the first page is shown when switching chapters. added by LiXizhi
		BigEventsListMain.page:CallMethod("BigEventsListMain_Drama", "Reset");
		BigEventsListMain.page:Refresh(0.01);
	end
end

function BigEventsListMain.ShowMainWnd()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);

	paraworld.PostLog({action = "read_bigevent"}, "bigevent_log", function(msg)	end);

    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/BigEvents/BigEvents.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "BigEventsListMain.ShowMainWnd", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 0,
				enable_esc_key = true,
        allowDrag = false,
				directPosition = true,
        align = "_ct",
        x = -890/2,
        y = -520/2-40,
        width = 890,
        height = 600,
    });

end

function BigEventsListMain.EventDS_Func(index)
	if(index == nil)then
		return #(BigEventsListMain.AllEvents);
	else
		return BigEventsListMain.AllEvents[index];
	end
end

function BigEventsListMain.ChapterDS_Func(index)
	if(index == nil)then
		return #(BigEventsListMain.chapters);
	else
		return BigEventsListMain.chapters[index];
	end
end

function BigEventsListMain.DramaDS_Func(index)
	if(index == nil)then
		return #(BigEventsListMain.chapter.drama);
	else
		local dramapage=#(BigEventsListMain.chapter.drama);
		if (index==dramapage) then
			BigEventsListMain.islastpage=1
		else
			BigEventsListMain.islastpage=0
		end
--		commonlib.echo("===dramapage"..index.."|"..dramapage.."|islastpage:"..BigEventsListMain.islastpage);
		return BigEventsListMain.chapter.drama[index];
	end
end

function BigEventsListMain.DetailDS_Func(index)
	if(index == nil)then
		return #(BigEventsListMain.chapter.detail);
	else
		return BigEventsListMain.chapter.detail[index];
	end
end

function BigEventsListMain.RewardDS_Func(index)
	if(index == nil)then
		return #(BigEventsListMain.chapter.reward);
	else
		return BigEventsListMain.chapter.reward[index];
	end
end

function BigEventsListMain.OnTelePort()
	local worldnm = BigEventsListMain.chapter.detail[1].world;
	local Instance = MyCompany.Aries.Instance;

	paraworld.PostLog({action = "enter_bigevent"}, "bigevent_log", function(msg)	end);

	Instance.EnterInstancePortal(worldnm);

	--NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
	--local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
	--local canpass = QuestHelp.InSameWorldByKey(BigEventsListMain.chapter.detail[1].world);
--
	--if (canpass) then
		--facing = 0;
		--local radius = 5;
		--local end_pos ={};
		--if (string.len(BigEventsListMain.chapter.detail[1].pos)>0) then
			--local section = string.format("{%s}",BigEventsListMain.chapter.detail[1].pos);
			--end_pos =  NPL.LoadTableFromString(section);
		--end;
--
		--if(next(end_pos)~=nil)then
			--local  x,y,z = end_pos[1],end_pos[2],end_pos[3];
			--x = x + radius * math.sin(facing);
			--z = z + radius * math.cos(facing);
			--if(x and y and z)then
				--local Position = {x,y,z};
				--local CameraPosition = { 15, 0.27, facing + 1.57 - 1};
				--local msg = { aries_type = "OnMapTeleport", 
							--position = Position, 
							--camera = CameraPosition, 
							--bCheckBagWeight = true,
							--wndName = "map", 
						--};
					--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
			--end
		--end
	--else
		--System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {
			--name = BigEventsListMain.chapter.detail[1].world,
			--local grid_node_key = "m:"..tostring(self.next_key);
			----create_join = true,
			--on_finish = function()
				--facing = -0.8;
				--local radius = 5;
				--local end_pos ={};
				--if (string.len(BigEventsListMain.chapter.detail[1].pos)>0) then
					--local section = string.format("{%s}",BigEventsListMain.chapter.detail[1].pos);
					--end_pos =  NPL.LoadTableFromString(section);
				--end;
				----commonlib.echo("===========bigevent pos======");
				----commonlib.echo(end_pos);
				--if(next(end_pos)~=nil)then
					--local  x,y,z = end_pos[1],end_pos[2],end_pos[3];
					--x = x + radius * math.sin(facing);
					--z = z + radius * math.cos(facing);
					--if(x and y and z)then
						--local Position = {x,y,z};
						--local CameraPosition = { 15, 0.27, facing + 1.57 - 1};
						--local msg = { aries_type = "OnMapTeleport", 
									--position = Position, 
									--camera = CameraPosition, 
									--bCheckBagWeight = true,
									--wndName = "map", 
								--};
							--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
					--end
				--end
			--end,
		--});
	--end
end

function BigEventsListMain.GoDirect()
    local bean = MyCompany.Aries.Pet.GetBean();
    local combatlvl;
    if(bean) then
			combatlvl = bean.combatlel or 0;
    end   
    if (combatlvl < BigEventsListMain.chapter.entrylevel) then
    	local s=string.format([[你的战斗等级比较低，去战斗有危险哦，等你达到<div style="float:left;color:#ff0000">%d</div>级再去吧！]],BigEventsListMain.chapter.entrylevel);
    	_guihelper.Custom_MessageBox(s,function(result)			
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"},12);   
	else
		local needplayer = BigEventsListMain.chapter.detail[1].needplayer or 1;
		if (needplayer>1) then
	    	local s=[[<div style="color:#ff0000">多人副本，难度比较高，建议组队进入！</div>组队完毕，队长可以直接带全队进入！]];
			_guihelper.Custom_MessageBox(s,function(result)
				if(result == _guihelper.DialogResult.Yes )then
					--进入副本
					BigEventsListMain.OnTelePort();
				end
			end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/Coming_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later2_32bits.png; 0 0 153 49"});
		else
			BigEventsListMain.OnTelePort();
		end
    end
	
end

function BigEventsListMain.GoWithTeam()
	NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
	local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");

    local bean = MyCompany.Aries.Pet.GetBean();
    local combatlvl;
    if(bean) then
			combatlvl = bean.combatlel or 0;
    end 

	  
    if (combatlvl < BigEventsListMain.chapter.entrylevel) then
    	local s="你的战斗等级比较低，去战斗有危险哦，多叫几个哈奇高手一起去吧！";
    	_guihelper.Custom_MessageBox(s,function(result)			
				local pve_world= BigEventsListMain.chapter.detail[1].world;
				local setworld = {};
				setworld[pve_world] = true;
				LobbyClientServicePage.DirectShowPage("PvE",setworld);
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"},12);   
		else
			local pve_world= BigEventsListMain.chapter.detail[1].world;
			local setworld = {};
			setworld[pve_world] = true;
			LobbyClientServicePage.DirectShowPage("PvE",setworld);
    end

end