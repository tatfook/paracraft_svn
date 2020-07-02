--------------------------------------------------------------------
Title: read me file for ParaWorld item system
Author(s): WangTian
Date: 2009/2/6
Desc: API specification and developer guide for item related applications
--------------------------------------------------------------------


-------------------------------
		Overview
-------------------------------
ParaWorld item system allows all users to pick, carry, use, sell, buy, wear items, and more important to contribute the item to the 
community and even the item itself. The big picture of a ParaWorld is a set of worlds which consists of various items and the related application 
upon them. Those items includes models, characters, animations and many others that can be either officially packed or user generated.

-------------------------------
		Global Store
-------------------------------
Global Store holds information on every item that exists in ParaWorld. All items are created from their information stored in this table.
It works like a template that all item entities are instances of the item template. Global Store table should include but not limited to: 

GSID		*Unique Indexed*	ID of the item unique between all templates, like IP
AssetKey	*Unique Indexed*	asset string key, like url path 
assetFile		varchar			reference a remote paraworld file where this item can be downloaded safely
majorversion	smallint		major version
minorversion	smallint		minor version
revision		smallint		revision,     major.minor.revision
isApproved		bool			bool, if AssetFile is offically approved
type			tinyint		like Item, AppCommand, App, model asset, texture asset, character asset, animation asset
				ID	template table
				1	item_template
				2	app_template
				3	appcommand_template
				4	model_asset_template
				5	texture_asset_template
				6	character_asset_template
				7	animation_asset_template
category		varchar			virtual folder: like model/char, char/v3/assets. similar to AssetKey. for human categorization.
count			int				how many are left in store. nil for infinity.
icon			varchar			icon to display. can be local or URL path.
pBuyPrice		int				The price required to pay to buy this item from a vendor, in p cash.
eBuyPrice		int				The price required to pay to buy this item from a vendor, in e cash.
pSellPrice		int				The price that the vendor will pay you for the item when you sell it and if it is possible to be sold, in p cash.
eSellPrice		int				The price that the vendor will pay you for the item when you sell it and if it is possible to be sold, in e cash.
								Put in 0 on both pSellPrice and eSellPrice, if the item cannot be sold to a vendor.
batched			int				how many times the item is batch from the global store

the following is removed in the original draft:
Author							userid who uploaded
UploadDate						date

-------------------------------
		Templates
-------------------------------
The items are represented by objects that will act as a black box - users or developers do not need to know how it is working on the inside. 
The information stored in Global Store is mainly for display purpose and contain an item index which indicates what kind of item they are. 
To get the properties of an item, there will be a template table that holds all the information for all the possible item indices an object can have.
The "type" field of the global store specifies which table that the properties are stored. Different templates stores different types of items.
But they all have an entry in global store.

-------------------------------
		Item Template
-------------------------------
Item template is a MMORPG-like type item table. It defines all official designed items. These items may have attributes that effect the user 
experience in ParaWorld, such as slow down. Some of these items are not free, such as some limited edition mount or brilliant clothes.
Item template table(item_template) includes but not limited to:

ID			SQL server generated ID <-- character.db ItemDatabase use this id
gsID		ID of the item in global store
brand	tinyint		ownership
			ID	Brand
			0	PE owned
			1	cooperative owned in business
			NOTE: 2 UGC 3rd party or user owned, this type of item is stored in the asset template table which will describe later
brandcode	smallint		ownership code
expiredays	smallint		the expire time in days, 0 for permanent
class	class.subclass.minorclass indexed
--	class		tinyint		class of the item
--	subclass	tinyint		subclass of the item
--	minorclass	tinyint		minorclass of the item
				The following table lists all available minorclass, subclass and class combinations and the minor/subclass name.
				The table is imported from Lorne's document, please refer to 策划部-《ParaWorld》物品系统设计文档-Lorne-090202.xls
		NOTE: the 3rd class in the document is obsoleted and splitted into the 2nd class
name		varchar		The item's name that will be displayed. 
quality		tinyint		The quality of the item: 
			ID  Color  Quality  
			0  Grey  Poor
			1  White  Common
			2  Blue  Uncommon
			3  Gold  High-quality
			4  Red  Epic
