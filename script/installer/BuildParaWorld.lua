--[[
Title: batch build the release redistributable of ParaWorld
Author(s): LiXizhi
Date: 2008/7/2
Desc: batch build the release redistributable of ParaWorld from development server. Some build options are available, see doc below. It may take several minutes to complete. 
The build process is as below:
- compiles all NPL scripts to /bin folder
- rebuild zip packages for core script, texture and asset files. 
- encrypt all zip packages to ParaEngine pkg files
- run paraworld_installer_v1.nsi

Date: 2009/4/30
Change by WangTian: Taurus installer added for ParaEngine SDK

Date: 2009/5/22
Change by WangTian: Aries installer added for ParaEngine SDK

Use Lib:
-------------------------------------------------------
--
-- To build the release version: still needs to build nsi seperately
-- 
NPL.load("(gl)script/installer/BuildParaWorld.lua");
commonlib.BuildParaWorld.BuildAll()

--
-- Build ParaWorld Viewer app.
-- 
NPL.load("(gl)script/installer/BuildParaWorld.lua");
commonlib.BuildParaWorld.BuildParaWorldViewer()

--
-- Build Taurus app.
-- 
NPL.load("(gl)script/installer/BuildParaWorld.lua");
commonlib.BuildParaWorld.BuildTaurus()

--
-- Build Aries app.
-- 
NPL.load("(gl)script/installer/BuildParaWorld.lua");
commonlib.BuildParaWorld.BuildAries()

--
-- Build Haqi Teen
-- 
NPL.load("(gl)script/installer/BuildParaWorld.lua");
commonlib.BuildParaWorld.BuildTeenComplete()

--
-- To build the in-house SDK version: still needs to check-in the main.pky output file to AB
-- 
NPL.load("(gl)script/installer/BuildParaWorld.lua");
commonlib.BuildParaWorld.BuildInHouseSDK()

--
-- To build just main script and texture, still needs to build nsi seperately
-- 
NPL.load("(gl)script/installer/BuildParaWorld.lua");
commonlib.BuildParaWorld.BuildScriptAndTexture()

-- For Unkown reasons, nsi script is not output correctly. So one needs to compile it via command line manually. there is nsi built rules in visual studio, just select the nsi file and F7 to compile. 
--
-- one can also batch build by running following command line from debug window. 
--
NPL.load("(gl)script/ide/UnitTest/unit_test.lua");
local test = commonlib.UnitTest:new();
if(test:ParseFile("script/installer/BuildParaWorld.lua")) then test:Run(); end

--
-- To build only a given step
-- 
NPL.load("(gl)script/installer/BuildParaWorld.lua");
commonlib.BuildParaWorld.CompileNPLFiles()
commonlib.BuildParaWorld.MakeZipPackage()
commonlib.BuildParaWorld.EncryptZipFiles()
--commonlib.BuildParaWorld.RunInstallerScript()

--
-- To build translation text from mcml and npl files to script/lang/ folder
-- 
NPL.load("(gl)script/installer/BuildParaWorld.lua");
commonlib.BuildParaWorld.BuildTranslations()
-------------------------------------------------------
]]

if not commonlib.BuildParaWorld then commonlib.BuildParaWorld = {} end
local BuildParaWorld = commonlib.BuildParaWorld

-- the nullsoft command line maker path
local nsimaker_path = "script/bin/nsis/makensis.exe"
-- nsi scripts to compile
local nsi_scripts = {
	"paraworld_installer_v1.nsi",
}

-- zip packages to convert from source zip to destination pkg file
local zip_packages = {};

local function CheckString(str)
    return (type(str)=="string" and string.len(str)>0);
end

function BuildParaWorld.AddBuildProfile(name, profile)
    local checkPassed = false;
    if CheckString(name) and type(profile)=="table" and CheckString(profile.src) and CheckString(profile.dest) and type(profile.txtPathList)=="table" and #(profile.txtPathList)>0 then
        checkPassed = true;
        for i,v in ipairs(profile.txtPathList) do
            if not CheckString(v) then
                checkPassed = false;
            end
        end
    end
    if checkPassed then
        zip_packages[name] = profile;
    else
        if CheckString(name) then
            LOG.std(nil, "error", "cellfy", "BuildParaWorld.AddBuildProfile: profile %s syntax error", name);
        else
            LOG.std(nil, "error", "cellfy", "BuildParaWorld.AddBuildProfile: invalid name");
        end
    end
