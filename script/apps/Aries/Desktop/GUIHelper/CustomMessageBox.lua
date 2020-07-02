--[[
Title: 
Author(s): Leio
Date: 2009/12/15
See Also: script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
_guihelper.CloseCustom_MessageBox();
_guihelper.Custom_MessageBox("hello",function(result)
	if(result == _guihelper.DialogResult.Yes)then
		commonlib.echo("yes");
	else
		commonlib.echo("no");
	end
end,_guihelper.MessageBoxButtons.YesNo);


NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
_guihelper.Custom_MessageBox("hello",function(result)
	if(result == _guihelper.DialogResult.Yes)then
		commonlib.echo("yes");
	else
		commonlib.echo("no");
	end
end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Cancel_32bits.png; 0 0 153 49"});

NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
_guihelper.Custom_MessageBox("hello",function(result)
	if(result == _guihelper.DialogResult.Yes)then
		commonlib.echo("yes");
	else
		commonlib.echo("no");
	end
end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/Coming_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});

NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
_guihelper.Custom_MessageBox("hello",function(result)
	if(result == _guihelper.DialogResult.OK)then
		commonlib.echo("OK");
	end
end,_guihelper.MessageBoxButtons.OK);

NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
_guihelper.Custom_MessageBox("hello",function(result)
	if(result == _guihelper.DialogResult.OK)then
		commonlib.echo("OK");
	end
end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});

NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
_guihelper.Custom_MessageBox("hello",function(result)
	if(result == _guihelper.DialogResult.OK)then
		commonlib.echo("OK");
	end
end,_guihelper.MessageBoxButtons.OK,{show_label = true, ok = "确定"});

NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
_guihelper.Custom_MessageBox("hello",function(result)
	if(result == _guihelper.DialogResult.Yes)then
		commonlib.echo("yes");
	else
		commonlib.echo("no");
	end
end,_guihelper.MessageBoxButtons.YesNo,{show_label = true, yes = "查看家族列表", no = "取消"});

NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
MyCompany.Aries.Theme.Default:Load();
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
QuestHelp.is_kids_version = false;
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/gui_helper.lua");
NPL.load("(gl)script/ide/MessageBox.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local CustomMessageBox = commonlib.gettable("_Custom.CustomMessageBox");
commonlib.partialcopy(CustomMessageBox, {
	content = nil,
	MsgBoxClick_CallBack = nil,
	buttons = nil,
	--[[
		{
			yes = "",
			no = "",
			ok = "",
		}
	--]]
	customBtnIcon = nil,
});


function CustomMessageBox.Show(content,MsgBoxClick_CallBack, buttons,customBtnIcon,zorder_input, isNotTopLevel)
	local self = CustomMessageBox;
	if(not content) then
		self.ClosePage()
	end
	if(type(content)~="string") then
		content = commonlib.serialize(content);
	end
	
	buttons = buttons or _guihelper.MessageBoxButtons.OK;
	if(buttons ==  _guihelper.MessageBoxButtons.OK)then
		if(not customBtnIcon)then
			customBtnIcon = {ok = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49"};
		end
	end
	if(buttons ==  _guihelper.MessageBoxButtons.YesNo)then
		if(not customBtnIcon)then
			customBtnIcon = {yes = "Texture/Aries/Common/Yes_32bits.png; 0 0 153 49" , no = "Texture/Aries/Common/No_32bits.png; 0 0 153 49"};
		end
	end
	
	self.content = content;
	self.MsgBoxClick_CallBack = MsgBoxClick_CallBack;
	self.buttons = buttons;
	self.customBtnIcon = customBtnIcon;

	if (not zorder_input) then
		zorder_input = 1000
	end

	local isTopLevel = true;
	if(isNotTopLevel) then
		isTopLevel = false;
	end
	local width = 400;
	local height = 400;
	local url = "script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.html";
	if(not QuestHelp.IsKidsVersion())then
		url = "script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.teen.html"
		width = 340;
		height = 175;
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = url, 
			name = "CustomMessageBox.ShowTxt", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = zorder_input,
			isTopLevel = isTopLevel,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -width / 2,
				y = -height / 2,
				width = width,
				height = height,
		});
end
function CustomMessageBox.OnMessageBoxClick(editorInstName)
	local self = CustomMessageBox;
	local result = _guihelper.DialogResult.OK;
	if(editorInstName == "OK")then
		result = _guihelper.DialogResult.OK;
	elseif(editorInstName == "Yes")then
		result = _guihelper.DialogResult.Yes;
	elseif(editorInstName == "No")then
		result = _guihelper.DialogResult.No;
	end
	self.ClosePage()
	if(self.MsgBoxClick_CallBack and type(self.MsgBoxClick_CallBack) == "function")then
		self.MsgBoxClick_CallBack(result);
	end
end
function CustomMessageBox.ClosePage()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="CustomMessageBox.ShowTxt", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
end
if(_guihelper==nil) then _guihelper={} end
_guihelper.Custom_MessageBox = CustomMessageBox.Show;
_guihelper.CloseCustom_MessageBox = CustomMessageBox.ClosePage;