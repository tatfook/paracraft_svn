--[[
Title: character property page code behind file
Author(s): LiXizhi
Date: 2008/6/14
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/CharPropertyPage.lua");
Map3DSystem.App.Creator.CharPropertyPage.UpdatePanelUI()
Map3DSystem.App.Creator.CharPropertyPage.OnAssignAIClick(1, "contextmenu")
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("IDE");

local CharPropertyPage = {};
commonlib.setfield("Map3DSystem.App.Creator.CharPropertyPage", CharPropertyPage)
-- singleton page reference. 
local page; 

-- NPC data source. 
local dsNPC = {
	{Title="我要学会说话", Icon="Texture/3DMapSystem/AppIcons/chat_64.dds", SubTitle="学讲话, 真人配音"},
	{Title="随机走动", Icon="Texture/3DMapSystem/AppIcons/Environment_64.dds", SubTitle="在周围随机走动"},
	{Title="我是跟屁虫", Icon="Texture/3DMapSystem/AppIcons/People_64.dds", SubTitle="自动跟随附近的玩家"},
	{Title="我是导游", Icon="Texture/3DMapSystem/AppIcons/NewWorld_64.dds", SubTitle="协助玩家的导游"},
	{Title="木头人", Icon="Texture/3DMapSystem/AppIcons/Pet_64.dds", SubTitle="成为原地不动的人物"},
}

-- data source function for official app. 
function CharPropertyPage.DS_Func_NPC(index)
	if(dsNPC) then
		if(index==nil) then
			return #dsNPC;
		else
			return dsNPC[index];
		end
	end
end

-- init 
function CharPropertyPage.OnInit()
	-- singleton page reference. 
	page = document:GetPageCtrl();
end


-- update UI
function CharPropertyPage.UpdatePanelUI()
	local obj = Map3DSystem.obj.GetObjectParams(Map3DSystem.App.Creator.target);
	
	if(obj) then
		if(page) then
			page:SetUIValue("name", obj.name or "");
		end	
	end
	
	-- update the object canvas with selected object
	local ctl = CommonCtrl.GetControl("map3dsystem_char_property_canvas");
	if(ctl ~= nil) then
		if(obj == nil) then
			ctl:ShowModel();
		else
			local setBackName = obj.name;
			obj.name = nil;
			ctl:ShowModel(obj);
			obj.name = setBackName;
		end
	end
end

-- close panel
function CharPropertyPage.OnClose()
	local command = Map3DSystem.App.Commands.GetCommand("Creation.CharProperty");
	if(command) then
		command:Call({bShow=false});
	end
end

-- take control of the character
function CharPropertyPage.OnSwitchToObject()
	local objParam = Map3DSystem.obj.GetObjectParams(Map3DSystem.App.Creator.target);
	Map3DSystem.SwitchToObject(objParam);
end

-- whenever the user pressed the change name button
function CharPropertyPage.OnChangeCharacterName()
	if(not Map3DSystem.User.CheckRight("Save")) then return end
	local player = Map3DSystem.obj.GetObject(Map3DSystem.App.Creator.target);
	if(player~=nil and player:IsValid())then
		local newname = page:GetUIValue("name");
		if(player.name ~= newname)then
			player.name = newname;
			
			if(newname ~= player.name) then
				page:SetUIValue("name", player.name)
				autotips.AddMessageTips(L"rename failed: you can only change the name of a character, when you are not controlling it, and that the name should be identical.");
			else
				autotips.AddMessageTips("改名成功");
				page:SetUIValue("result", "改名成功");
			end	
		end	
	end	
end

-- whenever the user pressed the change scale button
function CharPropertyPage.OnChangeCharacterScale()
	if(not Map3DSystem.User.CheckRight("Save")) then return end
	local player = Map3DSystem.obj.GetObject(Map3DSystem.App.Creator.target);
	if(player~=nil and player:IsValid())then
		local newscale = page:GetUIValue("scale");
		newscale = tonumber(newscale);
		player:SetScale(newscale);
		autotips.AddMessageTips("放缩成功");
	end
end

-- change to the next skin
function CharPropertyPage.OnChangeCharacterSkin()
	local player = Map3DSystem.obj.GetObject(Map3DSystem.App.Creator.target);
	if((player~=nil) and player:IsValid() and (player:IsGlobal() ==true) and (player:IsCharacter() == true)) then
		local playerchar = player:ToCharacter();
		local LastSkin = playerchar:GetSkin();
		playerchar:SetSkin(LastSkin+1);
		local bSkinChanged;
		if(playerchar:GetSkin() == LastSkin) then
			if(LastSkin ==0) then
				autotips.AddMessageTips(L"I can not change skin");
			else
				playerchar:SetSkin(0);--cycle to the first one. 
				if(playerchar:GetSkin() ~= 0) then
					playerchar:SetSkin(1); -- some character does not begin with index 0, try index 1 anyway.
				end
				bSkinChanged = true;
			end
		else
			bSkinChanged = true;	
		end
		if(bSkinChanged) then
			-- update panel 
			Map3DSystem.obj.SetObject(player, Map3DSystem.App.Creator.target)
			CharPropertyPage.UpdatePanelUI()
			autotips.AddMessageTips("皮肤改变了");
		end
	end
end

-- save character to local world db
function CharPropertyPage.OnSaveCharacterProperty()
	if(not Map3DSystem.User.CheckRight("Save")) then return end
	local player = Map3DSystem.obj.GetObject(Map3DSystem.App.Creator.target);
	if((player~=nil) and player:IsValid() and (player:IsCharacter() == true))then
		if(player:IsPersistent()==true )then
			player:GetAttributeObject():CallField("Save");
			autotips.AddMessageTips(L"character has been saved");
			
		else
			autotips.AddMessageTips(L"I am not an NPC in this world, so I can not be saved.");
		end
	end
end

-- delete it. 
function CharPropertyPage.OnDeleteCharacter()
	local curObj = Map3DSystem.obj.GetObject(Map3DSystem.App.Creator.target);
	if(curObj ~= nil) then
		Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, obj = curObj});
		CharPropertyPage.OnClose()
	end
