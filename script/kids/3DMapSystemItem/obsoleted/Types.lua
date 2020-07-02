--[[
Title: supported item types. each type as its handler
Author(s): LiXizhi
Date: 2009/2/3
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemData/ItemTypes.lua");
local ItemTypes = Map3DSystem.Item.Types;
if(type == ItemTypes.Exe_AppCommand) then
end
------------------------------------------------------------
]]

-- supported item types
-- NOTE: this is not limited to the global store type. Item_template class categorization is also included.
--		each type of object has its own handler. The types are listed logically but not according to the database tables
local Types = {
	-- types in gloabl store
	Exe_App = 1,
	Exe_AppCommand = 2,
	
	Asset_Animation = 3,
	Asset_Character = 4,
	Asset_Model = 5,
	Asset_Texture = 6,
	
	-- item_template classes
	Item_Apparel = 7,
	Item_Furniture = 8,
	-- NOTE: Item for Creator and Movie are all Asset items in global store asset_*** templates
	Item_Blueprint = 9,
	Item_Mount = 10,
	Item_Box = 11,
	Item_Consumable = 12,
	Item_Robot = 13,
	Item_Quest = 14,
	Item_Misc = 15,
	Item_Bag = 16,
	
	------------------------
	-- Drafts by LiXizhi
	------------------------
	---- a locally defined function
	--LocalFunc=1,
	--AppCommand=2, 
	---- Application: Official or not
	--App=3,
	---- a 3d scene model submitted officially
	--Model=4, 
	---- user generated content 
	--ModelUGC=5,
	---- such as terrain texture, etc. 
	--Texture=6,
	---- a character model like pets, NPC, vehicles, etc. 
	--Character=7, 
	--CharacterUGC=8,
	---- like the market place
	--BagOfficial=9, 
	---- like the world store
	--BagWorld=10, 
	---- like the personal inventory 
	--BagInventory=11, 
	--BagBonus=12, 
	---- can be casted to a target
	--SkillItem = 13,
	---- can be attached to character slot
	--AttachmentItem=14,
	---- a letter of email
	--Email=15,
	---- new BCS item
	--BCSItem=16,
	---- officially approved world
	--World=17,
	---- user generated world
	--WorldUGC=18,
	---- a EBook
	--EBook=20,
	---- a movie script
	--Movie=21,
	---- an officially approved mcml page
	--MCMLPage=22,
	---- user generated mcml page
	--MCMLPageUGC=23,
	---- biped animation that can be shared
	--BipedAnimation=24,
	---- a blueprint
	--BluePrint=25,
	---- terrain heightmap
	--HeightMap=26,
};

commonlib.setfield("Map3DSystem.Item.Types", Types)
