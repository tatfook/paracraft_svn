--[[
Title: BadWordFilter
Author(s): WangTian
Date: 2009/12/5
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Chat/BadWordFilter.lua");
local BadWordFilter = commonlib.gettable("MyCompany.Aries.Chat.BadWordFilter");
BadWordFilter.FilterString(str)
------------------------------------------------------------
]]

-- create class
local libName = "AriesChatBadWordFilter";
local BadWordFilter = commonlib.gettable("MyCompany.Aries.Chat.BadWordFilter");
local string_match = string.match;

local badwordfiles = {
	"config/BadWords.xml",
};

local badwords = {};

local badwordfromnamefiles = {
	"config/BadWords.xml",
};

local badwordsfromname = {};

function BadWordFilter.Init()
	if(BadWordFilter.is_inited) then
		return;
	end
	BadWordFilter.is_inited = true;

	if(System.options.mc) then
		badwordfiles = {
			"config/BadWords.Paracraft.xml",
		};
		badwordfromnamefiles = {
			"config/BadWords.Paracraft.xml",
		};
	end

	local _, path;
	for _, path in ipairs(badwordfiles) do
		local file = ParaIO.open(path, "r");
		if(file:IsValid() == true) then
			LOG.std(nil, "debug", "BadWordFilter is inited from %s", path)
			-- read a line 
			local line = file:readline();
			while(line) do
				--badwords[line] = true;
				table.insert(badwords, line);
				line = file:readline();
			end
			file:close();
		else
			LOG.std(nil, "warn", "BadWordFilter failed to open file from %s", path)	
		end
	end

	local lua_symbols = {
		["^"] = true,
		["$"] = true,
		["("] = true,
		[")"] = true,
		["%"] = true,
		["."] = true,
		["["] = true,
		["]"] = true,
		["*"] = true,
		["+"] = true,
		["-"] = true,
		["?"] = true,
	};
	if(System.options.locale == "zhTW") then
		badwordfromnamefiles = {
			"config/BadWords.xml",
			"config/BadWords.zhTW.xml",
			"config/BadWordsFromName.zhTW.xml",
		};
	end
	local _, path;
	for _, path in ipairs(badwordfromnamefiles) do
		local file = ParaIO.open(path, "r");
		if(file:IsValid() == true) then
			LOG.std(nil, "debug", "BadWordFilter BadWordFromName is inited from %s", path)
			-- read a line 
			local line = file:readline();
			while(line) do
				--badwords[line] = true;
				if(lua_symbols[line]) then
					line = "%"..line;
				end
				badwordsfromname[line] = true;
				line = file:readline();
			end
			file:close();
		else
			LOG.std(nil, "warn", "BadWordFilter BadWordFromName failed to open file from %s", path)	
		end
	end
end

local ReplacementStr = {
	"*",
	"**",
	"***",
	"****",
	"*****",
	"******",
	"*******",
	"********",
	"*********",
	"**********",
	"***********",
	"************",
	"*************",
	"**************",
	"***************",
	"****************",
	"*****************",
	"******************",
	"*******************",
	"********************",
	"*********************",
	"**********************",
	"***********************",
	"************************",
	"*************************",
	"**************************",
	"***************************",
	"****************************",
	"*****************************",
	"******************************",
	"*******************************",
	"********************************",
	"*********************************",
	"**********************************",
	"***********************************",
};

ReplacementStr[0] = "";

-- public: return the validated string 
function BadWordFilter.FilterString(str)
	if(type(str) == "string") then
		local _, badword;
		for _, badword in ipairs(badwords) do
			if(str:match(badword)) then
				local len = #(badword);
				if(not string_match(badword, "^(%l+)$")) then
					len = math.floor(len/3);
				end
				local replace = ReplacementStr[len] or "";
				str = string.gsub(str, badword, replace);
			end
		end
	end
	return str;
end

-- public: return the validated string 
function BadWordFilter.FilterStringForUserName(str)
	if(type(str) == "string") then
		local badword, _;
		for badword, _ in pairs(badwordsfromname) do
			if(str:match(badword)) then
				local len = #(badword);
				if(not string_match(badword, "^(%l+)$")) then
					len = math.floor(len/3);
				end
				local replace = ReplacementStr[len] or "";
				str = string.gsub(str, badword, replace);
			end
		end
	end
	return str;
end

local cheat_strs = {
	"魔豆", "充值", "米币", "账号", "密码", "米米号", "交易密码", "交易"
}
function BadWordFilter.HasCheatingWord(str)
	if(type(str) == "string") then
		local bFound; 
		local _, badword;
		for _, badword in ipairs(cheat_strs) do
			if(str:match(badword)) then
				bFound = true;
				break;
			end
		end
		return bFound;
	end
end


function BadWordFilter.GenerateBadWordFile()
	local badwords = {};
	local input_files = {
		"BadWordFilter/c.t",
		"BadWordFilter/cdk.dat",
		"BadWordFilter/e.t",
		"BadWordFilter/edk.dat",
	};
	local _, path;
	for _, path in ipairs(input_files) do
		local file = ParaIO.open(path, "r");
		if(file:IsValid() == true) then
			-- read a line 
			local line = file:readline();
			while(line) do
				if(string.find(line, "%s")) then
					local word = string.match(line, "^(.-)%s");
					if(word and not string.find(word, "#")) then
						table.insert(badwords, word);
					end
				else
					table.insert(badwords, line);
				end
				line = file:readline();
			end
			file:close();
		end
	end
	
    ParaIO.DeleteFile("config/BadWords.xml");
    
	local file = ParaIO.open("config/BadWords.xml", "w");
	if(file:IsValid() == true) then
		local _, writeline;
		for _, writeline in ipairs(badwords) do
			file:WriteString(writeline.."\n");
		end
		file:close();
	end
end