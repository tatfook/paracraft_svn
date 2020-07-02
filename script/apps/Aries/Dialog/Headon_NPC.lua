--[[
Title: displaying head on speech on NPC character
Author(s): WangTian
Date: 2009/6/24
Desc: global AI related functions.
Use Lib: For displaying head on speech on NPC character, 
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Dialog/Headon_NPC.lua");
MyCompany.Aries.Dialog.Headon_NPC.Init()
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/headon_speech.lua");

-- create class
local Headon_NPC = commonlib.gettable("MyCompany.Aries.Dialog.Headon_NPC");

-- double line offset 
local line_offset = -20;

-- mapping from template name to headon UI template 
local template_map = {
	[""] = {name="", },
	["accept"] = {name="_headon_accept_", bg="Texture/Aries/HeadOn/Question_Mark_32bits.png", width=16, height=16, height_offset = -32},
	["pending"] = {name="_headon_pending_", bg="Texture/Aries/HeadOn/Question_Mark_Grey_32bits.png", width=16, height=16, height_offset = -32 },
	["finish"] = {name="_headon_finish_", bg="Texture/Aries/HeadOn/Excalmatory_Mark_32bits.png", width=16, height=16, height_offset = -32},
	["unfinshed"] = {name="_headon_unfinished", bg="Texture/Aries/HeadOn/Excalmatory_Mark_Grey_32bits.png", width=16, height=16, height_offset = -32},
	["portal"] = {name="_headon_portal_", bg="Texture/Aries/HeadOn/Portal_32bits.png", width=16, height=16, height_offset = -32},

	["can_accept"] = {name="_headon_can_accept_", bg="Texture/Aries/HeadOn/exclamation.png;0 0 13 51", width=13, height=51, height_offset = -48},
	["accepted"] = {name="_headon_accepted_", bg="Texture/Aries/HeadOn/exclamation_grey.png;0 0 13 51", width=13, height=51, height_offset = -48},
	["can_finished"] = {name="_headon_can_finished_", bg="Texture/Aries/HeadOn/question.png;0 0 32 50", width=32, height=50, height_offset = -48},
	["un_finished"] = {name="_headon_un_finished_", bg="Texture/Aries/HeadOn/question_grey.png;0 0 32 50", width=32, height=50, height_offset = -48},
	["can_dialoged"] = {name="_headon_can_dialoged_", bg="Texture/Aries/HeadOn/question.png;0 0 32 50", width=32, height=50, height_offset = -48},

	["needTranspot"] = {name="_headon_needTranspot_", bg="Texture/Aries/HeadOn/question2.png;0 0 32 50", width=32, height=50, height_offset = -48},
}

-- headon text speak. 
function Headon_NPC.Speak(charName, text, nLifeTime)
	headon_speech.Speek(charName, text, nLifeTime);
end

-- init all template
function Headon_NPC.Init()
	local _parent = ParaUI.GetUIObject("dummy_headon_npc");
	if(not _parent:IsValid()) then
		_parent = ParaUI.CreateUIObject("container","dummy_headon_npc", "_lt",-10,-10,1,1);
		_parent.visible = false;
		_parent.enabled = false;
		_parent:AttachToRoot();
	end

	-- single line
	local _, template
	for _, template in pairs(template_map) do
		local name = template.name;
		if(name ~= "" and not ParaUI.GetUIObject(name):IsValid()) then
			-- users can create their own UI template in NPL.
			local _this=ParaUI.CreateUIObject("button",name, "_lt",-template.width/2,-template.height/2+template.height_offset, template.width, template.height);
			_this.visible = false;
			_this.background = template.bg;
			_guihelper.SetUIColor(_this, "255 255 255");
			_parent:AddChild(_this);
			-- _this:AttachToRoot();
		end	
	end
	-- double single line
	local _, template
	for _, template in pairs(template_map) do
		local name = template.name.."_double";
		if(template.name ~= "" and not ParaUI.GetUIObject(name):IsValid()) then
			-- users can create their own UI template in NPL.
			local _this=ParaUI.CreateUIObject("button", name, "_lt",-template.width/2,-template.height/2+template.height_offset+line_offset, template.width, template.height);
			_this.visible = false;
			_this.background = template.bg;
			_guihelper.SetUIColor(_this, "255 255 255");
			_parent:AddChild(_this);
			-- _this:AttachToRoot();
		end	
	end
end

-- head on UI template. 
-- @param npcChar: the ParaObject of the character or model
-- @param sTemplateName: if nil or "", it will hide the mark. otherwise it can be 
--  "accept", "pending",  "finish","unfinshed","portal", etc. more info see Headon_NPC.lua
function Headon_NPC.ChangeHeadonMark(npcChar, sTemplateName)
	if (npcChar) then
		local template = template_map[sTemplateName or ""]
		if(template) then
			-- use the layer 1 for head on mark of NPC. 
			-- tricky: we will use the _double template if layer 0 is also double ine. So that the question mark icons, etc will be displayed properly. 
			-- echo({"1111111", npcChar:GetHeadOnUITemplateName(0), npcChar:GetHeadOnText(0)})
			if(npcChar:GetHeadOnUITemplateName(0) == "HOD_Selected_DoubleLine") then
				npcChar:SetHeadOnUITemplateName(if_else(template.name~="",  template.name.."_double", ""), 1);	
			else
				npcChar:SetHeadOnUITemplateName(template.name, 1);	
			end
		end
	end
end





