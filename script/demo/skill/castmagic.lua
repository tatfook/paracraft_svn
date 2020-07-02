--[[ 
Title: cast new magic of the skillsbar[skillsbar_index]
Author(s): LiXizhi
Date: 2005/11
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/demo/skill/castmagic.lua");
------------------------------------------------------------
]]
casteffect_from = "<player>";
casteffect_to = "NPC0";
local function activate()
	if(skillsbar~=nil and skillsbar_index~=nil) then
		local skillItem = skillsbar[skillsbar_index];
		if(skillItem~=nil and skillItem.ID~=nil) then
			-- just for testing.
			if(skillItem.ID > 3) then
				casteffect_from = "NPC0";
				casteffect_to = "girlPC";
			else
				casteffect_from = "<player>";
				casteffect_to = "NPC0";
			end

			local player = ParaScene.GetObject(casteffect_from);
			player:ToCharacter():CastEffect(skillItem.ID,casteffect_to);
		end
	end
end
NPL.this(activate);
