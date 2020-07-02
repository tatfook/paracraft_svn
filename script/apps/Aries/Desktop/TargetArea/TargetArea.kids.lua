--[[
Title: Desktop Target Area for selected object(NPC, players)
Author(s): WangTian
Date: 2009/4/7
Desc: See Also: script/apps/Aries/Desktop/AriesDesktop.lua
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/TargetArea.lua");
MyCompany.Aries.Desktop.TargetArea.Init();
------------------------------------------------------------
]]

-- create class
local libName = "AriesDesktopTargetArea";
local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");

local Combat = commonlib.gettable("MyCompany.Aries.Combat");

-- selection response pages, dynamicly loaded from web
local SelectionResponse = commonlib.gettable("MyCompany.Aries.Desktop.SelectionResponse");

NPL.load("(gl)script/apps/Aries/Team/TeamWorldInstancePortal.lua");
local TeamWorldInstancePortal = commonlib.gettable("MyCompany.Aries.Team.TeamWorldInstancePortal");

NPL.load("(gl)script/apps/Aries/Team/TeamMembersPage.lua");
local TeamMembersPage = commonlib.gettable("MyCompany.Aries.Team.TeamMembersPage");


-- virtual function: create UI
function TargetArea.Create()
	local _targetArea = ParaUI.CreateUIObject("container", "TargetArea", "_lt", 8, 80, 140, 512);
	_targetArea.background = "";
	_targetArea:SetField("ClickThrough", true);
	_targetArea:AttachToRoot();
end

-- virtual function
-- @param bAutoSelect: auto select or focus on the NPC
function TargetArea.TalkToNPC(id, instance, bAutoSelect)
	local NPC = MyCompany.Aries.Quest.NPC;
	if(bAutoSelect == true) then
		local npc_char = NPC.GetNpcCharacterFromIDAndInstance(id, instance);
		if(npc_char) then
			-- select the npc
			System.SendMessage_obj({type = System.msg.OBJ_SelectObject, obj = npc_char});
		end
	end
	
	local isAntiSystemIsEnabled = false;
	local AntiIndulgence = commonlib.getfield("System.App.MiniGames.AntiIndulgence");
	if(AntiIndulgence) then
		isAntiSystemIsEnabled = AntiIndulgence.IsAntiSystemIsEnabled();
	end
	
	-- NOTE 2010/2/3: comment the following line and return to normal antiindulgence
	--					designers requested a mode for non antiindulgence normal NPCs only mini games are antiindulgence enabled
	local NPCs = commonlib.getfield("MyCompany.Aries.Quest.NPCList.NPCs");
	if(NPCs and NPCs[id] and NPCs[id].main_script and not string.find(NPCs[id].main_script, "30161")) then
		isAntiSystemIsEnabled = false;
	end
	
	if(isAntiSystemIsEnabled) then
		local NPCs = commonlib.getfield("MyCompany.Aries.Quest.NPCList.NPCs");
		if(NPCs and NPCs[id] and NPCs[id].dialogstyle_antiindulgence) then
			-- show newbiequest help dialog
			local url = "script/apps/Aries/Desktop/GUIHelper/AntiIndulgence_dialog.html";
			if(id) then
				url = url.."?npc_id="..id;
			end
			if(instance) then
				url = url.."&instance="..instance;
			end
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = url, 
				app_key = MyCompany.Aries.app.app_key, 
				name = "NPC_Dialog", 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				allowDrag = false;
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 2,
				directPosition = true,
					align = "_lb",
						x = 41,					
						y = -165,
						width = 900,
						height = 130,
			});
		else
			TargetArea.ShowAntiIndulgenceBox()
		end
	else
		NPC.TalkToNPC(id, instance);
	end
end

function TargetArea.ShowURLAsGameObjectMCMLPage(url)
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	style.shadow_bg = "texture/bg_black_20opacity.png";
	style.fillShadowLeft = -10000;
	style.fillShadowTop = -10000;
	style.fillShadowWidth = -10000;
	style.fillShadowHeight = -10000;
	
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = url, 
		name = "GameObjectMCMLBrowser", 
		isShowTitleBar = false,
		allowDrag = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
		style = style,
		zorder = 2,
        allowDrag = false,
		isTopLevel = true,
		directPosition = true,
			align = "_ct",
				x = -848/2,
				y = -600/2 + 40,
				width = 848,
				height = 620,
	});
end

function TargetArea.ShowDialogStyleMessageBox(npc_id, instance, text)
	-- show newbiequest help dialog
	local url = "script/apps/Aries/Desktop/GUIHelper/CommonMessageBoxStyle_dialog.html";
	if(npc_id) then
		url = url.."?npc_id="..npc_id;
	end
	if(instance) then
		url = url.."&instance="..instance;
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = url, 
		app_key = MyCompany.Aries.app.app_key, 
		name = "NPC_Dialog", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
		allowDrag = false;
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 2,
		directPosition = true,
		align = "_ctb",
			x = 0,					
			y = 22,
			width = 900,
			height = 230,
	});
	
	-- set messagebox style dialog 
	TargetArea.Text_DialogStyleMessageBox = text;
end