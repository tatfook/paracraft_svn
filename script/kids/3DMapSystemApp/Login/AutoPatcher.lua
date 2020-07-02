--[[
Title: AutoPatcher
Author(s): Leio Zhang
Date: 2008/7/30
Desc: 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Login/AutoPatcher.lua");
-------------------------------------------------------
]]
local AutoPatcher = {
	--domain = "http://192.168.0.221:8111",
	--domain = "http://api.pala5.com:8111",
	-- defaultserver
	domain = nil,
	-- the position of download remote files
	destFolder = "temp/autopatcher/",
	-- local update config files, default path is "patchfiles.xml"
	localUpdateConfig = nil;
	-- list[1] = {index = 1,patchfile = "/testPatch/PatchData_test1.jpg" ,sourcefile = "/temp/autopatcher/temp.jpg",outputfile = "/temp/autopatcher/test_output_1.pkg"};
	downloadList = nil,
	downloadIndex = 0,
	patchIndex = 0,
	copyIndex = 0,
	localserver = nil,
	
	--private
	latestConfigFilesTxt = nil,
	--event
	singleFileProgressEvent = nil,
	singleFileCompleteEvent = nil,
	singleFileErrorEvent = nil,
	-- all of files had been downloaded
	allFilesCompleteEvent = nil,
	
	-- all of patch files complete vpatchprompt :VPATCHPROMPT.EXE (patchfile) (sourcefile) (outputfile)
	patchfilesCompleteEvent = nil,
	-- pe world  finished update
	copyCompleteEvent = nil,
	
};
commonlib.setfield("Map3DSystem.App.Login.AutoPatcher", AutoPatcher)
-- event
-- singleFileProgressEvent
function AutoPatcher.singleFileProgressEvent(src,percent)
	--commonlib.echo({"progressing",src,percent});
end
-- singleFileCompleteEvent
function AutoPatcher.singleFileCompleteEvent(src)
	--commonlib.echo({"complete",src});
end
-- singleFileErrorEvent
function AutoPatcher.singleFileErrorEvent(src)
	--commonlib.echo({"error",src});
end
-- allFilesCompleteEvent
function AutoPatcher.allFilesCompleteEvent()
	--commonlib.echo("allFilesComplete");
	
end
-- patchfilesCompleteEvent
function AutoPatcher.patchfilesCompleteEvent()
	--commonlib.echo("patchfilesCompleteEvent");
end
-- copyCompleteEvent;
function AutoPatcher.copyCompleteEvent()
	--commonlib.echo("copyCompleteEvent");
end
function AutoPatcher:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	return o
end
function AutoPatcher:Init()
	if(not self.localserver)then
		local ls = System.localserver.CreateStore("AutoPatcher", 1);
			if(not ls) then
				log("error: failed creating local server ResourceStore in AutoPatcher \n")
				return 
			end
		self.localserver = ls;
	end
	self.downloadList = nil;
	self.downloadIndex = 0;
	self.patchIndex = 0;
	self.copyIndex = 0;
	self.latestConfigFilesTxt = nil;
end
-- GetVersionsTable
function AutoPatcher:GetVersionsTable(v)
	if(not v)then return; end
	return v
end
-- GetFilesTable
function AutoPatcher:GetFilesTable(v)
	if(not v)then return; end
	return v
end
-- GetDefaultserverTable
function AutoPatcher:GetDefaultserverTable(v)
	if(not v)then return; end
	local domain = v[1];
	self.domain = domain;
end
-- read contents from a txtpath,if type="new" then record latestConfigFilesTxt
function AutoPatcher:GetTxtTable(txtPath,type)
	if(not txtPath)then return; end
	local xmlTable;
	local file = ParaIO.open(txtPath, "r")
		if(file:IsValid()) then
			local str = file:GetText();
			if(type =="new")then
				self.latestConfigFilesTxt = str;
			end
			xmlTable = ParaXML.LuaXML_ParseString(str);		
			file:close();
			if(not xmlTable)then return; end
			xmlTable = xmlTable[1];
			local k,value;
			local version_result,files_result;
			if(not xmlTable)then commonlib.echo(txtPath); return; end
			for k,value in ipairs(xmlTable) do
				local name = value["name"];
				if(name =="versions")then
					version_result = self:GetVersionsTable(value)
				elseif(name =="files")then
					files_result = self:GetFilesTable(value)
				elseif(name =="defaultserver")then
					self:GetDefaultserverTable(value)
				end
			end
			return version_result,files_result
			
		end
		file:close();