*InventoryType	tinyint		In what slot the item can be equipped. Directly borrowed from WoW, not all slots are used
			ID  Slot Name		ID  Slot Name  
			0  Non equipable	15  Ranged  
			1  Head				16  Back  
			2  Neck				17  Two-Hand  
			3  Shoulder			18  Bag  
			4  Shirt			19  Tabard  
			5  Chest			20  Robe  
			6  Waist			21  Main hand  
			7  Legs				22  Off hand  
			8  Feet				23  Holdable (Tome)  
			9  Wrists			24  Ammo  
			10  Hands			25  Thrown  
			11  Finger			26  Ranged right  
			12  Trinket			27  Quiver  
			13  Weapon			28  Relic  
			14  Shield    
*AllowableGender	tinyint		Bitmask controlling which gender can use this item. Add ids together to combine possibilities.
			Value	Gender
			1		Female only
			2		Male only
			3		All genders
RequiredContribution	int	The required contribution point the user needs to have to use this item.
RequiredTitle			varchar		The required title the user needs to have to use this item.
*maxcount				smallint	Maximum number of copies of this item a user can have. Use 0 for infinite.
*ContainerSlots			smallint	If the item is a bag, this field controls the number of slots the bag has. 
statsCount				tinyint		The number of stats used for this item. Only the first n stats are used. 
stackable				smallint	The number of copies of this item that can be stacked in the same slot.
stat_type(1-10)			tinyint		The type of stat to modify. 
stat_value(1-10)		smallint	The value to change the stat type to. 
			TODO: stat_type in ID, waiting for designer documents
			ID  Stat Type  
			0  ITEM_MOD_MANA  
			1  ITEM_MOD_HEALTH  
			3  ITEM_MOD_AGILITY  
			4  ITEM_MOD_STRENGTH  
			5  ITEM_MOD_INTELLECT  
			6  ITEM_MOD_SPIRIT  
			7  ITEM_MOD_STAMINA  
delay		int			The time in milliseconds between successive hits.
spellid		int			The spell ID of the spell that the item can cast or trigger.
spellcooldown	int		The cooldown in milliseconds for the specific spell controlling how often the spell can be used. Use -1 to use the default cooldown.
spellcharges	int		The number of times that the item can used. If 0, then infinite charges are possible. 
							If negative, then after the number of charges is depleted, the item is deleted as well. 
							If positive, then the item is not deleted after all the charges are spent.
*binding	tinyint		The binding type for the item. 
							ID	bind type
							0	no bound
							1	binds when used
							2	binds when equipped
							3	binds when picked up
							4	quest item
description	varchar		The description that appears in orange letters at the bottom of the item tooltip.
startquest	int			The ID of the quest that this item will start if right-clicked. See quest_template.entry
material	tinyint		The material that the item is made of. The value here affects the sound that the item makes when moved.
						Use 0 for consumable items like food, reagents, etc.
			ID Material
			0 consumable items
			1  Metal
			2  Wood
			3  Liquid
			4  Jewelry
			5  Chain
			6  Plate
			7  Cloth
			8  Leather
*itemset	int		The ID of the item set that this item belongs to. Item sets are defined in ItemSet.dbc
MaxComfortability	int		The maximum comfortability of this item, like the durability in MMORPG
*BagFamily	smallint	If the item is a bag, this field is an ID controlling what types of items can be put in this bag.
		ID  Type
		0  All
		1  Head
		2  Chest
		21  Furniture ...
duration	int		The duration of the item in seconds. 0 for permanent

not included in the table:

batch
serial


----------------------------------------------------------
		app_template and appcommand_template
----------------------------------------------------------
app_template:
ID			*Unique Indexed*	ID of the item unique between all templates
url			varchar		url, a url that the app can be downloaded
app_key		varchar		app_key

appcommand_template:
ID			*Unique Indexed*	ID of the item unique between all templates
url			varchar		url, a url that the app can be downloaded
app_key		varchar		app_key
commandname	varchar		command name
param		varchar		string, a param lua table


-------------------------------
		Asset Templates
-------------------------------

model_asset_template:
ID			*Unique Indexed*	ID of the item unique between all templates
name			varchar			The item's name that will be displayed. 
description		varchar			The description that appears in orange letters at the bottom of the item tooltip. 
author			varchar			userid who uploaded
uploaddate		datetime 		date
modifydate		datetime 		date
isbcscomponent		bool		is BCS component
component			tinyint		the component ID if model is BCS component
						ID	Component
						1	BCS_01base
						2	BCS_02block
						3	BCS_03blocktop
						4	BCS_04stairs
						5	BCS_05door
						6	BCS_06window
						7	BCS_07chimney
						8	BCS_08deco

