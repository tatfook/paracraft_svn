--[[
Title: Version update
Author(s): LiXizhi
Date: 2014/1/13
Desc:  The very first page shown to the user. It asks the user to create or load or download a game from game market. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/mobile/paracraft/Login/VersionUpdate.lua");
local VersionUpdate = commonlib.gettable("ParaCraft.Mobile.Login.VersionUpdate");
VersionUpdate.OnInit()
-------------------------------------------------------
]]

local VersionUpdate = commonlib.gettable("ParaCraft.Mobile.Login.VersionUpdate");

--local page;
local curVersion = "0.0.1";
local beHasUpdate = false;
local updateInfos = {};
local temp_version_info_file = "Update/mobile/TempUrlInfos.xml";
--[[
Version0.0.1
##1.测试1##
##2.测试2##
##3.测试3##
##4.测试4##
##5.测试5##
]]
local url="http://www.paraengine.com/twiki/bin/view/CCWeb/ParaCraftMobileVersion";

function VersionUpdate.OnInit(callback)
	VersionUpdate.GetCurVersionInfoFromFile();
	VersionUpdate.GetNewVersionInfoFromUrl(callback);
end

function VersionUpdate.GetCurVersionInfoFromFile()
	NPL.load("(gl)script/apps/Aries/Creator/Game/game_options.lua");
	local options = commonlib.gettable("MyCompany.Aries.Game.GameLogic.options")
	curVersion = options.GetClientVersion();
	return curVersion;
end

function VersionUpdate.LoadFromHTMLText(text)
	local first_num,second_num,third_num = string.match(curVersion,"(%d*)%.(%d*)%.(%d*)");
	first_num = tonumber(first_num);
	second_num = tonumber(second_num);
	third_num = tonumber(third_num);
	local new_version = "";
	if(text) then
		--echo(text);
		local new_first_num,new_second_num,new_third_num;
		--if_else(string.find(text,"Version(%d*)%.(%d*)%.(%d*)"),echo("find"),echo("no find"))
		for new_first_num,new_second_num,new_third_num in text:gmatch("Version(%d*)%.(%d*)%.(%d*)") do
			new_version = string.format("%s.%s.%s",new_first_num,new_second_num,new_third_num);
			new_first_num = tonumber(new_first_num);
			new_second_num = tonumber(new_second_num);
			new_third_num = tonumber(new_third_num);
			if(new_first_num > first_num or new_second_num > second_num or new_third_num > third_num) then
				beHasUpdate = true;
				local info;
				for updateInfo in text:gmatch("##([^#]*)##") do
					table.insert(updateInfos,{text = updateInfo,});
				end
			end
		end
	end
	VersionUpdate.SaveNewVersionTempInfoToFile(new_version);
end

function VersionUpdate.GetNewVersionInfoFromUrl(callback)
	NPL.load("(gl)script/ide/System/localserver/URLResourceStore.lua");

	local ls = System.localserver.CreateStore(nil, 3, "userdata");
	if(ls) then
		ls:GetURL(System.localserver.CachePolicy:new("access plus 1 day"), url,
			function(msg)
				if(not msg) then
					VersionUpdate.GetNewVersionInfoFromUrlTempFile();
				elseif(type(msg) == "table" and msg.rcode == 200) then
					VersionUpdate.LoadFromHTMLText(msg.data);
				end
				if(callback) then
					callback();
				end
			end);
	end
end

function VersionUpdate.SaveNewVersionTempInfoToFile(version)
	local file = ParaIO.open(temp_version_info_file, "w");
	if(file:IsValid()) then 
		local update = {name="update",};
		
		local notes = {name="notes",attr = {version = version,}};
		update[1] = notes;
		for i = 1,#updateInfos do
			local attr = {
				text = updateInfos[i]["text"],
			};
			local note = {name = "note",attr = attr,};
			notes[#notes + 1] = note;
		end
		file:WriteString(commonlib.Lua2XmlString(update, true));
		file:close();
		return true;
	end
end

function beNewVersion(new_version)
	local new_first_num,new_second_num,new_third_num = string.match(new_version,"(%d*)%.(%d*)%.(%d*)");
	local cur_first_num,cur_second_num,cur_third_num = string.match(curVersion,"(%d*)%.(%d*)%.(%d*)");
	
	if(new_first_num > cur_first_num or new_second_num > cur_second_num or new_third_num > cur_third_num) then
		return true;
	else
		return false;
	end
end

function VersionUpdate.GetNewVersionInfoFromUrlTempFile()
	local rootXML = ParaXML.LuaXML_ParseFile(temp_version_info_file);
	local notes;
	if(rootXML) then
		for notes in commonlib.XPath.eachNode(rootXML,"/update/notes") do
			local attr = notes.attr;
			if(attr.version and beNewVersion(attr.version)) then
				local note;
				for note in commonlib.XPath.eachNode(notes,"/note") do
					if(note.attr and note.attr.text and note.attr.text ~= "") then
						table.insert(updateInfos,{text = note.attr.text,});
					end
				end
			end
		end
	end
end

function VersionUpdate.GetUpdateInfo()
	if(not next(updateInfos)) then
		return nil;
	else
		return updateInfos;
	end
end