end
-- get the result of update
function AutoPatcher:GetDownloadList(curVersionTxt,newVersionTxt)
	if(not curVersionTxt or not newVersionTxt)then return; end
	local version_result_cur,files_result_cur = self:GetTxtTable(curVersionTxt,"old");
	local version_result_new,files_result_new = self:GetTxtTable(newVersionTxt,"new");
	if(not files_result_cur)then files_result_cur = {}; end
	if(not files_result_new)then files_result_new = {}; end
	local k,v;
	-- current files result
	local list_cur = {}
	for k,v in ipairs(files_result_cur) do
		v = v[1];
		local __,__,index,patchfile,sourcefile = string.find(v,"(.+),(.+),(.+)");
		local outputfile = string.gsub(patchfile,"/","_").."_"..k..".pkg"
		outputfile = "/"..self.destFolder..outputfile;
		list_cur[k] = {index = index,patchfile = patchfile,sourcefile = sourcefile,outputfile = outputfile};
	end
	
	-- new files result
	local list_new = {}
	for k,v in ipairs(files_result_new) do
		v = v[1];
		local __,__,index,patchfile,sourcefile = string.find(v,"(.+),(.+),(.+)");
		local outputfile = string.gsub(patchfile,"/","_").."_"..k..".pkg"
		outputfile = "/"..self.destFolder..outputfile;
		list_new[k] = {index = index,patchfile = patchfile,sourcefile = sourcefile,outputfile = outputfile};
	end
	
	local list = {};
	local kk,vv;
	local i = 1;
	for k,v in ipairs(list_new) do
		local index,patchfile,sourcefile;
		index = v["index"];
		patchfile = v["patchfile"];
		sourcefile = v["sourcefile"];
		outputfile = v["outputfile"];
		list[i] = {index = index,patchfile = patchfile,sourcefile = sourcefile,outputfile = outputfile};
		
		for kk,vv in ipairs(list_cur) do
			local index_cur,patchfile_cur,sourcefile_cur;
			index_cur = vv["index"];
			patchfile_cur = vv["patchfile"];
			sourcefile_cur = vv["sourcefile"];
			if(index==index_cur and patchfile==patchfile_cur and sourcefile==sourcefile_cur)then
				list[i] = nil;
				i = i - 1;
				break;
			end
		end	
		i = i + 1;
	end
	self.downloadList = list;
	return list;
	---- VPATCHPROMPT.EXE (patchfile) (sourcefile) (outputfile)
	--local list = {};
	--list[1] = {patchfile = "/testPatch/PatchData_test1.jpg" ,sourcefile = "/temp/autopatcher/temp.jpg",outputfile = "/temp/autopatcher/test_output_1.pkg"};
	--list[2] = {patchfile = "/testPatch/PatchData_test2.jpg" ,sourcefile = "/temp/autopatcher/temp.jpg",outputfile = "/temp/autopatcher/test_output_2.pkg"};
	--self.downloadList = list;
	--return list;
end
-- DownloadPatchfiles
function AutoPatcher:DownloadPatchfiles()
	local list = self.downloadList;
	if(not list)then return; end
	local len = table.getn(list);
	if(self.downloadIndex>=len)then return; end
	self.downloadIndex = self.downloadIndex + 1;
	local ls = self.localserver;
	if(not ls)then return; end
	
	local data = self.downloadList[self.downloadIndex];
	local cachepolicy = "access plus 0";
	local src = self.domain..data["patchfile"];
	local dest = self.destFolder..data["patchfile"];
	ls:GetFile(System.localserver.CachePolicy:new(cachepolicy),
			src,
			function (entry)
				if(ParaIO.CopyFile(entry.payload.cached_filepath, dest, true)) then
					--"complete";
					self.singleFileCompleteEvent(src)
					if(self.downloadIndex == len)then
						self.allFilesCompleteEvent();
						self:Patchfiles();
					else
						self:DownloadPatchfiles();
					end
				else
					--"error";	
					self.singleFileErrorEvent(src);
				end	
			end,
			nil,
			function (msg, url)
				if(msg.DownloadState == "") then
					--downloading
					if(msg.totalFileSize) then
						local percent = math.floor(msg.currentFileSize*100/msg.totalFileSize);
						self.singleFileProgressEvent(src,percent);
					end
				elseif(msg.DownloadState == "complete") then
				elseif(msg.DownloadState == "terminated") then
				end
			end
		);
end
-- do VPATCHPROMPT.EXE (patchfile) (sourcefile) (outputfile)
function AutoPatcher:Patchfiles()
	local list = self.downloadList;
	if(not list)then return; end
	local len = table.getn(list);
	if(self.patchIndex>=len)then return; end
	self.patchIndex = self.patchIndex + 1;
	local data = self.downloadList[self.patchIndex];
	-- VPATCHPROMPT.EXE (patchfile) (sourcefile) (outputfile)
	local vpatchprompt_path = "script/bin/VPatch/vpatchprompt.exe"
	local patchfile = self.destFolder..data["patchfile"];
	local sourcefile =data["sourcefile"];
	local outputfile = data["outputfile"];
	local script = string.format("%s %s %s", ParaIO.GetCurDirectory(0)..patchfile, ParaIO.GetCurDirectory(0)..sourcefile, ParaIO.GetCurDirectory(0)..outputfile);
	script = string.gsub(script, "/", "\\");
	if(ParaGlobal.ShellExecute("open", ParaIO.GetCurDirectory(0)..vpatchprompt_path, script, "", 1))then
		if(self.patchIndex == len)then
			self.patchfilesCompleteEvent();
			--self:CopyToNewVersion();
		else
			self:Patchfiles();
		end
	end
end
-- update pe world
function AutoPatcher:CopyToNewVersion()
	local list = self.downloadList;
	if(not list)then return; end
	local len = table.getn(list);
	if(self.copyIndex>=len)then return; end
	self.copyIndex = self.copyIndex + 1;
	local data = self.downloadList[self.copyIndex];
	local sourcefile =data["sourcefile"];
	local outputfile = data["outputfile"]
	if(ParaIO.CopyFile(outputfile, sourcefile, true)) then
		if(self.copyIndex == len)then
			self.copyCompleteEvent();
		else
			self:CopyToNewVersion();
		end
	else
		log("error: can't copy file "..outputfile.." to "..sourcefile.."\n")
	end
end
-- SaveLatestUpdatedConfigFiles
function AutoPatcher:SaveLatestUpdatedConfigFiles()
	local txt = self.latestConfigFilesTxt;
	local txtPath = self.localUpdateConfig;
	if(not txt)then return; end 
	local file = ParaIO.open(txtPath, "w")
		if(file:IsValid()) then	
			file:WriteString(txt);
			file:close();
		end
		file:close();
end