texture_asset_template:
ID			*Unique Indexed*	ID of the item unique between all templates
name			varchar			The item's name that will be displayed. 
description		varchar			The description that appears in orange letters at the bottom of the item tooltip. 
author			varchar			userid who uploaded
uploaddate		datetime 		date
modifydate		datetime 		date

character_asset_template:
ID			*Unique Indexed*	ID of the item unique between all templates
name			varchar			The item's name that will be displayed. 
description		varchar			The description that appears in orange letters at the bottom of the item tooltip.
author			varchar			userid who uploaded
uploaddate		datetime 		date
modifydate		datetime 		date
iscustomcharacter		bool	is CCS character
issupportcartoonface	bool	is support cartoon face
							NOTE: although these two fields are implicitly defined in the x file, we still expose in the database
gender			tinyint			character gender
						ID	gender
						0	male
						1	female
TODO: CCS character need to insert data into the local character.db CharSectionsDB table.
	And for each world that the character is included, visitors have to download the character as well as a modification to his character.db
	Need designer confirmation on this CCS related UGC character.
	Would common character be enough? Would the CCS characters be officially managed?

animation_asset_template:
ID			*Unique Indexed*	ID of the item unique between all templates
name			varchar			The item's name that will be displayed. 
description		varchar			The description that appears in orange letters at the bottom of the item tooltip. 
author			varchar			userid who uploaded
uploaddate		datetime 		date
modifydate		datetime 		date
TODO: Animation file is a game server bahavior than a world behavior. Animation play will be broadcasted 
	to the nearby users via game server. Other users will have to download the animation file immediately.


-------------------------------
		Item Instance
-------------------------------

Keeping all item information along with each item is overkill: all energy or speed-up potion have the same name, looks and properties. 
Some objects might have "personal" data such as charges, enchantments, nicknames or durability that must be stored on the item itself, 
but this can be added in a separate table item_instance.

The item_instance table holds individual item instance information for all items currently equipped or in some kind of character bag or world bag.

guid	int		The GUID of the item. This number is unique for each item instance.
userid	GUID	The GUID of the character who has ownership of this item.
data	nvarchar	long text, this field has many number fields all separated by a space
					which contain specific individual item information like any charges applied to the item, etc. 
					Currently most data fields are separately defined as individual table entries
					Index  Value Name  Comments  
					0  OBJECT_FIELD_GUID  Item GUID
					2  OBJECT_FIELD_TYPE  Should be 3 (TYPE_OBJECT + TYPE_ITEM)
					3  OBJECT_FIELD_ENTRY  Item template entry
					4  OBJECT_FIELD_SCALE_X  1.0
					5  OBJECT_FIELD_PADDING
					6  ITEM_FIELD_OWNER  Same value as owner_guid
					8  ITEM_FIELD_CONTAINED  If the item is in a bag, the GUID of the bag item; otherwise owner GUID.
					10  ITEM_FIELD_CREATOR  GUID of character who created the item.
					12  ITEM_FIELD_GIFTCREATOR  GUID of character who created the item.
					14  ITEM_FIELD_STACK_COUNT  Current number of item copies in the stack.
					15  ITEM_FIELD_DURATION  Current duration (in seconds)
					16  ITEM_FIELD_SPELL_CHARGES
					21  ITEM_FIELD_FLAGS  Stores items Flags (from item_template)
					22  ITEM_FIELD_ENCHANTMENT
					55  ITEM_FIELD_PROPERTY_SEED  Also called ITEM_FIELD_SUFFIX_FACTOR
					56  ITEM_FIELD_RANDOM_PROPERTIES_ID
					57  ITEM_FIELD_ITEM_TEXT_ID  Text id used and shown by the item.
					58  ITEM_FIELD_COMFORTABILITY  Current item comfortability.
					59  ITEM_FIELD_MAXCOMFORTABILITY  Maximum item comfortability.

Soulbound	bool		is soul bound
Scale		float		object scale
ContainedInBagid	int		If the item is in a bag, the GUID of the bag item; otherwise 0
StackCount  tinyint		Current number of item copies in the stack.
Duration	tinyint		Current duration 
Charges		tinyint		Current charges
Comfortability  tinyint	Current item comfortability

batch		int		batch number
serial		int		serial number

-------------------------------
		Characters
-------------------------------
This table holds vital static information for each character. This information loaded and used to create the player objects in-game. 

guid			The character global unique identifier. This number must be unique and is the best way to identify separate characters. 
userid			userid, foreign key to the user database
data			long text field holding many different numbers all separated by a space that can be separated into an array 
				with an explode function on the space
