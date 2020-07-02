--[[
Title: ScriptPanelPage 
Author(s): Leio
Date: 2008/10/29
Note: 
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/PropertyPanel/ScriptPanelPage.lua");
-------------------------------------------------------
--]]
local ScriptPanelPage = {
	name = "ScriptPanelPage_instance",
	TargetProperty = nil,
}
commonlib.setfield("Map3DSystem.Movie.ScriptPanelPage",ScriptPanelPage);
function ScriptPanelPage.OnInit()
	local self = ScriptPanelPage;
	self.page = document:GetPageCtrl();	
	
end
function ScriptPanelPage.DataBind(layer)
	local self = ScriptPanelPage;
	if(not layer or not self.page)then return; end
	self.TargetProperty = nil;
	self.OnClearTxt()
	local keyFrames = layer:GetChild(1);
	if(not keyFrames)then return; end
	self.layer = layer;
	self.keyFrames = keyFrames;
	
	local TargetName,TargetProperty = keyFrames.TargetName,keyFrames.TargetProperty;
	local txt;
	if(TargetName == "CaptionTarget" or TargetProperty == "CaptionTarget")then
		txt = self.CaptionAdapter(keyFrames);
		self.TargetProperty = TargetProperty;
	else
		txt = keyFrames:ReverseToMcml();
	end
	self.SetTxt(txt)
end
function ScriptPanelPage.OnUpdateProperty()
	local self = ScriptPanelPage;
	if(not self.layer or not self.page)then return; end	
	local _txt = self.GetTxt()
	local node = self.layer["ParentMcmlNode"];	
	if(_txt and node)then
		local valueNode = node:GetChild("value");
		if(valueNode)then
			local __KeyFrames__Node = valueNode:GetChild("__KeyFrames__Node");
			if(__KeyFrames__Node)then
				local frames;
				if(self.TargetProperty)then
					frames = CommonCtrl.Animation.Reverse.LrcToMcml_2(_txt);
				else
					frames = ParaXML.LuaXML_ParseString(_txt);
					frames = Map3DSystem.mcml.buildclass(frames);
					frames = frames[1];
					frames = Map3DSystem.Movie.mcml_controls.create(frames);
				end
				
				if(frames)then				
					self.layer:RemoveChildByIndex(1);
					self.layer:AddChild(frames,1);
					self.layer:Draw();
					__KeyFrames__Node["KeyFrames"] = frames;
					self.OnClose();
				end
			end
		end
	end
end
function ScriptPanelPage.CaptionAdapter(keyFrames)
	if(not keyFrames)then return; end
	local result = "";
	local list = keyFrames.keyframes;
	if(list)then
		for __,frame in ipairs(list) do
			local keyTime = frame:GetKeyTime();
			local target = frame:GetValue();
			local txt = target.Text
			local s = string.format("[%s]%s",keyTime,txt);
			result = result..s.."\r\n";		
		end 
	end
	return result;
end
function ScriptPanelPage.SetTxt(txt)
	if(not txt)then return; end
	local self = ScriptPanelPage;
	local _txt = self.page:FindControl("_txt");
	if(_txt)then
		_txt:SetText(txt);
	end	
end
function ScriptPanelPage.GetTxt()
	local self = ScriptPanelPage;
	local _txt = self.page:FindControl("_txt");
	if(_txt)then
		_txt = _txt:GetText();
		return _txt;
	end	
end
function ScriptPanelPage.OnClearTxt()
	ScriptPanelPage.SetTxt("");
end
function ScriptPanelPage.OnCopy()
	local self = ScriptPanelPage;
	local txt = self.GetTxt()
	if(txt)then
		ParaMisc.CopyTextToClipboard(txt);
	end
end
function ScriptPanelPage.Show(layer,width,height)
	if(not layer)then return; end
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	width = width or 640;
	height = height or 400;
	NPL.load("(gl)script/kids/3DMapSystemUI/Movie/PropertyPanel/ScriptPanelPage.lua");
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/Movie/PropertyPanel/ScriptPanelPage.html", name="ScriptPanelPage_instance", 
			app_key=MyCompany.Apps.VideoRecorder.app.app_key, 
			text = "代码编辑器",
			isShowTitleBar = true, 
			isShowToolboxBar = false, 
			isShowStatusBar = false, 
			isShowMinimizeBox = false,
			isShowCloseBox = true,
			allowResize = false,
			initialPosX = (screenWidth-width)/2,
			initialPosY = (screenHeight-height)/2,
			initialWidth = width,
			initialHeight = height,
			bToggleShowHide = false,
			bShow = true,
			DestroyOnClose = false,
		});
	Map3DSystem.Movie.ScriptPanelPage.DataBind(layer);
end
function ScriptPanelPage.OnClose()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
	name="ScriptPanelPage_instance", 
		app_key=MyCompany.Apps.VideoRecorder.app.app_key, 	
		bShow = false,bDestroy = false,
	});
end