end

function BuildParaWorld.InitBuildProfiles()
    -- release build: main package
    BuildParaWorld.AddBuildProfile("main", {src="installer/main.zip", dest="installer/main.pkg", txtPathList={"packages/redist/main_script-1.0.txt",} }); 
	BuildParaWorld.AddBuildProfile("main_teen", {src="installer/main_teen.zip", dest="main_teen.pkg", txtPathList={"packages/redist/main_script-1.0.teen.txt",} });
	BuildParaWorld.AddBuildProfile("main_commonlib", {src="installer/main_commonlib.zip", dest="installer/main_commonlib.pkg", txtPathList={"packages/redist/main_commonlib.txt",} });   
    BuildParaWorld.AddBuildProfile("main_append", {src="installer/main_append.zip", dest="installer/main_append.pkg", txtPathList={"packages/redist/main_script_append-1.0.txt",} });
    BuildParaWorld.AddBuildProfile("main_complete", {src="installer/main_complete.zip", dest="installer/main_complete.pkg", txtPathList={"packages/redist/main_script_complete-1.0.txt",} });
    BuildParaWorld.AddBuildProfile("main_complete_mobile", {src="installer/main_full_mobile.zip", dest="installer/main_full_mobile.pkg", txtPathList={"packages/redist/main_script_complete_mobile-1.0.txt",} });
	BuildParaWorld.AddBuildProfile("main_src", {src="installer/main_src.zip", dest="installer/main_src.pkg", txtPathList={"packages/redist/main_script_complete_mobile_src-1.0.txt",} });
    -- resource file for mobile platform
    BuildParaWorld.AddBuildProfile("main_mobile_res", {src="installer/main_mobile_res.zip", dest="installer/main_mobile_res.pkg", txtPathList={"packages/redist/main_mobile_res-1.0.txt",} });
    -- release build: UI textures
    BuildParaWorld.AddBuildProfile("main_texture", {src="installer/main_texture.zip", dest="installer/main_texture.pkg", txtPathList={"packages/redist/main_texture-1.0.txt",} });
    -- release build: art package
    BuildParaWorld.AddBuildProfile("art", {src="installer/art_model_char-1.0.zip", dest="installer/art_model_char-1.0.pkg", txtPathList={"packages/redist/art_model_char-1.0.txt",} });
    --{src="installer/map model-1.0.zip", dest="installer/map_model-1.0.pkg", txtPathList={"packages/redist/map model-1.0.txt",}},
    -- in-house SDK build: main package, it is same as "main"
    BuildParaWorld.AddBuildProfile("main_sdk", {src="installer/main_ui.zip", dest="main.pkg", txtPathList={"packages/redist/main_script-1.0.txt",} });
	-- in-house SDK build: main package
    BuildParaWorld.AddBuildProfile("hellochat", {src="installer/main_hellochat.zip",
                                                 dest="installer/main_hellochat.pkg",
                                                 txtPathList={"packages/redist/main_script-1.0.txt","packages/redist/main_hellochat-1.0.txt", 
                                                              --"packages/redist/art_hellochat-1.0.txt",
                                                              -- these two for demo purposes only
                                                              "packages/redist/art_model_char-1.0.txt",
                                                              "packages/redist/main_texture-1.0.txt",
    } });
    -- in-house SDK build: Taurus
    BuildParaWorld.AddBuildProfile("Taurus", {src = "installer/main_Taurus.zip", 
                                              dest = "installer/main_Taurus.pkg", 
                                              txtPathList = {"packages/redist/main_script-1.0.txt", 
                                                             "packages/redist/art_model_char_Taurus-1.0.txt",
    } });
    -- Aries release build: Aries
    BuildParaWorld.AddBuildProfile("Aries", {src = "installer/main_Aries.zip", 
                                             dest = "installer/main_Aries.pkg", 
                                             txtPathList = {"packages/redist/Aries/main_pkg_append_publish.txt",
    } });
    -- Aries release build: Aries_pipeline
    BuildParaWorld.AddBuildProfile("Aries_pipeline", {src = "installer/main_Aries_pipeline.zip", 
                                                      dest = "installer/main_Aries_pipeline.pkg", 
                                                      txtPathList = {"packages/redist/Aries/main_pkg_pipeline.txt",
    } });
