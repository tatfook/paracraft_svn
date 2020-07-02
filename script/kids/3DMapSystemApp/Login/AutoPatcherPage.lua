--[[
Title: AutoPatcherPage.html code-behind script
Author(s): LiXizhi
Date: 2008/7/24
Desc: 
---++ using autopatch to update to laset version
Auto Patcher is an mcml application page to auto patch a given list of files to their latest version. 
One can specify the src patch files url and the destination (local patch file) as below.
<verbatim>
	script/kids/3DMapSystemApp/Login/AutoPatcherPage.html?src=http://files.pala5.com/patchfiles.txt&dest=patchfiles.txt
</verbatim>

The patchfiles.txt contains a list of patch files and their patch versions. below is an example
<verbatim>
version=1.0.0.3, "/"
version=1.0.0.2, "c:/versions/1.0.0.2/"
version=1.0.0.1, "c:/versions/1.0.0.1/"
version=1.0.0.0, "c:/versions/1.0.0.0/"
defaultserver=http://files.pala5.com

files
4 "/patches_1_0_0_3/packages/startup/art_model_char-1.0(3_to_4).patch" "packages/startup/art_model_char-1.0.pkg"
3 "/patches_1_0_0_3/packages/startup/art_model_char-1.0(2_to_3).patch" "packages/startup/art_model_char-1.0.pkg"
2 "/patches_1_0_0_3/packages/startup/art_model_char-1.0(1_to_2).patch" "packages/startup/art_model_char-1.0.pkg"
2 "/patches_1_0_0_3/main(1_to_2).patch" "main.pkg"
2 "/patches_1_0_0_3/paraworld(1_to_2).patch" "paraworld.exe"
1 "" "readme.txt"

</verbatim>
   * version mean that it is able to upgrade from any versions from 1.0.0.0 to 1.0.0.3, the second parameter is the src folder where to locate the src files for that version.
   * defaultserver is the root directory of remote patch files. 
   * each file line contains file_version_after_patching  remote_patch_file_url local_file_to_patch
   * please note that file_version_after_patching is always an integer and there might be multiple patch files for the same dest file with decreasing file version as in the example.
   * if file_version_after_patching is 1, it means that it is the original (initial) version and the patch file is always empty. 

---++ generate autopatch files
one can generate patch files from a previous patch file. It will include all file patches from the previous patch plus their newest versions
for example, the initial patch file may contain just a list of files that are tracked for patching. such as 

<verbatim>
version=1.0.0.0, "/"
defaultserver=http://files.pala5.com

files
1 "" "packages/startup/art_model_char-1.0.pkg"
1 "" "main.pkg"
1 "" "paraworld.exe"
1 "" "readme.txt"
</verbatim>

<verbatim>
version=1.0.0.1, "/"
version=1.0.0.0, "c:/versions/1.0.0.0/"
defaultserver=http://files.pala5.com

files
1 "" "packages/startup/art_model_char-1.0.pkg"
1 "" "main.pkg"
1 "" "paraworld.exe"
1 "" "readme.txt"
</verbatim>

---++ patching procedure
When the platform start, it first checks the server version to see if the client is up to date. 
If not, it will download a patch (index) file to a temp location. If the latest patch file can upgrade from the local patch file, then we will apply the patch. 
Otherwise we will inform the user to download the major installer.

use the lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Login/AutoPatcherPage.lua");
script/kids/3DMapSystemApp/Login/AutoPatcherPage.html?src=http://192.168.0.221:8111/testPatch/patchfiles.xml
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemApp/Login/AutoPatcher.lua");
local AutoPatcherPage = {
	-- 将要更新的配置文件 "http://files.pala5.com/patchfiles.xml"
	src = nil,
	-- 下载最新的配置文件到本地
	localSrc = "temp/autopatcher/localSrc_temp.xml",
	-- 前一个版本的配置文件 if dest=nil then dest = "patchfiles.xml";
	dest = nil,
	autoPatcher = nil,
	canUpdate = false,
};
commonlib.setfield("Map3DSystem.App.Login.AutoPatcherPage", AutoPatcherPage)

-- Creating the patch file(s)
-- Make sure you have the source file (original version) and the target file (version to update to). For example, I have DATA.DTA (currently on user system) and DATA_20.DTA (v2.0 of this data file). Now call GenPat.exe:
-- GENPAT (sourcefile) (targetfile) (patchfile)
local GenPat_path = "script/bin/VPatch/GenPat.exe"
local VAppend_path = "script/bin/VPatch/VAppend.exe"
-- stand-alone runtime and patch
-- VPATCHPROMPT.EXE (patchfile) (sourcefile) (outputfile)
local vpatchprompt_path = "script/bin/VPatch/vpatchprompt.exe"
function AutoPatcherPage.singleFileProgressEvent(src,percent)
	local document = AutoPatcherPage.document;
	local pageCtrl = document:GetPageCtrl();
	pageCtrl:SetUIValue("progressbar",percent);
	pageCtrl:SetUIValue("progress_result","正在下载"..src.."  "..percent.."%");
end
function AutoPatcherPage.singleFileErrorEvent(src)
	local document = AutoPatcherPage.document;
	local pageCtrl = document:GetPageCtrl();
	pageCtrl:SetUIValue("progress_result","出错:"..src);
end
function AutoPatcherPage.singleFileCompleteEvent(src)
	AutoPatcherPage.SetResultTxt("下载完成："..src)
end
function AutoPatcherPage.allFilesCompleteEvent()
	local document = AutoPatcherPage.document;
	local pageCtrl = document:GetPageCtrl();
	pageCtrl:SetUIValue("progressbar",100);
	pageCtrl:SetUIValue("progress_result","");
	AutoPatcherPage.SetResultTxt("下载全部完成！");
	if(AutoPatcherPage.autoPatcher)then
	AutoPatcherPage.autoPatcher:Patchfiles();
	end
end
-- patchfilesCompleteEvent
function AutoPatcherPage.patchfilesCompleteEvent()
	AutoPatcherPage.canUpdate = true;
	AutoPatcherPage.SetResultTxt("匹配完成！");
end
function AutoPatcherPage.copyCompleteEvent()
	AutoPatcherPage.SetResultTxt("升级成功！");
	AutoPatcherPage.autoPatcher:SaveLatestUpdatedConfigFiles();
	AutoPatcherPage.canUpdate = false;
end
function AutoPatcherPage.OnInit()
	AutoPatcherPage.document = document;
	AutoPatcherPage.pageCtrl = document:GetPageCtrl();
	local pageCtrl = document:GetPageCtrl();
	AutoPatcherPage.src = pageCtrl:GetRequestParam("src");
	AutoPatcherPage.dest = pageCtrl:GetRequestParam("dest")
	AutoPatcherPage.canUpdate = false;
	if(not AutoPatcherPage.dest)then
		AutoPatcherPage.dest = "patchfiles.xml";
	end
	if(not AutoPatcherPage.autoPatcher)then
		AutoPatcherPage.autoPatcher = Map3DSystem.App.Login.AutoPatcher:new();
		
		AutoPatcherPage.autoPatcher.singleFileProgressEvent = AutoPatcherPage.singleFileProgressEvent;
		AutoPatcherPage.autoPatcher.singleFileErrorEvent = AutoPatcherPage.singleFileErrorEvent;
		AutoPatcherPage.autoPatcher.singleFileCompleteEvent = AutoPatcherPage.singleFileCompleteEvent;	
		AutoPatcherPage.autoPatcher.allFilesCompleteEvent = AutoPatcherPage.allFilesCompleteEvent;	
		AutoPatcherPage.autoPatcher.patchfilesCompleteEvent = AutoPatcherPage.patchfilesCompleteEvent;	
		AutoPatcherPage.autoPatcher.copyCompleteEvent = AutoPatcherPage.copyCompleteEvent;
	end
	AutoPatcherPage.autoPatcher.localUpdateConfig = AutoPatcherPage.dest;
	AutoPatcherPage.autoPatcher:Init();
end
-- GetRemoteSrc src=http://192.168.0.221:8111/testPatch/patchfiles.xml
function AutoPatcherPage.GetRemoteSrc()
	if(not AutoPatcherPage.src or not AutoPatcherPage.autoPatcher)then return; end
	local ls = AutoPatcherPage.autoPatcher.localserver;
	if(not ls)then return; end
	local cachepolicy = "access plus 0";
	local src = AutoPatcherPage.src;
	local dest = AutoPatcherPage.localSrc;
	ls:GetFile(System.localserver.CachePolicy:new(cachepolicy),
			src,
			function (entry)
				if(ParaIO.CopyFile(entry.payload.cached_filepath, dest, true)) then
					--"complete";
					AutoPatcherPage.SetResultTxt("下载完成："..src)
					AutoPatcherPage.SetDownloadListTxt()
				else
					--"error";	
					AutoPatcherPage.SetResultTxt("下载出错："..src)
				end	
			end,
			nil,
			function (msg, url)
				if(msg.DownloadState == "") then
					--downloading
					--if(msg.totalFileSize) then
						--local percent = math.floor(msg.currentFileSize/msg.totalFileSize);
					--end
				elseif(msg.DownloadState == "complete") then
				elseif(msg.DownloadState == "terminated") then
				end
			end
		);
end
function AutoPatcherPage.Reset()
	local document = AutoPatcherPage.document;
	local pageCtrl = document:GetPageCtrl();
	pageCtrl:SetUIValue("output_txt","");	
	pageCtrl:SetUIValue("progressbar",0);
	pageCtrl:SetUIValue("progress_result","");
	
	AutoPatcherPage.autoPatcher:Init();
	AutoPatcherPage.GetRemoteSrc();
end
-- DownloadPatchfiles
function AutoPatcherPage.SetDownloadListTxt()
	local list = AutoPatcherPage.autoPatcher:GetDownloadList(AutoPatcherPage.dest,AutoPatcherPage.localSrc);
	local k,v;		
	if(not list)then
		AutoPatcherPage.SetResultTxt("目前已经是最新版本！")
		return;
	end		
	if(type(list)=="table" and table.getn(list)>0)then
		AutoPatcherPage.SetResultTxt("要下载更新的文件为：")
		for k,v in ipairs(list) do
			local patchfile =AutoPatcherPage.autoPatcher.domain..v["patchfile"];
			AutoPatcherPage.SetResultTxt(patchfile)
		end
		AutoPatcherPage.autoPatcher:DownloadPatchfiles();
	else
		AutoPatcherPage.SetResultTxt("目前已经是最新版本！")
	end	
end
function AutoPatcherPage.SetResultTxt(v)
	local document = AutoPatcherPage.document;
	local pageCtrl = document:GetPageCtrl();
	local txt = pageCtrl:GetUIValue("output_txt")
	if(not txt)then txt =""; end
	txt = txt..v.."\n";
	pageCtrl:SetUIValue("output_txt",txt);	
end
function AutoPatcherPage.OnPackageStep(mcmlNode, step)
	ParaEngine.ForceRender(); ParaEngine.ForceRender();
end
-- check the latest version,if it is not latest version,it will download the latest pathfiles from remote server
function AutoPatcherPage.DoUpdate()
	AutoPatcherPage.Reset();
end
-- if it has the latest pathfiles and those pathfiles had been deal with,copy pkgs to new version
function AutoPatcherPage.DoMerge()
	if(AutoPatcherPage.canUpdate)then
		AutoPatcherPage.autoPatcher:CopyToNewVersion();
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- on click generate patch
function AutoPatcherPage.OnClickGeneratePatch(btnName, values)
	AutoPatcherPage.GeneratePatchFiles()
end

-- generate patch files
-- @param patchfile: file path of the patch file
-- @param destfolder: to which folder the patch files are generated. 
function AutoPatcherPage.GeneratePatchFiles(patchfile, destfolder)
	-- this just an example by LiXizhi
	local patchfile = "readme(1_to_2).patch"
	ParaIO.DeleteFile(patchfile);
	
	-- for each file
	local src = "readme.txt"
	--local target = "c:/versions/1.0.0.0/"..src; 
	local target = "test.txt"
	local script = string.format("%s %s %s", ParaIO.GetCurDirectory(0)..src, ParaIO.GetCurDirectory(0)..target, ParaIO.GetCurDirectory(0)..patchfile);
	script = string.gsub(script, "/", "\\");
	commonlib.log("generating patch file %s \n", src)
	ParaGlobal.ShellExecute("open", ParaIO.GetCurDirectory(0)..GenPat_path, script, nil, 1); 
end

-- on click generate patch
function AutoPatcherPage.OnClickApplyPatch(btnName, values)
	AutoPatcherPage.ApplyPatchFiles()
end

-- generate patch files
-- @param patchfile: file path of the patch file
function AutoPatcherPage.ApplyPatchFiles(patchfile)
	-- this is just an example by LiXizhi
	local src = "readme(1_to_2).patch"
	local target = "readme.txt"
	local patchfile = "temp/temp_patch_target.txt"
	local script = string.format("%s %s %s", ParaIO.GetCurDirectory(0)..src, ParaIO.GetCurDirectory(0)..target, ParaIO.GetCurDirectory(0)..patchfile);
	script = string.gsub(script, "/", "\\");
	commonlib.log("patching file %s \n", src)
	ParaGlobal.ShellExecute("open", ParaIO.GetCurDirectory(0)..vpatchprompt_path, script, "", 1); 
end
