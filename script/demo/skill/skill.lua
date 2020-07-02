--[[
skill slots for casting magic effects
]]

-- define the magic effect on the 8 skill bar slots
skillsbar = {};
-- the current selected skill bar index.  
skillsbar_index = 0;
local i;
for i=1,6 do
	skillsbar[i]={ID=i};
	-- skillsbar[i].name = "XX";
end

local function activate()
	local __this,__parent,__font,__texture;
	
	__this = ParaUI.GetUIObject("skill_box_cont");
	if(__this:IsValid()==true)then
		if(__this.visible == true) then
			__this.visible = false;
		else
			__this.visible = true;
		end
	else
		__this=ParaUI.CreateUIObject("container","skill_box_cont", "_lt",670,640,340,40);
		__this:AttachToRoot();
		__this.scrollable=false;
		__this.background="Texture/player/outputbox.png;0 0 512 256";
		__this.candrag=true;
		__this.receivedrag = true;
		__texture=__this:GetTexture("background");
		__texture.transparency=122;--[0-255]
		
		__this=ParaUI.CreateUIObject("button","arr_up", "_lt",0,0,20,20);
		__parent=ParaUI.GetUIObject("skill_box_cont");__parent:AddChild(__this);
		__this.background="Texture/skill/arr_up.png;";
		__this.onclick="(gl)script/demo/film/add_action.lua"; -- TODO: show action bar
		__this.candrag=false;

		__this=ParaUI.CreateUIObject("button","arr_down", "_lt",0,20,20,20);
		__parent=ParaUI.GetUIObject("skill_box_cont");__parent:AddChild(__this);
		__this.background="Texture/skill/arr_down.png;";
		__this.onclick="(gl)script/demo/film/add_spell.lua"; -- TODO: show action bar
		__this.candrag=false;

		-- create the skill butons.
		local nRow, nCol = 0,0;
		__parent=ParaUI.GetUIObject("skill_box_cont");
		local slotID, skillItem;
		for slotID, skillItem in ipairs(skillsbar) do
			__this=ParaUI.CreateUIObject("button","btn_skillbar"..nCol, "_lt",20+40*nCol,40*nRow,40,40);
			__parent:AddChild(__this);
			--__this.text=tostring(skillItem.ID);
			--__this.background="Texture/skill/item.png";
			__this.background="Texture/skill/"..tostring(skillItem.ID)..".png";
			__this.onclick=string.format([[(gl)script/demo/skill/castmagic.lua; skillsbar_index = %d;]], tonumber(skillItem.ID));
			__this.candrag=true;
		
			if(nCol>=7) then
				nCol = 0;
				nRow=nRow+1;
				log("skillbar overflowed.\n");
			else
				nCol = nCol+1;
			end
		end
	end
end
NPL.this(activate);