end

-- Build SDK dev packges for in-house usage
-- it will generate a main.pkg file at root SDK directory. However, it only contains script and xml files that are not available on AB source control server. 
function BuildParaWorld.BuildInHouseSDK()
	local error_count = BuildParaWorld.CompileNPLFiles(true)
	BuildParaWorld.MakeZipPackage({"main"})
	BuildParaWorld.EncryptZipFiles({"main"})
	return error_count;
end

-- Build HelloChat/ParaWorldViewer
function BuildParaWorld.BuildParaWorldViewer()
	BuildParaWorld.CompileNPLFiles(true)
	BuildParaWorld.MakeZipPackage({"hellochat"})
	BuildParaWorld.EncryptZipFiles({"hellochat"})
end

-- Build Taurus/ParaEngine SDK
function BuildParaWorld.BuildTaurus()
	BuildParaWorld.CompileNPLFiles(true)
	BuildParaWorld.MakeZipPackage({"Taurus"})
	BuildParaWorld.EncryptZipFiles({"Taurus"})
end

-- Build Aries
function BuildParaWorld.BuildAries()
	local error_count = BuildParaWorld.CompileNPLFiles(true)
	BuildParaWorld.GenerateNormalAriesPublishPkg();
	BuildParaWorld.MakeZipPackage({"Aries"})
	BuildParaWorld.EncryptZipFiles({"Aries"})
	BuildParaWorld.MakeZipPackage({"Aries_pipeline"})
	BuildParaWorld.EncryptZipFiles({"Aries_pipeline"})
	return error_count;
end

-- BuildComplete
function BuildParaWorld.BuildComplete()
	local error_count = BuildParaWorld.CompileNPLFiles(true)
	BuildParaWorld.MakeZipPackage({"main_complete"})
	BuildParaWorld.EncryptZipFiles({"main_complete"})
	return error_count;
end


-- only add source file to pkg file. 
function BuildParaWorld.BuildSrcComplete()
	BuildParaWorld.MakeZipPackage({"main_src"})
	BuildParaWorld.EncryptZipFiles({"main_src"})
	return 0;	
end

-- only add source file to pkg file. 
function BuildParaWorld.BuildTeenComplete()
	BuildParaWorld.MakeZipPackage({"main_teen"})
	BuildParaWorld.EncryptZipFiles({"main_teen"})
	return 0;	
end



-- BuildComplete_Mobile
function BuildParaWorld.BuildComplete_Mobile()
	local error_count = BuildParaWorld.CompileNPLFiles(true)
	BuildParaWorld.MakeZipPackage({"main_complete_mobile"})
	if(not BuildParaWorld.BUILD_FROM_MAC)then
		BuildParaWorld.EncryptZipFiles({"main_complete_mobile"})
	end
	return error_count;
end
-- Build All
function BuildParaWorld.BuildAll()
	local error_count = BuildParaWorld.CompileNPLFiles(true)
	BuildParaWorld.MakeZipPackage({"main", "main_texture", "art"})
	BuildParaWorld.EncryptZipFiles({"main", "main_texture", "art"})
	--BuildParaWorld.RunInstallerScript()
	return error_count;
end

-- build script and textures
function BuildParaWorld.BuildScriptAndTexture()
	local error_count = BuildParaWorld.CompileNPLFiles(true)
	BuildParaWorld.MakeZipPackage({"main", "main_texture"})
	BuildParaWorld.EncryptZipFiles({"main", "main_texture"})
	--BuildParaWorld.RunInstallerScript()
	return error_count;
end


-- %TESTCASE{"BuildParaWorld.CompileNPLFiles", func="commonlib.BuildParaWorld.CompileNPLFiles"}%
function BuildParaWorld.CompileNPLFiles(bStripComments)
	-- compile all files in script directory
	return NPL.CompileFiles("script/*.lua", bStripComments and "-stripcomments", 100); 