position_x		The x position of the character's location. 
position_y		The y position of the character's location. 
position_z		The z position of the character's location. 
world			The world of the character's location.
orientation		The character's facing.
scale			The character's scaling, how the character appears in game
player_bytes	((hairColor << 24) | (hairStyle << 16) | (face << 8) | skin) and facialHair(currently unused)
orientation		The character's facing.
player_chosen_title  player chosen title
bag_slots_per_category	bag slots per category. Items with the same "class.subclass" belongs to the same bag.
				And each bag has a limited capacity that upgrades with the user contribution.
				Users have the same bag number as category number, but have different bag capacity.

unit_field_stat0 
unit_field_posstat0 
unit_field_negstat0  create stat triple for each status, TODO: implement according to designer document

player_quest_log_(logslot)_(logreq)  create quest log slots for each active quest

player_item_**	Item ID equipped on each character slot
player_field_inv_slot_head
level			smallint	地位 in designer document
exp				int			地位点数 in designer document
next_level_exp	int			next level experience
popularity		int			


---------------------------------------
		Wallet Level Time
---------------------------------------
level			smallint	wallet level
level_time		int			online time needed for level
level_capacity	int			wallet capacity for E cash only

---------------------------------------
		Bank
---------------------------------------
NOTE: we support bank account for E cash only, and credit card for P cash only
TODO: if move these fields to the central character database
guid				nvarchar	user id * unique indexed *
deposit				int			deposit in character account E cash only
wallet_level		smallint	wallet level for E cash only
wallet_capacity		int			wallet capacity for E cash only
credit_limit		int			credit P cash only
--cash_advance_limit	int			cash advance P cash only
current_balance		int			current balance P cash only
interest			int			current interest P cash only
statement_date		date		statement date P cash only (NOTE: different user may have different statement and payment dates)
payment_due_date	date		payment due date P cash only

--------------------------------------------------------
	title database pending for official activities
--------------------------------------------------------

TODO: the following already exists or need to append into the user database in ParaWorld API server
totaltime	The total time that the character has been active in ParaWorld, measured in minutes. 
logout_date	The time when the character last logged out, measured in date. 

---------------------------------------
		Global Store Editing
---------------------------------------
Append Update Delete Browse

-------------------------------
		Item Flow
-------------------------------
Traditional MMORPG have a strictly defined items system that item creates from limited sources including but not limited to:
Vendors, Quest, Drop, Game object etc.
ParaWorld doesn't involved mod killing, so creature corpse loot is not included in items system. So basicly, an item can be created from 
vendors, or picked on game objects or as a rewards of quest accomplishment. We will deal with each item creating process:

Vendor: this might possible be the most common way that a user gets an item. Usually the vendor is created in a user world or 
			a cooperative party world or an official world. The vendor is bound to a local bag or local store. This bag can contains any item objects 
			that will act like an always online character -- it will accept trading process if other player accept the price.
			The local bag items are previously bought from global stores which use the same trade metaphore.
Quest: this kind of items are always under game server behavior. The item achievement is still trading with the game server bag. 
			But the trading process is accepted not by price but by quest complete status.
			Basicly, the game server get the items from the global store into the game server bag. For officially defined quest items, 
			such item instance process needs game server authentification. So it can be only appears in approved game server bags.
Game object: game objects act like item in local bag, but it is for free or under certain quest status. User get the item directly from 
			game object picking. Game object is then respawned under particular rules.

So basicly, global store is an unlimited bag that contains all items in ParaWorld. Item instance process is always a bag to bag process that need 
different articles for exchange(p/e cash, quest requirements or for free).

Items can be destroyed by user or used for consumable items.

Items have batch and serial numbers indicating the item pipelining. Once the items are imported to local bag or game server bag. The batch number is then 
increased to record how many times that item is batched. Once the items are instanced into the user's inventory bag. The serial number is then increased 
to record how many times that item is instanced. Batch and serial number shows how "old" is the item.

---------------------------------------
		Character Inventory
---------------------------------------
Contains all the character inventory data.
userid		GUID		The GUID of the character who has ownership of this item.
--bagid		int			If it isn't 0, then it is the bag's item instance id. See item_instance.guid
--						If it is 0, then this item is a bag item or equipped on character.
ItemFamily	smallint	If it is 0, this item is equipped on character.
						If it isn't 0, this is the class and subclass of the item.
						class * 1000 + subclass
