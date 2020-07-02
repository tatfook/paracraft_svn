--[[
Title: Translator page
Author(s): Leio Zhang
Date: 2008/7/8
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Translator/TranslatorPage.lua");
------------------------------------------------------------
]]

-- create class
local TranslatorPage = {translator = nil,};
commonlib.setfield("Map3DSystem.App.Translator.TranslatorPage", TranslatorPage)
-----------------------------read event
function TranslatorPage.StartReadFileEvent()
	local document = TranslatorPage.document;
	local pageCtrl = document:GetPageCtrl();
	local txt = pageCtrl:GetUIValue("output_txt")
	txt = txt.."开始查找以下文件：\n";
	pageCtrl:SetUIValue("output_txt",txt);	
	pageCtrl:SetUIValue("progressbar",0 );
	pageCtrl:SetUIValue("progress_result","0%" );
	
end
function TranslatorPage.ProgressReadFileEvent(index,len,path)
	--commonlib.echo({index,len,path});
	local document = TranslatorPage.document;
	local pageCtrl = document:GetPageCtrl();
	local txt = pageCtrl:GetUIValue("output_txt")
	txt = txt..path.."\n";
	pageCtrl:SetUIValue("output_txt",txt);	
	local v = 100*index/len 
	pageCtrl:SetUIValue("progressbar",v);
	pageCtrl:SetUIValue("progress_result",v.."%" );
end
function TranslatorPage.EndReadFileEvent(len,resultLen)
	local document = TranslatorPage.document;
	local pageCtrl = document:GetPageCtrl();
	local txt = pageCtrl:GetUIValue("output_txt")
	txt = txt.."查找了"..len.."个文件，";
	txt = txt.."共"..resultLen.."个有中文字符！ \n";
	pageCtrl:SetUIValue("output_txt",txt);	
	
	pageCtrl:SetUIValue("progressbar",100 );
	pageCtrl:SetUIValue("progress_result","100%" );
end
-----------------------------write event
function TranslatorPage.StartWriteFileEvent()
	local document = TranslatorPage.document;
	local pageCtrl = document:GetPageCtrl();
	local txt = pageCtrl:GetUIValue("output_txt_write")
	txt = txt.."开始汉化以下文件：\n";
	pageCtrl:SetUIValue("output_txt_write",txt);	
	pageCtrl:SetUIValue("progressbar_write",0 );
	pageCtrl:SetUIValue("progress_result_write","0%" );
	
end
function TranslatorPage.ProgressWriteFileEvent(index,len,path)
	--commonlib.echo({index,len,path});
	local document = TranslatorPage.document;
	local pageCtrl = document:GetPageCtrl();
	local txt = pageCtrl:GetUIValue("output_txt_write")
	txt = txt..path.."\n";
	pageCtrl:SetUIValue("output_txt_write",txt);	
	local v = 100*index/len 
	pageCtrl:SetUIValue("progressbar_write",v);
	pageCtrl:SetUIValue("progress_result_write",v.."%" );
end
function TranslatorPage.EndWriteFileEvent(len)
	local document = TranslatorPage.document;
	local pageCtrl = document:GetPageCtrl();
	local txt = pageCtrl:GetUIValue("output_txt_write")
	txt = txt.."完成："..len.."个文件的汉化！\n";
	pageCtrl:SetUIValue("output_txt_write",txt);	
	
	pageCtrl:SetUIValue("progressbar_write",100 );
	pageCtrl:SetUIValue("progress_result_write","100%" );
end

function TranslatorPage.OnInit()
	TranslatorPage.document = document;
	local pageCtrl = document:GetPageCtrl();
	if(not TranslatorPage.translator)then
		NPL.load("(gl)script/kids/3DMapSystemApp/Translator/Translator.lua");
		TranslatorPage.translator = Map3DSystem.App.Translator.Translator:new();
		
		TranslatorPage.translator.StartReadFileEvent = TranslatorPage.StartReadFileEvent;
		TranslatorPage.translator.ProgressReadFileEvent = TranslatorPage.ProgressReadFileEvent;
		TranslatorPage.translator.EndReadFileEvent = TranslatorPage.EndReadFileEvent;
		
		TranslatorPage.translator.StartWriteFileEvent = TranslatorPage.StartWriteFileEvent;
		TranslatorPage.translator.ProgressWriteFileEvent = TranslatorPage.ProgressWriteFileEvent;
		TranslatorPage.translator.EndWriteFileEvent = TranslatorPage.EndWriteFileEvent;
	end
	TranslatorPage.translator:Init();
	local filebrowserCtl = document:GetPageCtrl():FindControl("FileBrowser");
	if(filebrowserCtl) then
		filebrowserCtl:ResetTreeView();
		local dest = {};
		filebrowserCtl:SetCheckedPathList(dest);
	end
	local output_txt = document:GetPageCtrl():FindControl("output_txt");
	if(output_txt) then
		pageCtrl:SetUIValue("output_txt","");	
	end
	local output_txt_write = document:GetPageCtrl():FindControl("output_txt_write");
	if(output_txt_write) then
		pageCtrl:SetUIValue("output_txt_write","");	
	end
	local progressbar = document:GetPageCtrl():FindControl("progressbar");
	if(progressbar) then
		pageCtrl:SetUIValue("progressbar",0);	
	end
	local progressbar_write = document:GetPageCtrl():FindControl("progressbar_write");
	if(progressbar_write) then
		pageCtrl:SetUIValue("progressbar_write",0);	
	end
	local progress_result = document:GetPageCtrl():FindControl("progress_result");
	if(progress_result) then
		pageCtrl:SetUIValue("progress_result","");	
	end
	local progress_result_write = document:GetPageCtrl():FindControl("progress_result_write");
	if(progress_result_write) then
		pageCtrl:SetUIValue("progress_result_write","");	
	end