end

-- make update package
-- @param files: file list array of filename. if it is lua, it will be automatically compiled to .o file. 
function BuildParaWorld.MakeUpdatePackage(files)
	local error_count = 0;
	local _, file
	for _, file in ipairs(files) do
		if(file:match("%.lua")) then
			-- compile all files in script directory
			error_count = error_count + NPL.CompileFiles("file", nil, 10); 
			file = file:gsub("^(.*)lua$", "bin/%1o");
		end
	end
	return error_count;
	--TODO: make zip, and PKG
end

-- %TESTCASE{"BuildParaWorld.MakeZipPackage", func="commonlib.BuildParaWorld.MakeZipPackage"}%
-- @param options: nil or a table of {true, true, true}, each boolean denotes whether to generate zip_packages at the given index
function BuildParaWorld.MakeZipPackage(options)
	NPL.load("(gl)script/kids/3DMapSystemApp/Assets/PackageMakerPage.lua");
	local PackageMakerPage = Map3DSystem.App.Assets.PackageMakerPage;
	local index, pkgname
	for index, pkgname in ipairs(options) do
		local pkg = zip_packages[pkgname];
		if(pkg) then
			PackageMakerPage.BuildPackageByGroupPath(pkg.txtPathList,pkg.src)
		end	
	end
end

-- %TESTCASE{"BuildParaWorld.EncryptZipFiles", func="commonlib.BuildParaWorld.EncryptZipFiles"}%
function BuildParaWorld.EncryptZipFiles(options)
	local index, pkgname
	for index, pkgname in ipairs(options) do
		local pkg = zip_packages[pkgname];
		if(pkg) then
			ParaAsset.GeneratePkgFile(pkg.src, pkg.dest);
		end	
	end
end

-- %TESTCASE{"BuildParaWorld.RunInstallerScript", func="commonlib.BuildParaWorld.RunInstallerScript"}%
function BuildParaWorld.RunInstallerScript()
	local _, script
	for _, script in ipairs(nsi_scripts) do
		script = ParaIO.GetCurDirectory(0)..script
		script = string.gsub(script, "/", "\\");
		commonlib.log("Running script %s \n", script)
		ParaGlobal.ShellExecute("open", ParaIO.GetCurDirectory(0)..nsimaker_path, script, "", 1); 
	end
end

-- %TESTCASE{"BuildParaWorld.BuildTranslations", func="commonlib.BuildParaWorld.BuildTranslations"}%
function BuildParaWorld.BuildTranslations()
	NPL.load("(gl)script/kids/3DMapSystemApp/Translator/Translator.lua");
	
	---------------------------------------
	-- generate all script translation text
	ParaIO.DeleteFile("script/lang/ParaWorld_script-zhCN.lua")
	local translator = Map3DSystem.App.Translator.Translator:new{
		filePathList = {"script/kids/3DMapSystemApp/", "script/kids/3DMapSystemUI/"},
		--ignoreFilePathList = {"script/lang/"},
		filterList = {"*.lua"},
		--contentFilterList = {"ParaWorld"}, -- search for CommonCtrl.Locale("ParaWorld")
		-- input merge: unused, new record.
		outPutTxtFilePathList = {"script/lang/ParaWorld_script-zhCN.lua",}
	}
	translator:TransFiles();
	
	
	---------------------------------------
	-- generate all mcml page translation text
	
	ParaIO.DeleteFile("script/lang/Paraworld_MCML-zhCN.lua")
	local translator = Map3DSystem.App.Translator.Translator:new{
		filePathList = {"script/kids/3DMapSystemApp/", "script/kids/3DMapSystemUI/"},
		--ignoreFilePathList = {"script/lang/"},
		filterList = {"*.html"},
		--contentFilterList = {"ParaWorld"}, -- search for CommonCtrl.Locale("ParaWorld")
		-- input merge: unused, new record.
		outPutTxtFilePathList = {"script/lang/Paraworld_MCML-zhCN.lua",}
	}
	translator:TransFiles();
end



