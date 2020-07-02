--[[
Title: Chat area
Author(s): LiXizhi
Date: 2010/7/20
Desc: chat log and chat input
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/Areas/BattleChatArea.lua");
-------------------------------------------------------
]]
local BattleChatArea = commonlib.gettable("MyCompany.Aries.Combat.UI.BattleChatArea");


-- this function is called when UI needs to be recreated. 
-- @param bDelayCreateUI: if true, we will delay creating ui. 
function BattleChatArea.Init(bDelayCreateUI)
	-- load implementation
	if(System.options.version=="kids") then
		NPL.load("(gl)script/apps/Aries/Desktop/ChatArea/BattleChatArea.kids.lua");
	else
		NPL.load("(gl)script/apps/Aries/Desktop/ChatArea/BattleChatArea.teen.lua");
	end
	BattleChatArea.Create(bDelayCreateUI);
end


-- virtual function: create UI
function BattleChatArea.Create(bDelayCreateUI)
	
end

-- virtual function: show/hide the battle area
function BattleChatArea.Show(bShow)

end

-- virtual function: called when desktop is activated.
function BattleChatArea.OnActivateDesktop()
	NPL.load("(gl)script/apps/Aries/Combat/Battlefield/BattlefieldClient.lua");
	local BattlefieldClient = commonlib.gettable("MyCompany.Aries.Battle.BattlefieldClient");
	BattlefieldClient.OnActivateDesktop();
end

-- virtual funciton: Set the UI mode of the battle area, so that it has different display for different mode.
-- @param mode: "tutorial", "combat", "normal", "home"
function BattleChatArea.SetMode(mode)
	BattleChatArea.mode = mode;
end

