--[[
Title: displaying head on speech on OPC character
Author(s): WangTian
Date: 2009/6/24
Desc: global AI related functions.
Use Lib: For displaying head on speech on OPC character, 
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Dialog/Headon_OPC.lua");
local Headon_OPC = commonlib.gettable("MyCompany.Aries.Dialog.Headon_OPC");
Headon_OPC.ChangeHeadonMark(nid, sTemplateName)
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/headon_speech.lua");

-- create class
local libName = "AriesDialogHeadonOPC";
local Headon_OPC = commonlib.gettable("MyCompany.Aries.Dialog.Headon_OPC");

-- double line offset 
local line_offset = -20;

-- mapping from template name to headon UI template 
local template_map = {
	[""] = {name="", },
	-- only used in teen version. 
	["autocombat"] = {version="teen", name="_headon_autocombat_", bg="Texture/Aries/HeadOn/AutoCombat_32bits.png", width=128, height=32, height_offset = -32},
	["leader"] = {version="kids", name="_headon_leader_", bg="Texture/Aries/Team/leader_headon_32bits.png", width=64, height=64, height_offset = -64},
	["member"] = {version="kids", name="_headon_member_", bg="Texture/Aries/Team/member_headon_32bits.png", width=64, height=64, height_offset = -64},
};

function Headon_OPC.Speak(nid, text, nLifeTime)
	local char = MyCompany.Aries.Pet.GetUserCharacterObj(nid);
	if(char and char:IsValid() == true) then
		-- TODO: set the OPC speek background and padding
		headon_speech.dialog_bg = "Texture/3DMapSystem/Desktop/headon_dialog.png:38 15 16 34";
		headon_speech.padding = 10;
		headon_speech.padding_bottom = 26;
		headon_speech.Speek(char.name, text, nLifeTime);
	end
end

-- init all template
function Headon_OPC.Init()
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

function Headon_OPC.ChangeHeadonMark(nid, sTemplateName)
	local template = template_map[sTemplateName or ""]
	if(template and (not template.version or template.version == System.options.version)) then
		local char = ParaScene.GetCharacter(tostring(nid));
		if(char and char:IsValid() == true) then
			-- use the layer 1 for head on mark of NPC. 
			-- tricky: we will use the _double template if layer 0 is also double ine. So that the question mark icons, etc will be displayed properly. 
			-- echo({"1111111", char:GetHeadOnUITemplateName(0), char:GetHeadOnText(0)})
			if(char:GetHeadOnUITemplateName(0) == "HOD_Selected_DoubleLine") then
				local template_name = if_else(template.name~="", template.name.."_double", "");
				local template_name_previous = char:GetDynamicField("HeadOnUITemplateName", nil);
				if(template_name_previous ~= template_name) then
					char:SetDynamicField("HeadOnUITemplateName", template_name);
					char:SetHeadOnUITemplateName(template_name, 1);
					local x,y,z = char:GetHeadOnOffset(0);
					char:SetHeadOnOffset(x, y, z, 1);
				end
			else
				local template_name = template.name;
				local template_name_previous = char:GetDynamicField("HeadOnUITemplateName", nil);
				if(template_name_previous ~= template_name) then
					char:SetDynamicField("HeadOnUITemplateName", template_name);
					char:SetHeadOnUITemplateName(template_name, 1);
					local x,y,z = char:GetHeadOnOffset(0);
					char:SetHeadOnOffset(x, y, z, 1);
				end
			end
			return true;
		end
	end
end