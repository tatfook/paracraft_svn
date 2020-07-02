--[[
Title: code behind page for TranslateFilePage.html
Author(s): LiXizhi
Date: 2008/8/28
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Developers/TranslateFilePage.lua");
-------------------------------------------------------
]]
local L = CommonCtrl.Locale("ParaWorld");
NPL.load("(gl)script/kids/3DMapSystemApp/Translator/Translator.lua");

local TranslateFilePage = {};
commonlib.setfield("Map3DSystem.App.Developers.TranslateFilePage", TranslateFilePage)

---------------------------------
-- page event handlers
---------------------------------

-- init
function TranslateFilePage.OnInit()
	local self = document:GetPageCtrl();

	local files = Map3DSystem.App.Developers.app:ReadConfig("RecentlyTranslatedFiles", {})
	local index, value
	for index, value in ipairs(files) do
		self:SetNodeValue("filepath", value);
	end
	self:SetNodeValue("filepath", "");
end

-- the current translator
local translator;

-- translate the file
function TranslateFilePage.OnTranslateFile(btnName, values)
	local self = document:GetPageCtrl();
	local filepath = values["filepath"]
	if(filepath~=nil and filepath ~= "" and ParaIO.DoesFileExist(filepath)) then
		---------------------------------
		-- save to recently opened files
		local worlds = Map3DSystem.App.Developers.app:ReadConfig("RecentlyTranslatedFiles", {})
		local bNeedSave;
		-- sort by order
		local index, value, found
		for index, value in ipairs(worlds) do
			if(value == filepath) then
				if(index>1) then
					commonlib.moveArrayItem(worlds, index, 1)
					bNeedSave = true;
				end	
				found = true;
				break;
			end
		end
		if(not found) then
			commonlib.insertArrayItem(worlds, 1, filepath)
			bNeedSave = true;
		end
		if(bNeedSave) then
			if(#worlds>50) then
				commonlib.resize(worlds, 50)
			end
			Map3DSystem.App.Developers.app:WriteConfig("RecentlyTranslatedFiles", worlds)
			Map3DSystem.App.Developers.app:SaveConfig();
		end
	
		---------------------------------
		-- translate the file

		local sParentDir = string.gsub(filepath, "[^/\\]+$", "")
		local sFileName = string.match(filepath, "[^/\\]+$")
		translator = Map3DSystem.App.Translator.Translator:new{
			filePathList = {sParentDir},
			filterList = {sFileName},
		}
		translator:TransFiles();
		
		---------------------------------
		-- update the UI 
		local left_text = translator:GetOutPutString(false, true, false);
		local right_text = left_text; -- translator:GetOutPutString(false, true, true);
		self:SetUIValue("result_left", left_text)
		self:SetUIValue("result_right", right_text)
		
		ParaMisc.CopyTextToClipboard(left_text);
		self:SetUIValue("result", L"结果已经复制到裁剪版中. 你可以Ctrl-V到任何编辑器中")
	else	
		self:SetUIValue("result", L"请选择一个有效的NPL或MCML文件")
	end
end

function TranslateFilePage.OnClickCopyRight()
	local self = document:GetPageCtrl();
	ParaMisc.CopyTextToClipboard(self:GetUIValue("result_right"));
	self:SetUIValue("result", L"结果已经复制到裁剪版中. 你可以Ctrl-V到任何编辑器中")
end

function TranslateFilePage.OnClickCopyLeft()
	local self = document:GetPageCtrl();
	ParaMisc.CopyTextToClipboard(self:GetUIValue("result_left"));
	self:SetUIValue("result", L"结果已经复制到裁剪版中. 你可以Ctrl-V到任何编辑器中")
end

-- write to the source code. 
function TranslateFilePage.OnWriteToSourceFile()
	if(translator) then
		local self = document:GetPageCtrl();
		local filepath = self:GetUIValue("filepath")
		if(string.match(filepath, "%.lua$"))then
			translator:Do_writeIn(true);
			self:SetUIValue("result", L"已经覆盖. 你可以恢复原来文件在temp/tranlated_files/")
		else
			self:SetUIValue("result", L"只有NPL文件才可以生成")
		end	
	end
end

-- I used http://translate.google.com to translate. it is basically http post
function TranslateFilePage.OnMachineTranslate()
	local self = document:GetPageCtrl();
	local text = self:GetUIValue("result_right");
	NPL.load("(gl)script/ide/System/localserver/UrlHelper.lua");
	local srcText;
	
	-- translate one line of text
	local function TranslateNext_()
		srcText = string.match(text, "%[ \"([^\r\n]-)\" %] = true,");
		if(srcText) then
			-- TODO: if there is already an human translation in the locale file, we will use it instead of doing machine translation.
			local body = ParaMisc.EncodingConvert("", "utf-8", srcText);
			body = System.localserver.UrlHelper.url_encode(body)
			local url = "http://translate.google.com/translate_a/t?client=t&sl=zh-CN&tl=en&text="..body;
			--local url = [[http://translate.google.com/translate_a/t?client=t&text=%E4%B8%AD%E6%96%87&sl=zh-CN&tl=en]]
			--commonlib.echo(url);
			self:SetUIValue("result", string.format("http://translate.google.com/translating:%s\n", srcText))
			NPL.AsyncDownload(url, "temp/google_translated.txt", "TranslatorCallback()", "translator");
		else
			self:SetUIValue("result", "translation done by http://translate.google.com in the right window\n")	
			--TranslateFilePage.OnClickCopyRight();
		end
		return srcText;
	end
	
	TranslatorCallback = function ()
		--commonlib.echo(msg);
		if(msg and msg.DownloadState=="complete") then
			local file = ParaIO.open("temp/google_translated.txt", "r");
			if(file:IsValid()) then
				local translatedText = file:GetText();
				-- correct the text. the google translator will translate %s and \n to % s and \ n, so we will remove the blank space.
				translatedText = string.gsub(translatedText, "([\\%%]) ", "%1");
				file:close();
				local from, to, tmp = string.find(text, "(%[ [^\r\n]- %] = )true,");
				if(from and to) then
					text = string.sub(text, 1, from-1)..tmp..translatedText..string.sub(text, to, -1)
					self:SetUIValue("result_right", text);
					TranslateNext_();
				end
			end	
		end	
	end;
	
	-- start translating
	TranslateNext_();
end