end
-- User clicks a file
function TranslatorPage.OnSelectFile(name, filepath)
end

-- user selects a new folder
function TranslatorPage.OnSelectFolder(name, folderPath)
	local document = TranslatorPage.document;
	local filebrowserCtl = document:GetPageCtrl():FindControl("FileBrowser");
	if(filebrowserCtl and folderPath) then
		filebrowserCtl.rootfolder = folderPath;		
		filebrowserCtl:ResetTreeView();
		local dest = {};
		filebrowserCtl:SetCheckedPathList(dest);
		filebrowserCtl.LastClickedNode = nil;
	end
end
-- user selects a new filter
function TranslatorPage.OnSelectFilter(name, filter)
	local document = TranslatorPage.document;
	local filebrowserCtl = filebrowserCtl or document:GetPageCtrl():FindControl("FileBrowser");
	if(filebrowserCtl and filter) then
		filebrowserCtl.filter = filter;	
		filebrowserCtl:ResetTreeView();
		local dest = {};
		filebrowserCtl:SetCheckedPathList(dest);
	end
end
function TranslatorPage.OnPackageStep(mcmlNode, step)
	ParaEngine.ForceRender(); ParaEngine.ForceRender();
end
function TranslatorPage.DoSave()
	if(not TranslatorPage.translator)then return; end
	local document = TranslatorPage.document;
	local pageCtrl = document:GetPageCtrl();
	
	local txtfileName = pageCtrl:GetUIValue("txtfileName");
	local txtfilePath = pageCtrl:GetUIValue("txtfilePath");
	local filebrowserCtl = pageCtrl:FindControl("FileBrowser");
	--local filter = filebrowserCtl.filter;
	local filter = pageCtrl:GetUIValue("CurFilter");
	local checkedPathList = filebrowserCtl.CheckedPathList;
	
	local txt = "";
	txt = txt.."txtfileName:"..txtfileName.."\n";
	txt = txt.."txtfilePath:"..txtfilePath.."\n";
	txt = txt.."filter:"..filter.."\n";
	txt = txt.."---------------------\n";
	local k,v;
	for k,v in pairs(checkedPathList) do
		txt = txt..v.."\n";
	end
	txt = txt.."---------------------\n";
	pageCtrl:SetUIValue("output_txt",txt);	
	
	local filePathList,filterList,outPutTxtFilePath;
	-- outPutTxtFilePath
	outPutTxtFilePath = txtfilePath.."/"..txtfileName;
	-- filePathList
	filePathList = {}
	for k,v in pairs(checkedPathList) do
		local path= v.."/";
		table.insert(filePathList,path);
	end
	-- filterList
	filterList = {};
	local f;
	for f in string.gfind(filter, "([^%s;]+)") do
		table.insert(filterList,f);
	end
	TranslatorPage.translator.filePathList = filePathList;
	TranslatorPage.translator.filterList = filterList;
	TranslatorPage.translator.outPutTxtFilePathList = {outPutTxtFilePath,"script/lang/test-zhCN.lua","script/lang/test-enUS.lua"}
	TranslatorPage.translator.ignoreFilePathList = {"script/lang/"};
	TranslatorPage.translator.contentFilterList = {"IDE", "Kids3DMap"}
	TranslatorPage.translator:TransFiles();
	
end
-- use clicks to open a new folder
function TranslatorPage.NewPkgSelectFolder(name, filter)
	local document = TranslatorPage.document;
	NPL.load("(gl)script/ide/OpenFolderDialog.lua");
	local dialog = CommonCtrl.OpenFolderDialog:new();
	local pageCtrl = document:GetPageCtrl();
	dialog.OnSelected = function (sCtrlName,path)
			
		pageCtrl:SetUIValue("txtfilePath",path);	
	end;
	dialog:Show();
end

function TranslatorPage.DoWrite()
	if(not TranslatorPage.translator)then return; end
	TranslatorPage.translator:Do_writeIn();
end