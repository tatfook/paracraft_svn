--[[
Title: Aries quest Daily wish Dataload
Author(s): Spring
Date: 2010/9/26

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/DailyWish.lua");
------------------------------------------------------------
]]

local DailyWish = commonlib.gettable("MyCompany.Aries.Quest.DailyWish");

function DailyWish.GetData()
	local config_file="config/Aries/Quests/dailywish.xml";
	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading mentor config file: %s\n", config_file);
		return;
	end
	
	xmlnode="/DailyWish/group"
	local MoodPerDay={};
	local each_group;
	for each_group in commonlib.XPath.eachNode(xmlRoot, xmlnode) do
		group_id = tonumber(each_group.attr.id);
		MoodPerDay[group_id]={};
		local each_quest,i=nil,1;		
		for each_quest in commonlib.XPath.eachNode(each_group, "/quest") do
			local quest={};			
			quest.id=i
			quest.name = each_quest.attr.name;
			quest.level = tonumber(each_quest.attr.level);
			quest.status_pg = each_quest.attr.status_pg;
			quest.acquire_gsid = tonumber(each_quest.attr.acquire_gsid);
			quest.need_gsid = tonumber(each_quest.attr.need_gsid);
			quest.begin_desc = each_quest.attr.begin_desc;
			quest.has_gsid = tonumber(each_quest.attr.has_gsid);
			quest.aries_type = each_quest.attr.aries_type;
			quest.finish_desc = each_quest.attr.finish_desc;
			quest.rewards_gsid = tonumber(each_quest.attr.rewards_gsid);
			quest.exid = tonumber(each_quest.attr.exid);		
			quest.rewards_desc = each_quest.attr.rewards_desc;
			i=i+1;
			table.insert(MoodPerDay[group_id],quest)

			--commonlib.echo("======read from dailywish.xml:  ====="..group_id);
			--commonlib.echo(MoodPerDay[group_id]);
		end
	end
	--commonlib.echo("======read from dailywish.xml:  =====");
	--commonlib.echo(MoodPerDay);
	return MoodPerDay;
end

function DailyWish.GetGrowData()
	local config_file="config/Aries/Quests/growrec.xml";
	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading mentor config file: %s\n", config_file);
		return;
	end
	
	local xmlnode = "/Growup/quest";
	local Growup={};
	local each_quest;
	for each_quest in commonlib.XPath.eachNode(xmlRoot, xmlnode) do
		local quest={};			
		quest.name = each_quest.attr.name;
		quest.level = tonumber(each_quest.attr.level);
		quest.subclass = tonumber(each_quest.attr.subclass);
		quest.status_url = each_quest.attr.status_url;
		quest.lua_url = each_quest.attr.lua_url;
		quest.acquire_gsid = tonumber(each_quest.attr.acquire_gsid);
		quest.need_gsid = tonumber(each_quest.attr.need_gsid);
		quest.begin_desc = each_quest.attr.begin_desc;
		quest.proc_desc = each_quest.attr.proc_desc;
		quest.finish_gsid = tonumber(each_quest.attr.finish_gsid);
		quest.has_gsid = tonumber(each_quest.attr.has_gsid);
		quest.aries_type = each_quest.attr.aries_type;
		quest.finish_desc = each_quest.attr.finish_desc;
		quest.rewards_gsid = tonumber(each_quest.attr.rewards_gsid);
		quest.exid = tonumber(each_quest.attr.exid);		
		quest.rewards_desc = each_quest.attr.rewards_desc;
		quest.status_url2 = each_quest.attr.status_url2;
		table.insert(Growup,quest)
	end
	--commonlib.echo("======read from growrec.xml:  =====");
	--commonlib.echo(Growup);
	return Growup;
end