-- generate file list 
-- @param afterdate: yyyy-MM-DD
-- commonlib.BuildParaWorld.GenerateFileList("config/", "txt", "o", "2009-11-26", "bin/");
function BuildParaWorld.GenerateFileList(input_dir, extension, replace_extension, afterdate, parent, exclude_sub_dirs)
	
	local output_lines = {};
    
	local files = {};
	commonlib.Files.Find(files, input_dir, 30, 100000, "*."..extension);
	
	local _, file;
	for _, file in ipairs(files) do
		
		--file.fileattr 32 -- read access
		--file.fileattr 33 -- read only
		--file.filename
		--file.writedate
		
		local y = string.match(file.writedate, "^(%d+)");
		local m = string.match(file.writedate, "^%d+%-(%d+)");
		local d = string.match(file.writedate, "^%d+%-%d+%-(%d+)");
		
		y = tonumber(y)
		m = tonumber(m)
		d = tonumber(d)
		
		local filedate = string.format("%04d-%02d-%02d", y, m, d);
		if(not afterdate or (filedate > afterdate)) then
			local filename = input_dir..file.filename;
			local isExcluded = false;
			if(exclude_sub_dirs) then
				local _, sub_dir;
				for _, sub_dir in ipairs(exclude_sub_dirs) do
					commonlib.echo({filename, "^"..sub_dir, string.match(filename, "^"..sub_dir)})
					if(string.match(filename, "^"..sub_dir)) then
						isExcluded = true;
					end
				end
			end
			if(not isExcluded) then
				if(string.match(filename, "%."..extension.."$")) then
					-- append to the file table
					if(replace_extension) then
						filename = string.gsub(filename, "%."..extension.."$", "."..replace_extension);
						--string.sub(file.filename)
						--main100316.pkg
					end
					if(parent) then
						filename = parent..filename;
					end
					-- append filename
					table.insert(output_lines, filename);
				end
			end
		end
	end
	
	return output_lines;
	
end

-- generate normal regular pkg package
function BuildParaWorld.GenerateNormalAriesPublishPkg()
	
	local append_filelist = "packages/redist/Aries/main_pkg_append_publish.txt";
    ParaIO.DeleteFile(append_filelist);
    
	local file = ParaIO.open(append_filelist, "w");
	if(file:IsValid() == true) then
		
		local afterdate = "2009-11-26";
		local exclude_dirs = {
			"script/apps/Aries/Pipeline/", 
			"script/apps/Aries/Debug/",
			"script/apps/Aries/Combat/",
		};
		
		local filelines = commonlib.BuildParaWorld.GenerateFileList("script/", "lua", "o", afterdate, "bin/", exclude_dirs);
		local _, writeline;
		for _, writeline in ipairs(filelines) do
			file:WriteString(writeline.."\n");
		end
		
		local filelines = commonlib.BuildParaWorld.GenerateFileList("script/", "html", nil, afterdate, nil, exclude_dirs);
		local _, writeline;
		for _, writeline in ipairs(filelines) do
			file:WriteString(writeline.."\n");
		end
		
		local filelines = commonlib.BuildParaWorld.GenerateFileList("script/", "table", nil, afterdate, nil, exclude_dirs);
		local _, writeline;
		for _, writeline in ipairs(filelines) do
			file:WriteString(writeline.."\n");
		end
		
		local filelines = commonlib.BuildParaWorld.GenerateFileList("script/", "fx", nil, afterdate, nil, exclude_dirs);
		local _, writeline;
		for _, writeline in ipairs(filelines) do
			file:WriteString(writeline.."\n");
		end
		
		file:WriteString("config/*.xml\n");
		file:WriteString("Texture/kidui/main/cursor.tga\n");
		file:WriteString("_emptyworld/worldconfig.txt\n");
		file:WriteString("_emptyworld/flat.raw\n");
		file:WriteString("_emptyworld/flat.txt\n");
		file:WriteString("_emptyworld/*.db\n");
		file:WriteString("script/UIAnimation/*.lua\n");
		file:WriteString("model/scripts/*.lua\n");
		file:WriteString("character/Animation/script/*.lua\n");
		
		file:close();
	end
end

--Run init func
BuildParaWorld.InitBuildProfiles();
