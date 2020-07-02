--[[
Title: Desktop Target Area for selected object(NPC, players)
Author(s): LiXizhi
Date: 2011/5/23
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

local page;


-- mapping from selection type to its mcml page template for display
TargetArea.SelectionResponseURL ={
	["NPC"] = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC.html",
	["Myself"] = "script/apps/Aries/Desktop/SelectionResponse/Myself.kids.html",
	["GameObject"] = "script/apps/Aries/Desktop/SelectionResponse/GameObject.html",
	["OtherPlayer"] = "script/apps/Aries/Desktop/SelectionResponse/OtherPlayer.kids.html",
	["townchiefrodd"] = "script/apps/Aries/Desktop/SelectionResponse/townchiefrodd.html",
	["mountpetinhomeland"] = "script/apps/Aries/Desktop/SelectionResponse/MountPetInHomeland.html",
	["followpetinhomeland"] = "script/apps/Aries/Desktop/SelectionResponse/FollowPetInHomeland.html",
	["mountpetinotherhomeland"] = "script/apps/Aries/Desktop/SelectionResponse/OtherPlayerMountPetInHomeland.html",
	["followpetinotherhomeland"] = "script/apps/Aries/Desktop/SelectionResponse/OtherPlayerFollowPetInHomeland.html",

	-------------------------------------
	-- TODO: use following teen version instead for leio by xizhi
	-------------------------------------

	["NPC"] = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC.teen.html",
	["Myself"] = "script/apps/Aries/Desktop/SelectionResponse/Myself.teen.html",
	["GameObject"] = "script/apps/Aries/Desktop/SelectionResponse/GameObject.teen.html",
	["OtherPlayer"] = "script/apps/Aries/Desktop/SelectionResponse/OtherPlayer.teen.html",
	--["townchiefrodd"] = "script/apps/Aries/Desktop/SelectionResponse/townchiefrodd.teen.html",
	--["mountpetinhomeland"] = "script/apps/Aries/Desktop/SelectionResponse/MountPetInHomeland.teen.html",
	--["followpetinhomeland"] = "script/apps/Aries/Desktop/SelectionResponse/FollowPetInHomeland.teen.html",
	--["mountpetinotherhomeland"] = "script/apps/Aries/Desktop/SelectionResponse/OtherPlayerMountPetInHomeland.teen.html",
	--["followpetinotherhomeland"] = "script/apps/Aries/Desktop/SelectionResponse/OtherPlayerFollowPetInHomeland.teen.html",
};


-- virtual function: create UI
function TargetArea.Create()
	local _parent = ParaUI.CreateUIObject("container", "TargetArea", "_lt", 256, 0, 512, 90);
	_parent.background = "";
	_parent:GetAttributeObject():SetField("ClickThrough", true);
	_parent:AttachToRoot();
	
	-- Note by Xizhi: this is a common background page shared by all SelectionResponseURL. we can delete it if not used. 
	page = page or Map3DSystem.mcml.PageCtrl:new({url="script/apps/Aries/Desktop/TargetArea/TargetArea.teen.html",click_through = true,});

	-- one can create a UI instance like this. 
	page:Create("Aries_TargetArea_mcml", _parent, "_fi", 0, 0, 0, 0);
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
		align = "_lb",
			x = 41,					
			y = -165,
			width = 900,
			height = 130,
	});
	
	-- set messagebox style dialog 
	TargetArea.Text_DialogStyleMessageBox = text;
end