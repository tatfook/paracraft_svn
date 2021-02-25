--[[
Title: Agent Editor Page
Author(s): LiXizhi
Date: 2021/2/17
Desc: it defines properties of agent package
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/AgentEditorPage.lua");
local AgentEditorPage = commonlib.gettable("MyCompany.Aries.Game.GUI.AgentEditorPage");
AgentEditorPage.ShowPage();
-------------------------------------------------------
]]
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local AgentEditorPage = commonlib.gettable("MyCompany.Aries.Game.Agent.AgentEditorPage");

local cur_entity;
local page;

AgentEditorPage.updateMethods = {
	{value="always", text=L"强制更新"},
	{value="never", text=L"从不更新", selected=true},
	{value="manual", text=L"手工更新"},
}

function AgentEditorPage.OnInit()
	page = document:GetPageCtrl();

	if(cur_entity) then
		local blocks = cur_entity:HighlightConnectedBlocks();
		if(blocks) then
			page:SetValue("blockCount", tostring(#blocks))
		end
		page:SetValue("agentPackageName", cur_entity:GetAgentName())
		page:SetValue("agentPackageVersion", cur_entity:GetVersion())
		page:SetValue("agentDependencies", cur_entity:GetAgentDependencies())
		page:SetValue("agentExternalFiles", cur_entity:GetAgentExternalFiles())
		page:SetValue("agentUrl", cur_entity:GetAgentUrl())
		page:SetValue("isGlobal", cur_entity:IsGlobal() == true)
		page:SetValue("updateMethod", cur_entity:GetUpdateMethod())
	end
	
end

function AgentEditorPage.GetEntity()
	return cur_entity;
end

function AgentEditorPage.ShowPage(entity)
	if(not entity) then
		return;
	end
	
	if(cur_entity~=entity) then
		if(page) then
			page:CloseWindow();
		end
		cur_entity = entity;
	end

	local params = {
		url = "script/apps/Aries/Creator/Game/Agent/AgentEditorPage.html", 
		name = "AgentEditorPage.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true,
		bToggleShowHide=false, 
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		enable_esc_key = true,
		bShow = true,
		app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
		directPosition = true,
			align = "_lt",
			x = 0,
			y = 160,
			width = 200,
			height = 500,
	};
	
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	params._page.OnClose = function()
		if(cur_entity) then
			cur_entity:HighlightConnectedBlocks(false);
		end
		cur_entity = nil;
		page = nil;
	end
end

function AgentEditorPage.CloseWindow()
	if(page) then
		page:CloseWindow();
	end
end

function AgentEditorPage.OnClickOK()
	local entity = AgentEditorPage.GetEntity();
	if(entity) then
		local version = page:GetValue("agentPackageVersion");
		local agentName = page:GetValue("agentPackageName");
		local agentDependencies = page:GetValue("agentDependencies");
		local agentExternalFiles = page:GetValue("agentExternalFiles");
		local agentUrl = page:GetValue("agentUrl");
		local isGlobal = page:GetValue("isGlobal");
		local updateMethod = page:GetValue("updateMethod");
		entity:SetVersion(version);
		entity:SetAgentName(agentName);
		entity:SetAgentDependencies(agentDependencies);
		entity:SetAgentExternalFiles(agentExternalFiles);
		entity:SetAgentUrl(agentUrl);
		entity:SetGlobal(isGlobal);
		entity:SetUpdateMethod(updateMethod);

		-- finally save to agent file
		entity:SaveToAgentFile();
	end
	page:CloseWindow();
end