end

-- user clicks the NPC template. 
function CharPropertyPage.OnClickNPLTemplate(index)
	CharPropertyPage.OnAssignAIClick(index)
end

function CharPropertyPage.OnShowAndCopyAssetBtn()
	local objParam = Map3DSystem.obj.GetObjectParams(Map3DSystem.App.Creator.target);
	_guihelper.MessageBox(objParam.AssetFile..[[<br/>路径已经复制到剪切板，可以Ctrl+V复制成文本]]);
	ParaMisc.CopyTextToClipboard(objParam.AssetFile);
end

-- called when one of the AI buttons is clicked. see dsNPC table for meaning of the index. 
-- @param nIndex: behavior type
-- @param target: it can be "selection" or "contextmenu" or nil.  if nil it is the target set by Map3DSystem.App.Creator.target
function CharPropertyPage.OnAssignAIClick(nIndex, target)
	target = target or Map3DSystem.App.Creator.target
	local player = Map3DSystem.obj.GetObject(target);
	if(player==nil or not player:IsValid() or player:IsCharacter() == false) then
		autotips.AddMessageTips(L"Only character can have behaviors.");
		return;
	end
	
	NPL.load("(gl)script/ide/headon_speech.lua");
	
	local playerChar = player:ToCharacter();
	local att = player:GetAttributeObject();
	if(nIndex == 1) then
		NPL.load("(gl)script/kids/3DMapSystemUI/InGame/SimpleNPCTalkEditor.lua");
		Map3DSystem.UI.SimpleNPCTalkEditor.obj_params = Map3DSystem.obj.GetObjectParams(target);
		Map3DSystem.UI.SimpleNPCTalkEditor.Show(true);
	elseif(nIndex == 2) then
		headon_speech.Speek(player.name, L"Let me wander near here.", 2);
		playerChar:Stop();
		playerChar:AssignAIController("follow", "false");
		playerChar:AssignAIController("movie", "false");
		playerChar:AssignAIController("sequence", "false");
		att:SetField("OnLoadScript", "");
		att:SetField("On_Perception", "");
		local px,py,pz = player:GetPosition();
		local radius = 9;
		att:SetField("On_FrameMove", string.format([[;NPL.load("(gl)script/AI/templates/RandomWalker.lua");_AI_templates.RandomWalker.On_FrameMove(%d, %.1f, %.1f);]], radius, px,pz));
		att:SetField("On_EnterSentientArea", "");
		att:SetField("On_LeaveSentientArea", "");
		att:SetField("On_Click", "");
	elseif(nIndex == 3) then
		headon_speech.Speek(player.name, L"I am a piggy now.", 2);
		playerChar:Stop();
		playerChar:AssignAIController("face", "true");
		playerChar:AssignAIController("follow", "false");
		playerChar:AssignAIController("movie", "false");
		playerChar:AssignAIController("sequence", "false");
		att:SetField("OnLoadScript", "");
		att:SetField("On_Perception", [[;NPL.load("(gl)script/AI/templates/SimpleFollow.lua");_AI_templates.SimpleFollow.On_Perception();]]);
		att:SetField("On_FrameMove", "");
		att:SetField("On_EnterSentientArea", "");
		att:SetField("On_LeaveSentientArea", "");
		att:SetField("On_Click", "");
	elseif(nIndex == 4) then
		headon_speech.Speek(player.name, "我是导游了", 2);
		playerChar:Stop();
		playerChar:AssignAIController("face", "true");
		playerChar:AssignAIController("follow", "false");
		playerChar:AssignAIController("movie", "false");
		playerChar:AssignAIController("sequence", "false");
		att:SetField("OnLoadScript", "");
		att:SetField("On_Perception", "");
		att:SetField("On_FrameMove", "");
		att:SetField("On_EnterSentientArea", "");
		att:SetField("On_LeaveSentientArea", "");
		att:SetField("On_Click", "");	-- TODO: Load the guider AI. LiXizhi 2008.6.15
	elseif(nIndex == 5) then
		headon_speech.Speek(player.name, L"Ah, I am a dummy now.", 2);
		playerChar:Stop();
		playerChar:AssignAIController("face", "false");
		playerChar:AssignAIController("follow", "false");
		playerChar:AssignAIController("movie", "false");
		playerChar:AssignAIController("sequence", "false");
		att:SetField("OnLoadScript", "");
		att:SetField("On_Perception", "");
		att:SetField("On_FrameMove", "");
		att:SetField("On_EnterSentientArea", "");
		att:SetField("On_LeaveSentientArea", "");
		att:SetField("On_Click", "");
	end
end
