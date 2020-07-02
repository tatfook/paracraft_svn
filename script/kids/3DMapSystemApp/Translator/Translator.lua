--[[
Title: Translator
Author(s): Leio Zhang
Date: 2008/7/8
Desc: 
find out all of chinese char in npl or mcml files
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Translator/Translator.lua");
local translator = Map3DSystem.App.Translator.Translator:new{
	filePathList = {"script/3Ddev/","script/AI/","script/lang/", },
	ignoreFilePathList = {"script/lang/"},
	filterList = {"*.lua"},
	contentFilterList = {"IDE", "paraworld"}, -- search for CommonCtrl.Locale("IDE")
	-- input merge: unused, new record.
	outPutTxtFilePathList = {"script/lang/test-zhCN.lua","script/lang/test-enUS.lua",}
}
translator:TransFiles();
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/common_control.lua");
local Translator = {
	name = "tanslator_instance",
	-- the path of current output text
	outPutTxtFilePath = nil,
	outPutTxtFilePathList = nil,
	-- the collection of path which will be translate
	filePathList = nil,
	-- detailed path discovered from filePathList
	resultPathList = nil,
	ignoreFilePathList = nil,
	contentFilterList = nil,
	-- like this:{"*.html","*.xml","*.mcml"}
	filterList = nil,	
	parseIndex = 1,
	writeIndex = 1,
	-- like this:table.insert(self.outPutList,{path = path,data = data});
	-- stored a path and its chinese char table,maybe the value of data is empty
	outPutList = nil,	
	-- the result of chinese char writed in NPL or MCML file
	-- if true, the char had been included "L"
	-- transResultList[i] = {path = "a/b.lua" data = {["测试"] = true},["测试1"] = true},}
	transResultList = nil,
	mergeresult = true, -- if mergeresult is false, it will made a new text file every time, see:Translator:WriteFile()
	--event
	StartReadFileEvent = nil,
	ProgressReadFileEvent = nil,
	EndReadFileEvent = nil,
	
	StartWriteFileEvent = nil,
	ProgressWriteFileEvent = nil,
	EndWriteFileEvent = nil,
};
commonlib.setfield("Map3DSystem.App.Translator.Translator", Translator);
-- find chinese character
function Translator.StartReadFileEvent()
	--commonlib.echo("开始：");
end
function Translator.ProgressReadFileEvent(index,len,path)
	--commonlib.echo({index,len,path});
end
function Translator.EndReadFileEvent(len,resultLen)
	--commonlib.echo("完成："..len);
end
-- add "L" in the found result 
function Translator.StartWriteFileEvent()
	--commonlib.echo("开始：");
end
function Translator.ProgressWriteFileEvent(index,len,path)
	--commonlib.echo({index,len,path});
end
function Translator.EndWriteFileEvent(len)
	--commonlib.echo("完成："..len);
end
function Translator:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	return o
end

function Translator:Init()
	self.outPutTxtFilePath = nil;
	self.filePathList = nil;
	self.resultPathList = nil;
	self.filterList = nil;
	self.parseIndex = 1;
	self.writeIndex = 1;
	self.outPutList = nil;
	self.transResultList = nil;
	self.ignoreFilePathList = nil;
	self.contentFilterList = nil;
	self.outPutTxtFilePathList = nil;
end
-- doing translate files
-- @param options: nil or {}
function Translator:TransFiles()
	self.parseIndex = 1;
	self.StartReadFileEvent();
	-- SearchAllFiles
	self:SearchAllFiles();
	if(not self.resultPathList or type(self.resultPathList)~="table") then return ; end;
	-- IgnoreFilePathList
	self:IgnoreFilePathList();
	-- IgnoreContent
	self:IgnoreContent();
	self.outPutList = {};
	self:Do_TransFiles()
	self:WriteFile()
	local len = table.getn(self.resultPathList);
	local resultLen = table.getn(self:FilterOutPutList());
	self.EndReadFileEvent(len,resultLen);
end
-- find all of chinese char
-- it will read everyone file(npl or mcml) by self.parseIndex instead of "for repetition"
function Translator:Do_TransFiles()
	local len = table.getn(self.resultPathList);
	if(self.parseIndex > len)then
		return;
	end	
	local path = self.resultPathList[self.parseIndex];
	
	local file = ParaIO.open(path, "r")
	if(file:IsValid()) then
		local __,__,__,extension = string.find(path,"(.+)%.(.+)$");
		extension = string.lower(extension);
		if(extension == "lua" or extension == "txt")then
			local txt = file:GetText();
			file:close();
			self:TransNPL(path,txt);
		else
			local txt = file:GetText();
			file:close();
			self:TransMCML(path,txt)
		end
	else
		log("error in Translator:"..path.."\n");
			
	end
	self.ProgressReadFileEvent(self.parseIndex,len,path)
	file:close();
	self.parseIndex = self.parseIndex + 1;
	self:Do_TransFiles();
end
-- translate npl files
function Translator:TransNPL(path,str)
	local data = {};
	local k,w;
	str = string.gsub(str,'^%s*%-%-%[%[.-[\r\n]?%]%]',"\r\n");
	str = string.gsub(str, "([\r\n])%s*%-%-%[%[.-[\r\n]?%]%]", "%1");
	str = string.gsub(str, "([\r\n])%s*%-%-(%-*)([^%-]%s*)[^\r\n]*", "%1");
	
	str = self:TransNPL_1(str,data);
	str = self:TransNPL_2(str,data);
	
	
	table.insert(self.outPutList,{path = path,data = data});
end


-- " "
function Translator:TransNPL_1(str,data)
	str = string.gsub(str,'"\\-"',"");
	local k,w;
	for k,w in string.gfind(str,'[^\\]("(.-)[^\\]")') do	
		if(self:isChineseCode(w))then
			data[k] = w;
			
		end
	end
	str = string.gsub(str,'([^\\])("(.-)[^\\]")',"%1");
	return str
end
-- [[ ]]
function Translator:TransNPL_2(str,data)
	for k,w in string.gfind(str,'(%[%[(.-\r?\n?)%]%])') do		
		if(self:isChineseCode(w))then
			data[k] = w;
		end
	end
	str = string.gsub(str,'(%[%[(.-\r?\n?)%]%])',"");
	return str
end
-- search all files in filePathList
function Translator:SearchAllFiles()
	if(not self.filePathList or type(self.filePathList)~="table") then return ; end;
	local k,v;
	local root_path = ParaIO.GetCurDirectory(0);
	local filterList = self.filterList;
	local temp_list = {}
	self.resultPathList = {};
	for k,v in ipairs(self.filePathList) do
		local path = v;
		local full_path = root_path..path;	
		local files = {};
		commonlib.SearchFiles(files,full_path, filterList, 300, 10000, true);
		table.insert(temp_list,{path = path,files = files});
	end
	local kk,vv;
	for k,v in ipairs(temp_list) do
		local path = v["path"];
		local files = v["files"];
		for kk,vv in ipairs(files)do
			local _path = path..vv;
			table.insert(self.resultPathList,_path);
		end		
	end
end
-- IgnoreFilePathList
function Translator:IgnoreFilePathList()
	if(not self.ignoreFilePathList or type(self.ignoreFilePathList)~="table")then return; end
	if(not self.resultPathList or type(self.resultPathList)~="table") then return ; end;
	local k,v ;
	local ignore_k,ingore_v;
	local root_path = ParaIO.GetCurDirectory(0);
	local resultPathList = self.resultPathList;
	for ignore_k,ingore_v in ipairs(self.ignoreFilePathList) do
		local ingore_path = root_path..ingore_v;
		ingore_path = string.lower(ingore_path)
		local len = table.getn(resultPathList);
		while(len>0)do
			local path = root_path..resultPathList[len];
			path = string.lower(path)
			if(string.find(path,"^"..ingore_path))then
				table.remove(resultPathList,len);
			end	
			len = len - 1;	
		end
	end
end
-- IgnoreContent
function Translator:IgnoreContent()
	if(not self.contentFilterList or type(self.contentFilterList)~="table")then return; end
	if(not self.resultPathList or type(self.resultPathList)~="table") then return ; end;
	local k,v ;
	local ignore_k,ingore_v;
	local root_path = ParaIO.GetCurDirectory(0);
	local resultPathList = self.resultPathList;
	for ignore_k,ingore_v in ipairs(self.contentFilterList) do
		local find_str = "CommonCtrl.Locale%(%s-\"%s-"..ingore_v.."%s-\"%s-%)"
		local len = table.getn(resultPathList);
		while(len>0)do
			local path = resultPathList[len];
			local file = ParaIO.open(path, "r")
			if(file:IsValid()) then			
				local txt = file:GetText();			
				file:close();
				if(string.find(txt,find_str))then
					table.remove(resultPathList,len);
				end		
			end
			file:close();	
			len = len - 1;	
		end
	end
end
function Translator:TransMCML_especial(path,str,data)
	if(not path or not str or not data)then return end;
	local k,w;
	for k ,w in string.gfind(str,'(<%%(.-[\r\n]?)%%>)') do
		local s = w;
		s = ParaMisc.EncodingConvert("utf-8", "", s) -- added lxz, mcml are utf-8 encoded, need conversion
		s = self:TransNPL_1(s,data);
		s = self:TransNPL_2(s,data);
	end
	str =string.gsub(str,'(<%%(.-[\r\n]?)%%>)',"");
	for k ,w in string.gfind(str,'(<script.->(.-[\r\n]?)<%/script>)') do
		local s = w;
		s = ParaMisc.EncodingConvert("utf-8", "", s) -- added lxz, mcml are utf-8 encoded, need conversion
		s = self:TransNPL_1(s,data);
		s = self:TransNPL_2(s,data);	
	end
	str =string.gsub(str,'(<script.->(.-[\r\n]?)<%/script>)',"");
	return str;
end
-- translate mcml files
function Translator:TransMCML(path,str)
	if(not path or not str)then return; end
	local data = {};
	str = self:TransMCML_especial(path,str,data)
	local xmlTable = ParaXML.LuaXML_ParseString(str);
	self:FindAllChild_node(xmlTable,data)
	table.insert(self.outPutList,{path = path,data = data});
end

function Translator:FindAllChild_node(child_table,data)
	if(not child_table or type(child_table) ~= "table") then return; end
	
	-- for attributes: added lxz
	if(type(child_table.attr) == "table") then
		local att,value;
		for att,value in pairs(child_table.attr) do
			if(type(value) == "string")then		
				if(self:isChineseCode(value))then
					data[string.format("%q", value)] = true; -- this encode in quotation lxz
				end
			end
		end
	end	
	
	-- for nodes
	local att,value;
	for att,value in ipairs(child_table) do
		if(type(value) == "table")then 
			self:FindAllChild_node(value,data); 
		elseif(type(value) == "string")then		
			if(self:isChineseCode(value))then
				data[string.format("%q", value)] = true; -- this encode in quotation lxz
			end
		end
	end
end
function Translator:isChineseCode(str)
	local len = string.len(str);
	local k;
	for k =1,len do
		local s = string.sub(str,k,k);
		local byte = string.byte(s);
		if(byte > 127)then
			return true;
		end
	end
	return false;
end
-- made a text file
function Translator:WriteFile()	
	local k,path;
	if(not self.outPutTxtFilePathList or type(self.outPutTxtFilePathList)~="table")then return; end
	for k,path in ipairs(self.outPutTxtFilePathList) do
		self.outPutTxtFilePath = path;
		local file;
		ParaIO.CreateDirectory(self.outPutTxtFilePath);
		if(ParaIO.DoesFileExist(self.outPutTxtFilePath) == false) then
			file = ParaIO.open(self.outPutTxtFilePath, "w");
			file:close();
		end
		file = ParaIO.open(self.outPutTxtFilePath, "r")
		if(file:IsValid()) then
			local oldString = file:GetText();
			file:close();
			file = ParaIO.open(self.outPutTxtFilePath, "w")
			if(file:IsValid()) then
				local out_string = self:GetOutPutString();
				if(self.mergeresult)then
					out_string = self:ImproveOutString(oldString,out_string)
				end
				file:WriteString(out_string);
			end
		else
			log("error in Translator: couldn't open " .. self.outPutTxtFilePath.. "\n");	
		end
		file:close();
	end
end
function Translator:ImproveOutString(oldString,newString)
	if(not newString)then 
		return "" 
	end
	if(not oldString)then
		return newString;
	end
	local __,__,oldTable = string.find(oldString,"({.+})");
	if(not oldTable)then
		return newString;
	end
	oldTable = self:ConstructATable(oldTable)
	
	local __,__,newTable = string.find(newString,"({.+})");
	
	newTable = self:ConstructATable(newTable)
	-- input merge: unused, new record.
	local key_old,data_old,key_new,data_new;
	local temp = {};
	for key_old,data_old in pairs(oldTable) do
		local data = newTable[key_old];
		if(not data)then
			temp[key_old] = {data = data_old, type = "unused"}
		else
			temp[key_old] = {data = data_old, type = "update"}	
		end	
	end
	
	for key_new,data_new in pairs(newTable) do
		local data = oldTable[key_new];
		if(not data)then
			temp[key_new] = {data = data_new, type = "new"}		
		else
			temp[key_new] = {data = data, type = "update"}	
		end		
	end
	local outstring = "\n";
	for key_new,key_data in pairs(temp) do
		local key = key_new;
		local data = key_data["data"];
		local type = key_data["type"];
		local sub_str = string.format('[ %s ] = %s,',key,data);
		if(type =="unused")then
			outstring = outstring .. " -- unused \n";
		elseif(type =="new")then
			outstring = outstring .. " -- new \n";	
		end
		outstring = outstring ..sub_str.. "\n";	
	end
	outstring = "{"..outstring.."}";
	outstring = string.gsub(newString,"({.+})",outstring);
	return outstring;
end
function Translator:ConstructATable(s)
	if(not s)then return; end
	local t = {};
	local find_key,find_value;		
	for find_key,find_value in string.gfind(s,'%[%s-(".-")%s-%]%s-=%s-([^%s].-)%s-,') do	
		t[find_key] = find_value;
	end
	for find_key,find_value in string.gfind(s,'%[%s-(%[%[.-%]%])%s-%]%s-=%s-([^%s].-)%s-,') do	
		t[find_key] = find_value;
	end
	return t;
end
-- only full path of files
function Translator:GetResultPathList()
	return self.resultPathList;
end
-- the result of chinese char 
-- @param bIgnoreHeader: if true, each line is a translation text or a comment, without outputing header info
-- @param bDuplicateText: if true, it will duplicate text on right of the equal sign. otherwise, it will use true.
function Translator:GetOutPutString(bReport, bIgnoreHeader, bDuplicateText)
	if(not self.outPutList)then return ; end
	local k,v;
	local out_string = "";
	local allFindStr = "";
	local index = 0;
	local result = self:FilterOutPutList()
	
	
	for k,v in ipairs(result) do
		local path = v["path"];
		local data = v["data"];		
		local kk,vv;
			index = index + 1;
			local title_str = string.format("--\n-- %s\n",path);
			allFindStr = allFindStr..string.format('["%s"] = true, \n',path);
			out_string = out_string..title_str;
			for kk,vv in pairs(data) do
				local sub_str;
				--local sub_str = string.format('[ [[ %s ]] ] = true, \n',vv);
				if(not bDuplicateText) then
					sub_str = string.format('[ %s ] = true, \n',kk);
				else
					sub_str = string.format('[ %s ] = %s, \n',kk,kk);
				end	
				out_string = out_string..sub_str;
			end
	end
	if(not bIgnoreHeader or bReport) then
		local last_str = "----------------------------------------------\n";
		last_str = last_str ..string.format("--查找了%s个文件，共%s个有中文字符！ \n",table.getn(self.outPutList),index)
		out_string = out_string..last_str;
	end
	
	if(bReport)then
		out_string = out_string.."----------------------------------------------\n";
		out_string = out_string.."以下是包含中文字符的文件！\n";
		out_string = out_string..allFindStr;
		out_string = out_string.."----------------------------------------------\n";
		out_string = out_string.."以下是包含'L'中文字符的结果！\n";
		out_string = out_string..self:GetAbout_L_str(true)
		out_string = out_string.."----------------------------------------------\n";
		out_string = out_string.."以下是替换中文字符的结果！\n";
		out_string = out_string..self:GetAbout_L_str(false)
	elseif(not bIgnoreHeader) then
		-- add header
		local __,__,locale_name,local_cn = string.find(self.outPutTxtFilePath,".+/(.+)%-(.+)%.(.+)$")
		--local locale_name = "test";
		--local local_cn = "zhCN";
		local luaFileStr = string.format([[
NPL.load("(gl)script/ide/Locale.lua");
local L = CommonCtrl.Locale("%s");
L:RegisterTranslations("%s", function() return {
%s
} end);
]],locale_name,local_cn,out_string);
		out_string = luaFileStr;
	end
	return out_string;
end

function Translator:GetAbout_L_str(hasL)
	local out_string = "";
	local result = self.transResultList;
	if(self.transResultList)then 
		for k,v in ipairs(result) do
			local path = v["path"];
			local data = v["data"];		
			local kk,vv;
				local title_str = string.format("----------------------------------------------\n--[[%s]] \n",path);
				out_string = out_string..title_str;
				if(hasL)then
					for kk,vv in pairs(data) do
						if(vv)then
							local sub_str = string.format('[ %s ] = true, \n',kk);
							out_string = out_string..sub_str;
						end
					end
				else
					for kk,vv in pairs(data) do
						if(not vv)then
							local sub_str = string.format('[ %s ] = false, \n',kk);
							out_string = out_string..sub_str;
						end
					end
				end
		end
	end	
	return out_string;
end
function Translator:FilterOutPutList()
	local temp = {};
	for k,v in ipairs(self.outPutList) do
		local path = v["path"];
		local data = v["data"];		
		local kk,vv;
		local hasChild = false;
		for kk,vv in pairs(data) do
			
			if(kk)then
				hasChild = true;
				break;
			end
		end
		--commonlib.echo({path,hasChild});
		if(hasChild)then
			table.insert(temp,{path = path, data = data});
		end
	end
	return temp;
end

------------------------------------------------
-- @param bOverWrite: if true, it will overwrite the file, otherwise it will output to output file directory and create necessary sub folders there. 
function Translator:Do_writeIn(bOverWrite)
	if(not self.outPutList)then return; end
	self.writeIndex = 1;
	self.StartWriteFileEvent();
	local result = self:FilterOutPutList();
	self:Do_writeInFiles(result, bOverWrite)
	local len = table.getn(result);
	self.EndWriteFileEvent(len);
	self:GetReport();
end

-- @param bOverWrite: if true, it will overwrite the file, otherwise it will output to output file directory and create necessary sub folders there. 
function Translator:Do_writeInFiles(result, bOverWrite)
	local len = table.getn(result);
	if(self.writeIndex > len)then
		return;
	end	
	local path = result[self.writeIndex]["path"];
	local data = result[self.writeIndex]["data"];
	if(not self.outPutTxtFilePathList) then
		self.outPutTxtFilePath = "temp/tranlated_files/default-zhCN.lua";
	else
		self.outPutTxtFilePath = self.outPutTxtFilePathList[1];
	end
	
	local __,__,newFilePath = string.find(self.outPutTxtFilePath,"(.+)%.(.+)");
	local root_path = ParaIO.GetCurDirectory(0);
	newFilePath = newFilePath.."/"..path;
	if(ParaIO.CopyFile(path,newFilePath, true))then
		local file = ParaIO.open(newFilePath, "r")
		if(file:IsValid()) then
			local txt = file:GetText();
			file:close();
			txt = self:ReplaceMatchStr(txt,path,data);
			file = ParaIO.open(newFilePath, "w")
			file:WriteString(txt);
			file:close();
		else
			log("error in Translator:"..newFilePath.." is not valid\n");
				
		end
		file:close();
		
		if(bOverWrite) then
			-- make a backup of old file and overwrite it with new one. added LiXizhi.
			ParaIO.CopyFile(path, newFilePath..".old", true);
			ParaIO.CopyFile(newFilePath, path, true);
		end
	else
		log("error in Translator:"..newFilePath.." can't be made\n");
	end
	self.ProgressWriteFileEvent(self.writeIndex,len,newFilePath)
	
	self.writeIndex = self.writeIndex + 1;
	self:Do_writeInFiles(result, bOverWrite);
end
function Translator:ReplaceMatchStr(str,path,data)
	if(not str or not path or not data) then return ; end
	if(not self.transResultList)then
		self.transResultList = {};
	end
	local t_path = path;
	local t_data = {};
	local k,v
	for k,v in pairs(data) do
		--local temp_k = k;
		local temp_k = string.gsub(k,"([%(%)%.%%%+%-%*%?%[%]%^%$])","%%%1");
		local w;
		for w in string.gfind(str,string.format('L%s',temp_k)) do
				t_data[k] = true;
		end
		for w in string.gfind(str,string.format('[^L]%s',temp_k)) do
				t_data[k] = false;
		end
		str = string.gsub(str,string.format('([^L])(%s)',temp_k),"%1L%2");
	end	
	table.insert(self.transResultList,{path = t_path,data = t_data});
	return str;
end

function Translator:GetReport()
		local txt = "";
		txt = txt..self:GetOutPutString(true);		
		local path = self.outPutTxtFilePath..".report.txt"
		ParaIO.CreateDirectory(path);
		local file = ParaIO.open(path, "w")
		if(file:IsValid()) then
			file:WriteString(txt);
		else
			log("error in Translator: couldn't write a report " .. path.. "\n");
		end
		file:close();
end