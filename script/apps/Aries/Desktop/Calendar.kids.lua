--[[
Title: Calendar.kids.lua
Author(s): spring yan
Date: 2012/2/29
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/Calendar.kids.lua");
local Calendar = commonlib.gettable("MyCompany.Aries.Desktop.Calendar");
Calendar.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/AntiIndulgence.lua");
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");

local Calendar = commonlib.gettable("MyCompany.Aries.Desktop.Calendar");
local LOG = LOG;

Calendar.datasource = {};
Calendar.datasource_map = {};
Calendar.tags={};
Calendar.SelectedDay=1;
Calendar.HotTips = "";
Calendar.IsTagAll=false;
Calendar.IsTagRecomm=false;

function Calendar.FuncIsTagAll()
	return Calendar.IsTagAll;
end

function Calendar.FuncIsTagRecomm()
	return Calendar.IsTagRecomm;
end

function Calendar.ClosePage()
	local self = Calendar;
	if(self.page)then
		self.page:CloseWindow();
		self.page = nil;
	end
	self.datasource = nil;
end

function Calendar.DoInit()
	if(Calendar.IsInited) then
		return 
	else
		Calendar.IsInited = true;
	end
	Calendar.Init();
end

function Calendar.Init()
	local self = Calendar;
	local config_file="config/Aries/Others/calendar.kids.xml"; 

	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading help config file: %s\n", config_file);
		return;
	end	
		
	local rootnode="/Calendar";	
	local week_set,each_act;
	local _day;

	for _day=1,7 do
		Calendar.datasource_map[_day]={};
	end

	local function LoadTagFromString(_tags0)
		local _tags=_tags0;
		local _s1,_s2,_tag1,_taglvl;
		local _t,__t={},{};
		while true do
			_s1=string.find(_tags,",");
			if not _s1 then break end;
			_s2=string.sub(_tags,1,_s1-1);
			_tags=string.sub(_tags,_s1+1);
			__t={tag=_s2};
			table.insert(_t,__t);
		end
		__t={tag=_tags};
		table.insert(_t,__t);
		return _t;
	end

	local function LoadTagsFromString(_tags0)
		local _tags=_tags0;
		local _s1,_s2,_tag1,_taglvl;
		local _t,__t={},{};
		while true do
			_s1=string.find(_tags,"|");
			if not _s1 then break end;
			_s2=string.sub(_tags,1,_s1-1);
			_tags=string.sub(_tags,_s1+1);
			_tag1,_taglvl=string.match(_s2,"(.*),(%d+)");
			__t={tag=_tag1,lvl=tonumber(_taglvl),clicked=0;};
			table.insert(_t,__t);
		end
		_tag1,_taglvl=string.match(_tags,"(.*),(%d+)");
		__t={tag=_tag1,lvl=tonumber(_taglvl),clicked=0;};
		table.insert(_t,__t);
		return _t;
	end

	for week_set in commonlib.XPath.eachNode(xmlRoot, "/Calendar/Week") do
		local _tags = week_set.attr.tags;

		self.HotTips = week_set.attr.hottips;
		self.tags = LoadTagsFromString(_tags) or {};

		--commonlib.echo(_tags);
		--commonlib.echo(self.tags);
		for each_act in commonlib.XPath.eachNode(week_set, "/act") do
			local act_days=commonlib.LoadTableFromString(each_act.attr.days) or {};
			local act_name = each_act.attr.name;
			local act_tag = LoadTagFromString(each_act.attr.tag);
			local act_worldname = each_act.attr.worldname;
			local act_gametype = string.lower(each_act.attr.gametype);
			local act_desc = each_act.attr.desc;
			local act_times = tonumber(each_act.attr.times);
			local act_place = each_act.attr.place;
			local act_npcid = tonumber(each_act.attr.npcid);
			local act_gsid = tonumber(each_act.attr.actgsid);
			local act_combatlvl = each_act.attr.combatlvl;
			local act_combatlvl_string = string.gsub(act_combatlvl,","," ~ ");
			local act_period = each_act.attr.period;
			local act_reward = commonlib.LoadTableFromString(each_act.attr.reward) or {};
			local act_doact = each_act.attr.doact;
			
			local disp_period;
			if (not tonumber(act_period)) then
				disp_period=act_period;
			elseif (tonumber(act_period)==999) then
				disp_period="整点开放";			
			end
			
			if (act_worldname and act_gametype=="pve" and next(act_reward)==nil) then				
				local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
				local loots=LobbyClientServicePage.GetLootsByWorldName(act_worldname,3)
				if(loots)then					
					local line;
					local i=1;
					for line in string.gfind(loots, "[^|]+") do
						local gsid,cnt = string.match(line,"(.+),(.+)");
						gsid = tonumber(gsid);
						cnt = tonumber(cnt) or 0;
						if(gsid)then
							act_reward[i]=gsid; i=i+1;
						end
					end
					table.sort(act_reward,function(a,b)
						return a < b;
					end);
				end				
			
			elseif (act_worldname and act_gametype=="pvp" and next(act_reward)==nil) then
				local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
				local templates = LobbyClientServicePage.GetGameTemplates();
				local keyname;
    			for _,keyname in pairs(templates) do
    				if (string.lower(act_worldname)==string.lower(keyname.worldname)) then
    					local loots=keyname.loots;
							if(loots)then					
									local line;
									local i=1;
									for line in string.gfind(loots, "[^|]+") do
										local gsid,cnt = string.match(line,"(.+),(.+)");
										gsid = tonumber(gsid);
										cnt = tonumber(cnt) or 0;
										if(gsid)then
											act_reward[i]=gsid; i=i+1;
										end
									end
									table.sort(act_reward,function(a,b)
										return a < b;
									end);
							end
							break;    				
    				end 
    			end -- for _,keyname
    		
			end
			
			local act={name=act_name,worldname=act_worldname,
						desc=act_desc,times=act_times,place=act_place,actgsid=act_gsid,
						npcid=act_npcid,combatlvl_string=act_combatlvl_string,combatlvl=act_combatlvl,
						disp_period=disp_period,period=act_period,reward=act_reward,
						doact=act_doact,tag=act_tag};

			local each_day;
			for _,each_day in pairs(act_days) do
				table.insert(Calendar.datasource_map[each_day],act);
			end
		end
	end --for weekset
		
	--commonlib.echo(self.datasource_map);	
end

function Calendar.OnInit()
	local self = Calendar;	
	self.page = document:GetPageCtrl();
end

function Calendar.CreatePage(leavehaqi,paraoldv)
	local self = Calendar;
	local params={};
	if (leavehaqi and paraoldv) then
		params = {
				url = "script/apps/Aries/Desktop/Calendar.kids.html?leavehaqi=1&paraoldv="..paraoldv,  
				name = "Calendar.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				isTopLevel = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = true,
				directPosition = true,
					align = "_ct",
					x = -930/2,
					y = -540/2,
					width = 930,
					height = 540,
		}
	else
		params = {
				url = "script/apps/Aries/Desktop/Calendar.kids.html", 
				name = "Calendar.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				isTopLevel = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = true,
				directPosition = true,
					align = "_ct",
					x = -930/2,
					y = -530/2,
					width = 930,
					height = 530,
		}
	end
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
	if(params._page and Dock.OnClose) then
		params._page.OnClose = function(bDestroy)
			Dock.OnClose("Calendar.ShowPage")
		end
	end	
end

function Calendar.DS_Func(index)
	local self = Calendar;
	if(index == nil) then
		return #(self.datasource);
	else
		return self.datasource[index];
	end	
end

function Calendar.DS_Func_reward(index,mindex)
	local self = Calendar;
	local _reward={};
	local rewardlist={};
	local _,_gsid;

	if (next(self.datasource)~=nil) then
		_reward=self.datasource[mindex].reward;
		local i=1;
		for _,_gsid in pairs(_reward) do
			rewardlist[i]={gsid=_gsid};
			i=i+1;
		end
	end
	--commonlib.echo("=============DS_Func_reward")
	--commonlib.echo(rewardlist)
	if(index == nil) then
		return #(rewardlist);
	else
		return rewardlist[index];
	end	
end

function Calendar.DS_Func_tags(index)
	local self = Calendar;
	if(index == nil) then
		return #(self.tags);
	else
		return self.tags[index];
	end	
end

function Calendar.ShowPage(leavehaqi,paraoldv)
	local self = Calendar;
	self.FindDataSource();
	self.TagFilter("recomm",false);
	self.InitTag();
	self.IsTagRecomm = true;
	self.IsTagAll = false;
	self.CreatePage(leavehaqi,paraoldv);
end

--@param type: "1","2","3","4","5","6","7"
function Calendar.FindDataSource(weekday)
	local self = Calendar;
	-- self.datasource_map[helptype] = Calendar.CreateHelpFolder(helptype);
	self.DoInit();
	
	local week_day="";
	local _datasource,__datasource={},{};

	if (weekday) then
		weekday=tonumber(weekday);
		_datasource = commonlib.deepcopy(self.datasource_map[weekday]);
		self.SelectedDay = weekday;
	else	
		local Scene = commonlib.gettable("MyCompany.Aries.Scene");
	--周末  1 is sunday
	-- 2 3 4 5 6 7 1				
		local week = Scene.GetDayOfWeek();		
		if (week==1) then 
			week=7;
		else
			week=week-1;
		end				
		_datasource = commonlib.deepcopy(self.datasource_map[week]);
		self.SelectedDay = week;
	end

	local bean = MyCompany.Aries.Pet.GetBean();
	local mylevel;
	if(bean) then
		mylevel = bean.combatlel or 0;
	end

	local _index,_act;
	for _index,_act in pairs(_datasource) do
		local _combatlvl = _act.combatlvl;		
		local __,__,minlvl,maxlvl=string.find(_combatlvl,"(.+),(.+)");
		minlvl=tonumber(minlvl);
		maxlvl=tonumber(maxlvl);
		
		if (mylevel>=minlvl and mylevel<=maxlvl) then
			table.insert(__datasource,_act)
		end	
	end
	self.datasource = commonlib.deepcopy(__datasource);

	--commonlib.echo("================find datasource");
	--commonlib.echo(self.datasource);
end

-- @result 0: 等级不足, 1: 等级满足、当前也在活动时间内，2:等级满足、还未到活动时间, 3:时间已过
function Calendar.GetState(index)
	if (next(Calendar.datasource[index])~=nil) then
		local _period=Calendar.datasource[index].period;
		local _combatlvl=Calendar.datasource[index].combatlvl;
		
		local __,__,minlvl,maxlvl=string.find(_combatlvl,"(.+),(.+)");
		minlvl=tonumber(minlvl);
		maxlvl=tonumber(maxlvl);			
	
		local nowsec=MyCompany.Aries.Scene.GetElapsedSecondsSince0000();
		local bean = MyCompany.Aries.Pet.GetBean();
		local mylevel;
		if(bean) then
			mylevel = bean.combatlel or 0;
		end
		
		local validlvl=0;
		if (mylevel>=minlvl and mylevel<=maxlvl) then
			validlvl=1;
		end
		
		local validsec=0;
		local _test=tonumber(_period);
		if (not _test) then
			local __,__,time1,time2=string.find(_period,"(.+),(.+)");
	
			if (not time1) then
				local __,__,frm_hour,frm_min,to_hour,to_min = string.find(_period,"(.+):(.+)~(.+):(.+)");
				frm_hour=tonumber(frm_hour);
				frm_min=tonumber(frm_min);
				to_hour=tonumber(to_hour);
				to_min=tonumber(to_min);
				frmsec=Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(frm_hour,frm_min,0);
				tosec=Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(to_hour,to_min,0);
				
				if (nowsec>=frmsec and nowsec<=tosec) then
					validsec=1
				elseif (nowsec<frmsec) then
					validsec=2
				elseif (nowsec>tosec) then
					validsec=3
				end
			else
				local __,__,frm_hour1,frm_min1,to_hour1,to_min1 = string.find(time1,"(.+):(.+)~(.+):(.+)");			
				local __,__,frm_hour2,frm_min2,to_hour2,to_min2 = string.find(time2,"(.+):(.+)~(.+):(.+)");
				
				frm_hour1=tonumber(frm_hour1);
				frm_min1=tonumber(frm_min1);
				to_hour1=tonumber(to_hour1);
				to_min1=tonumber(to_min1);
				frmsec1=Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(frm_hour1,frm_min1,0);
				tosec1=Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(to_hour1,to_min1,0);
				
				frm_hour2=tonumber(frm_hour2);
				frm_min2=tonumber(frm_min2);
				to_hour2=tonumber(to_hour2);
				to_min2=tonumber(to_min2);			
				frmsec2=Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(frm_hour2,frm_min2,0);
				tosec2=Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(to_hour2,to_min2,0);
			
				if (frmsec2<frmsec1) then -- 确保第2时间段是晚于第1时间段，即使策划配反了
					local __sec=frmsec1;
					frmsec1=frmsec2;	frmsec2=__sec;
					__sec=tosec1; tosec1=tosec2; tosec2=__sec;
				end
				
				if ((nowsec>=frmsec1 and nowsec<=tosec1) or (nowsec>=frmsec2 and nowsec<=tosec2)) then
					validsec=1
				elseif ((nowsec<frmsec1) or (nowsec>tosec1 and nowsec<frmsec2)) then
					validsec=2
				elseif (nowsec>tosec2) then
					validsec=3
				end			
			end --if (not time1)
			
		elseif (_test==999) then -- 999表示整点活动
			local _min=(nowsec%3600-(nowsec%3600)%60)/60;
			if (_min==0) then
				validsec=1				
			else
				validsec=2
			end
						
		end
		
		if (validlvl==1) then
			return validsec;
		else
			return 0;
		end
		
	else  -- if (next(Calendar.datasource[index])~=nil)
		return 0;
	end
end

function Calendar.InitTag()
	local self = Calendar;
	for _index,__tag in pairs(self.tags) do
		self.tags[_index].clicked=0;
	end
end

function Calendar.GetHotTips()
	local self = Calendar;
	return self.HotTips;
end

function Calendar.TagFilter(index,isrefresh)
	local self = Calendar;

	self.FindDataSource(self.SelectedDay);
	local _datasource = commonlib.deepcopy(self.datasource);

	if (index == "alltags") then
		self.datasource=commonlib.deepcopy(_datasource);
		for _index,__tag in pairs(self.tags) do
			self.tags[_index].clicked=0;
		end
		self.IsTagRecomm = false;
		self.IsTagAll = true;
	elseif (index=="recomm") then
		local _tag = "推荐";
		local _act,_index,__tag;
		local __datasource={};

		for _index,_act in ipairs(_datasource) do
			for _,__tag in pairs(_act.tag) do
				if (_tag == __tag.tag) then  
					table.insert(__datasource,_act);
				end;
			end
		end

		self.datasource=commonlib.deepcopy(__datasource);
		for _index,__tag in pairs(self.tags) do
			self.tags[_index].clicked=0;
		end
		self.IsTagRecomm = true;
		self.IsTagAll = false;
	else
		local _tag = self.tags[index].tag;
		local _act,_index,__tag;
		local __datasource={};

		for _index,_act in ipairs(_datasource) do
			for _,__tag in pairs(_act.tag) do
				if (_tag == __tag.tag) then  
					table.insert(__datasource,_act);
				end;
			end
		end

		self.datasource=commonlib.deepcopy(__datasource);

		for _index,__tag in pairs(self.tags) do
			if (_tag == __tag.tag) then
				self.tags[_index].clicked=1;
			else
				self.tags[_index].clicked=0;
			end
		end
		self.IsTagRecomm = false;
		self.IsTagAll = false;
	end

	--commonlib.echo(_datasource);
	--commonlib.echo(self.tags);
	if (isrefresh) then
		self.page:Refresh(0.1);
	end
end