--[[
Title: generate visual studio doc project.
Author(s): LiXizhi
Date: 2008/10/20
Desc: It will read script.vsproj and generate to installer/SDK/script.vcproj. the latter contains
only sources files, however with implementation removed. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/installer/GenVisualStudioDocProject.lua");
commonlib.GenVisualStudioDocProject.RebuildScriptProject();
-------------------------------------------------------
]]

if not commonlib.GenVisualStudioDocProject then commonlib.GenVisualStudioDocProject = {} end
local GenVisualStudioDocProject = commonlib.GenVisualStudioDocProject


-- it copies all build rules and npl compilers and files to the destination directory
function GenVisualStudioDocProject.RebuildScriptProject()
	-- generate all files first
	commonlib.GenVisualStudioDocProject.GenProject({
		src="script.vcproj", 
		dest = "installer/SDK/script.vcproj",
		-- completely included 
		include_full = {
			"^script/kids/3DMapSystemApp/mcml/test/", 
			"^script/VisualStudioNPL/", 
		},
		-- source exempted include
		include_filter={
			"^script/ide/math/", 
			"^script/ide/[^/]+$",
			"^script/kids/3DMapSystemApp/mcml/", 
			"^script/ide/System/localserver/", 
			"^script/kids/3DMapSystemApp/WebBrowser/", 
			"^script/kids/3DMapSystemApp/Developers/", 
			"^script/kids/3DMapSystemApp/profiles/", 
			"^script/kids/3DMapSystemApp/Login/", 
			"^script/kids/3DMapSystemApp/worlds/", 
			"^script/kids/3DMapSystemApp/[^/]+$", 
			"^script/kids/3DMapSystemUI/Desktop/", 
		}, 
		-- exclude files
		exclude_filter={
			"^script/kids/3DMapSystemApp/appkeys%.lua", 
		},
	})
	
	-- Please manually copy files script/bin to installer/SDK/script/bin
end

-- generate a visual studio project from src to destination, replacing all source code and leaving only documentation. 
-- @param options: table of {src="script.vcproj", include_full={}, include_filter={"^script/ide", ""}, exclude_filter={}, dest = "installer/SDK/script.vcproj"}
function GenVisualStudioDocProject.GenProject(options)
	local xmlRoot = ParaXML.LuaXML_ParseFile(options.src);
	if(not xmlRoot) then 
		log("file"..options.src.." does not exist\n");
		return 
	end
	local destFolder = string.gsub(options.dest, "[^/\\]+$", "");
	if(destFolder == nil) then
		return
	end

	-- whether file is completely included. 
	local function FilterFullInclude(filename)
		if(options.include_full) then
			local _, filter;
			for _, filter in ipairs(options.include_full) do
				if(string.match(filename, filter)) then
					return true;
				end
			end
		end
	end

	-- return true if filename passes both include_filter and exclude_filter
	local function FilterLuaFile(filename)
		local bPassed = true;
		if(options.include_filter) then
			bPassed = false;
			local _, filter;
			for _, filter in ipairs(options.include_filter) do
				if(string.match(filename, filter)) then
					bPassed = true;
					break;
				end
			end
		end
		if(bPassed and options.exclude_filter) then
			local _, filter;
			for _, filter in ipairs(options.exclude_filter) do
				if(string.match(filename, filter)) then
					bPassed = false;
					break;
				end
			end
		end
		return bPassed;
	end
	
	local NPL_HeaderText=[[-- Copyright (C) 2004 - 2008 ParaEngine Corporation, All Rights Reserved.
]]
	local nCount = 0;
	NPL.load("(gl)script/ide/XPath.lua");
	local fileNode;
	for fileNode in commonlib.XPath.eachNode(xmlRoot, "//File") do
		if(fileNode.attr and fileNode.attr.RelativePath) then
			local srcFile = fileNode.attr.RelativePath;
			srcFile = string.gsub(srcFile, "\\", "/");
			srcFile = string.gsub(srcFile, "^%./", "");
			if(FilterFullInclude(srcFile)) then
				-- completely included. 
				local destFile = string.gsub(srcFile,"%.lua$","%.doc%.lua");
				destFile = string.gsub(destFile, "\\", "/");
				destFile = destFolder..string.gsub(destFile, "^%./", "");
				ParaIO.CopyFile(srcFile, destFile, true);
			elseif(string.match(fileNode.attr.RelativePath, "%.lua$")) then
				nCount = nCount + 1;
				local srcFile = fileNode.attr.RelativePath;
				local destFile = string.gsub(srcFile,"%.lua$","%.doc%.lua");
				fileNode.attr.RelativePath = destFile;
				
				srcFile = string.gsub(srcFile, "\\", "/");
				srcFile = string.gsub(srcFile, "^%./", "");
				destFile = string.gsub(destFile, "\\", "/");
				destFile = destFolder..string.gsub(destFile, "^%./", "");
				
				if(FilterLuaFile(srcFile)) then
					ParaIO.CreateDirectory(destFile)
					local out = ParaIO.open(destFile, "w")
					if(out:IsValid()) then
						local src = ParaIO.open(srcFile, "r")
						if(src:IsValid()) then
							out:WriteString(NPL_HeaderText);
							local text = src:GetText();
							
							--
							-- header: title, author, date, description and sample code
							--
							local header = string.match(text, "^%s*%-%-%[%[.-[\r\n]+%]%]")
							if(header) then
								out:WriteString(header);
								out:WriteString("\r\n");
							end
	
							local funcText;
							for funcText in string.gfind(text, "\n(function%s+.-)[\r\n]+.-\nend%s-") do
								out:WriteString(funcText.." end\r\n");
							end
							-- -- remove function body
							--text = string.gsub(text, "(\nfunction%s+.-[\r\n]+).-(\nend%s-)", "%1\r%2");
							--text = string.gsub(text, "(\nlocal%s+function%s+.-[\r\n]+).-(\nend%s-)", "%1\r%2");
							-- out:WriteString(text);
							
							src:close();
							commonlib.log("gen file %s\n", destFile);
						end
						out:close();
					end
				end	
			end
		end	
	end
	
	-- output project file.
	ParaIO.CreateDirectory(options.dest);
	local file = ParaIO.open(options.dest, "w");
	if(file:IsValid()) then
		-- TODO: shall we change encoding to "utf-8" ? 
		file:WriteString([[<?xml version="1.0" encoding="gb2312"?>]]);
		file:WriteString("\r\n");
		file:WriteString(commonlib.Lua2XmlString(xmlRoot));
		-- change encoding to "utf-8" before saving
		--file:WriteString(ParaMisc.EncodingConvert("", "utf-8", commonlib.Lua2XmlString(xmlRoot)));
		file:close();
	end
end