position	int			If the ItemFamily field is non-zero, The position is the slot in the category where the item is kept. 
								This field is auto-incremental. e.g. the position doesn't shift if the item is deleted from the inventory
						If the ItemFamily field is zero, then the position has a range of 0 to MaxBagFamily+50 and the value stands for the following: 
						0  Head  
						1  Neck  
						2  Shoulders  
						3  Body  
						4  Chest  
						5  Waist  
						6  Legs  
						7  Feet  
						8  Wrists  
						9  Hands  
						10  Finger 1  
						11  Finger 2  
						12  Trinket 1  
						13  Trinket 2  
						14  Back  
						15  Main Hand  
						16  Off Hand  
						17  Ranged  
						18  Tabard  
-- NOTE: this position field is changed from tinyint to int
						-- NOTE: slot number lower than 50 is reserved for equipped items
						BagFamily + 50   category bags
itemID		int		The item's instance GUID. See item_instance.guid 
gsID		int		The item's global store gsID. See global_store.gsID

In project Aries we don't need many bags in user's inventory. Items with the same category is put in one bag.

Since we don't have bag item in paraworld, the character inventory capacity varies according to the user contribution.


---------------------------------------
		World Inventory
---------------------------------------
Contains all the world inventory data.
guid			The GUID of the worlds. See worlds.guid
bag				If it isn't 0, then it is the bag's item GUID. See item_instance.guid 
slot			The slot is the slot in the bag where the item is kept. 
				The range can differ depending on the number of slots the bag has.
item			The item's GUID. See item_instance.guid 
item_template	The item's template entry. See item_template.entry 

TODO:
category		class.subclass, each category is a bag that can only hold items with the same "class.subclass".
				NOTE: not including minorclass.

Since we don't have bag item in paraworld, the world inventory capacity varies according to the world level.


-------------------------------
		Stores
-------------------------------
Contains all the local bag data. This can be local store bag or game server bag.
guid			int			The GUID of the store
owner_guid		int			The owner of the store, characters.guid
position		smallint	The slot is the slot in the bag where the item is kept. 
							The range can differ depending on the number of slots the bag has.
gsID			int			The item's global store ID. See global_store.gsID
extendedCosts	nvarchar	long text, this field has many number fields all separated by a space
							which contain specific individual non monetary price, e.g. honor points, contribution points or any combination.
							Index  ValueName  Comments  
							1  COST_HONOR  honor points
							2  COST_CONTRIBUTION  contribution points
							3  COST_CHARM  charm points
							4-8  COST_ITEM_(1-5)  specific items
							.etc
maxcount		smallint	The maximum number of copies of the item the vendor has available to be sold. If 0, then it is an unlimited number of copies. 
batch			int			batch number


TODO: unified bag interface and data structure in one table

-------------------------------
		APIs
-------------------------------

Global Store Related:

paraworld.globalstore.CreateItem
paraworld.globalstore.ReadItem
paraworld.globalstore.UpdateItem
paraworld.globalstore.DeleteItem
paraworld.globalstore.Browse

paraworld.bag.Fetch



TODO: character_queststatus

TODO: gameobject_template

TODO: gameobject_respawn


item instance database and character inventory sample:


guid	int		The GUID of the item. This number is unique for each item instance.
owner_guid	int	The GUID of the character who has ownership of this item.
data	nvarchar	long text, this field has many number fields all separated by a space
Soulbound	bool		is soul bound
Scale		float		object scale
ContainedInBagid	int		If the item is in a bag, the GUID of the bag item; otherwise 0
StackCount  tinyint		Current number of item copies in the stack.
Duration	tinyint		Current duration
Charges		tinyint		Current charges
Comfortability  tinyint	Current item comfortability

batch		int		batch number
serial		int		serial number


Item Instance:
guid		A	B	C	D	E	F	G
owner_guid	C1	C1	C1	C1	C1	C1	C1

Character Inventory:
owner_guid	C1	C1	C1	C1	C1	C1	C1
bagid		0	A	A	A	A	E	0
position	51	1	1	2	3	1	6
itemID		A	B	C	D	E	F	G
gsID		G1	G2	G2	G3	G4	G5	G6

indicating:	A is a category bag of BagFamily of (51-50), contains B, C, D, E items.
			B and C stacks in position 1, D alone in position 2 and E in position 3.
			E item is also a bag item that contains item F in position 1.
			C1 character wears item G on legs(6)
			

Crystal Shard


