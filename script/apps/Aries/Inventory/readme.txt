
---++Overview

Item system allows all users to pick, carry, use, sell, buy, wear items. The big picture is a set of worlds which 
consists of various items and the related application upon them. The original implementation includes models, characters, animations 
and many others that can be either officially packed or user generated. Currently we only take portion of the original design 
for Aries item system.

**D** stands for deprecated or need redesign

---++Global Store

Global Store holds information on every item that exists in ParaWorld. All items are created from their information stored in this table.
It works like a template that all item entities are instances of the item template. 
Global Store table should include but not limited to: 

|GSID	|		*Unique Indexed*	|ID of the item unique between all templates, like IP|
|AssetKey		|*Unique Indexed*	|asset string key, like url path |
|assetFile		|nvarchar			|reference an asset file where this item can be downloaded safely|
|descFile		|nvarchar			|reference a description file where this item can be downloaded safely|
|^|^				|-- NOTE: this file will contain asset file urls(maybe multiple files) and urls to MCML pages if the item is interactive|
|^|^				|-- NOTE: descFile will be stored in local server. Only the file existence is checked \
						for asset loading. If not exists or corrupted, download the assetFile again.|
|**D** majorversion	|smallint		|major version|
|**D** minorversion	|smallint		|minor version|
|**D** revision		|smallint		|revision|
|^|^				|-- NOTE: version: major.minor.revision|
|**D** isApproved		|bool			|if the AssetFile is offically approved|
|type			|tinyint		|like Item, AppCommand, App, model asset, texture asset, character asset, animation asset|
|^|^				|ID	template table|
|^|^				|1	item_template|
|^|^				|2	app_template|
|^|^				|3	appcommand_template|
|^|^				|4	model_asset_template|
|^|^				|5	texture_asset_template|
|^|^				|6	character_asset_template|
|^|^				|7	animation_asset_template|
|^|^				|-- NOTE: the rest of the data members will be deprecated or redefined to suit Aries project|
|**D** category		|nvarchar			|virtual folder: like model/char, char/v3/assets. similar to AssetKey. for human categorization.|
|**D** count			|int				|how many are left in store. nil for infinity.|
|**D** icon			|nvarchar			|icon to display. can be local or URL path.|
|**D** pBuyPrice		|int				|The price required to pay to buy this item from a vendor, in p cash.|
|**D** eBuyPrice		|int				|The price required to pay to buy this item from a vendor, in e cash.|
|**D** pSellPrice		|int				|The price that the vendor will pay you for the item when you sell it and if it is possible to be sold, in p cash.|
|**D** eSellPrice		|int				|The price that the vendor will pay you for the item when you sell it and if it is possible to be sold, in e cash.|
|^|^								|Put in 0 on both pSellPrice and eSellPrice, if the item cannot be sold to a vendor.|
|**D** batched			|int				|how many times the item is batch from the global store|

the following is removed in the original draft:
Author							userid who uploaded
UploadDate						date



---++Templates

The items are represented by objects that will act as a black box - users or developers do not need to know how it is working on the inside. 
The information stored in Global Store is mainly for display purpose and contain a "type" index which indicates what kind of item they are. 
To get the properties of an item, there will be a template table that holds all the information for all the possible item indices an object can have.
The "type" field of the global store specifies which table that the properties are stored. Different templates stores different types of items.
But they all have an entry in global store.


---+++Item Template
Item template is a MMORPG-like type item table. It defines all officially designed items. These items may have attributes that effect the user 
experience in the game world, such as slow down. Some of these items are not free, such as some limited edition mount or brilliant clothes.
Item template table(item_template) includes but not limited to:

|ID			|int		|SQL server generated ID <-- character.db ItemDatabase use this id|
|gsID		|int		|ID of the item in global store|
|**D** brand		|tinyint		|ownership|
|^|^			|ID	Brand|
|^|^			|0	PE owned|
|^|^			|1	cooperative owned in business|
|^|^			|NOTE: 2 UGC 3rd party or user owned, this type of item is stored in the asset template table which will describe later|
|^|^			|-- NOTE: all items are PE owned in Aries |
|**D** brandcode	|smallint		|ownership code|
|**D** expiredays	|smallint		|the expire time in days, 0 for permanent|
|**D** class		|indexed		|class.subclass.minorclass|
|class		|tinyint	|class of the item|
|^|^				| class name|
|^|^				| 1 Clothes and Hand-held|
|^|^				| 2 Consumable |
|^|^				| 3 Collectable|
|^|^				| 4 Readings|
|^|^				| 5 Mount MakeUps|
|^|^				| 6 Mount Food|
|^|^				| 7 Monthly-paid special|
|^|^				| 8 Decorate |
|^|^				| 9 Plants |
|^|^				| 10 Tools |
|^|^				| 11 Honors |
|subclass	|tinyint	|subclass of the item|
|^|^				| class subclass name|
|^|^				| 1	1	OverHead|
|^|^				| 1	2	Hat|
|^|^				| 1	3	Facial|
|^|^				| 1	4	Accessories|
|^|^				| 1	5	Shirt|
|^|^				| 1	6	Pants|
|^|^				| 1	7	Boots|
|^|^				| 1	8	Back|
|^|^				| 1	9	Gloves|
|^|^				| 1	10	Staff|
|^|^				| 1	11	Magical|
|^|^				| 1	12	Totem|
|^|^				| 1	13	Axe Temp slot|
|^|^				| 1	14	Mace Temp slot|
|^|^				| 1	15	Sword Temp slot|
|^|^				| 1	16	Dagger Temp slot|
|^|^				| 1	17	Shield Temp slot|
|^|^				| 2	1	General Food|
|^|^				| 2	2	General Potion|
|^|^				| 2	3	General Herb|
|**D** minorclass	|tinyint		|minorclass of the item|
|^|^				|The following table lists all available minorclass, subclass and class combinations and the minor/subclass name.\
				The table is imported from Ina's document, please refer to 帕拉巫物品及背包系统说明文档(ina).doc|
|^|^			|NOTE: the 3rd class in the document is obsoleted and splitted into the 2nd class|
|name		|nvarchar		|The item's name that will be displayed. |
|**D** ItemQuality	|tinyint		|The quality of the item: |
|^|^			|ID  Color  Quality  |
|^|^			|0  Grey  Poor|
|^|^			|1  White  Common|
|^|^			|2  Blue  Uncommon|
|^|^			|3  Gold  High-quality|
|^|^			|4  Red  Epic|
|*InventoryType	|tinyint		|In what character slot the item can be equipped.|
|^|^			|ID InventoryType|
|^|^			|1  OverHead|
|^|^			|2  Hat|
|^|^			|3  Facial|
|^|^			|4  Accessories|
|^|^			|5  Shirt|
|^|^			|6  Pants|
|^|^			|7  Boots|
|^|^			|8  Back|
|^|^			|9  Gloves|
|^|^			|10 Left Hand Only|
|^|^			|11 Right Hand Only|
|^|^			|12 One-Handed|
|^|^			|13 Two-Handed|
|^|^			|... ...|
|^|^			|31 Current Mount|
|^|^			|32 Current Follow|
|^|^			|... ...|
|^|^			|41 Mount Head|
|^|^			|42 Mount Wings|
|^|^			|43 Mount Legs|
|^|^			|NOTE: MaskInventoryType is written in the description file on global store table\
				If this item is equipted, the MaskInventoryType items will be hidden.|
|*AllowableGender	|tinyint		|Bitmask controlling which gender can obtain and use this item. Add ids together to combine possibilities.|
|^|^			|Value	Gender|
|^|^			|1		Female only|
|^|^			|2		Male only|
|^|^			|3		All genders|
|^|^			|-- NOTE: we don't explicitly distinguish user gender from their appearance or as an attribute in Aries|
|**D** RequiredContribution	|int			|The required contribution point the user needs to have to use this item.|
|**D** RequiredTitle		|nvarchar		|The required title the user needs to have to use this item.|
|MaxCount				|smallint	|Maximum number of copies of this item a user can have. Use 0 for infinite. 1 for unique owned|
|**D** *ContainerSlots		|smallint	|If the item is a bag, this field controls the number of slots the bag has.|
|*MaxCopiesInStack	|smallint	|The maximum number of copies of this item that can be stacked in the same slot.| 
|statsCount				|tinyint		|The number of stats used for this item. Only the first n stats are used. |
|stat_type_(1-10)			|tinyint		|The type of stat to modify. |
|stat_value_(1-10)		|smallint	|The value to change the stat type to.| 
|**D** hitdelay		|int			|The time in milliseconds between successive hits.|
|**D** spellid			|int			|The spell ID of the spell that the item can cast or trigger.|
|**D** spellcooldown	|int		|The cooldown in milliseconds for the specific spell controlling how often the spell can be used. Use -1 to use the default cooldown.|
|**D** spellcharges	|int		|The number of times that the item can used. If 0, then infinite charges are possible. |
|^|^			|If negative, then after the number of charges is depleted, the item is deleted as well. |
|^|^			|If positive, then the item is not deleted after all the charges are spent.|
|^|^			|NOTE: Spell or skill related logics can be stored in the description file on global store table\
								Some of them has very specific use or even web service calls.|
|**D** *binding	|tinyint		|The binding type for the item. |
|^|^			|ID	bind type|
|^|^			|0	no bound|
|^|^			|1	binds when used|
|^|^			|2	binds when equipped|
|^|^			|3	binds when picked up|
|^|^			|4	quest item|
|description		|nvarchar		|The description that appears at the bottom of the item tooltip.|
|CanUseDirectly		|bool		|if can be used directly|
|DestroyAfterUse	|bool		|if destroyed after use|
|CanSell			|bool		|can be sold to vendor|
|CanExchange		|bool		|can be exchanged among users|
|CanGift			|bool		|can be sent as a gift|
|RequirePayment		|tinyint		|Bitmask controlling how the item can be obtained|
|^|^						|0: can't be sold|
|^|^						|1: regular user only|
|^|^						|2: monthly paid user only|
|^|^						|3: monthly paid user and regular user|
|ExpireType		|tinyint		|expired type|
|^|^						|0: never expire|
|^|^						|1: expired after amount of time|
|^|^						|2: expired on datetime|
|ExpireTime		|int		|expire time in seconds, available if ExpireType == 1|
|ExpireDate		|datetime	|expire time in datatime, available if ExpireType == 2|
|DestroyAfterExpire	|tinyint	|if destroyed after expire, available if ExpireType == 1 or 2|
|^|^						|0: reserve for 30 days after expire|
|^|^						|1: destroy immediately after expire|
|Rechargeable	|bool		|if can be set to unexpired after expire, available if ExpireType == 1|
|**D** startquest	|int			|The ID of the quest that this item will start if right-clicked. See quest_template.entry|
|**D** material	|tinyint		|The material that the item is made of. The value here affects the sound that the item makes when equipped or used.|
|^|^						|Use 0 for consumable items like food, reagents, etc.|
|^|^						|ID Material|
|^|^						|0  consumable items|
|^|^						|1  Metal|
|^|^						|2  Wood|
|^|^						|3  Liquid|
|^|^						|4  Jewelry|
|^|^						|5  Chain|
|^|^						|6  Plate|
|^|^						|7  Cloth|
|^|^						|8  Leather|
|*ItemSetID		|int			|The ID of the item set that this item belongs to. Item sets are defined in ItemSet.db|
|**D** MaxComfortability	|int		|The maximum comfortability of this item, like the durability in MMORPG|
|*BagFamily	|smallint	|Implied bag family that the item can be placed in|
|^|^						|ID  BagFamily|
|^|^						|1  Clothes and Hand-held|
|^|^						|... ...|
|^|^						|21  Consumable|
|^|^						|22  Collectable|
|^|^						|23  Readings|
|^|^						|... ...|
|^|^						|31  Mount MakeUps|
|^|^						|32  Mount Food|
|^|^						|... ...|
|^|^						|41  Monthly-paid special|
|^|^						|... ...|
|^|^						|51  Home Decorate|
|^|^						|52  Home Plants|
|^|^						|53  Home Tools|
|^|^						|54  Home Honors|
|^|^						|... ...|
|**D** duration	|int		|The duration of the item in seconds. 0 for permanent|

NOTE: some client behavior fields may be removed to the global store description file

not included in the table:

batch
serial

-- NOTE: the following templates are all deprecated in Aries



---+++app_template and appcommand_template (deprecated)
app_template:
appcommand_template:



---+++Asset Templates (deprecated)
model_asset_template:
texture_asset_template:
character_asset_template:
animation_asset_template:




---++Item Instance
Keeping all item information along with each item is overkilling: all energy or speed-up potion have the same name, looks and properties. 
Some objects might have "personal" data such as charges, enchantments, nicknames or durability that must be stored on the item itself, 
but this can be added in a separate table item_instance.

The item_instance table holds individual item instance information for all items currently equipped or in some kind of character bag or world bag.
Combining with the data members of Global store table, item instance provides all data that needed in the process of item visualization without 
additional web service calls or local server data.


|guid		|int		|The GUID of the item. This number is unique for each item instance.|
|userid		|GUID		|The GUID of the character who has ownership of this item.|
|gsID		|int		|The item's global store gsID. See global_store.gsID|
|ObtainTime	|datetime	|time when the item is obtained, if the item is stackable, it records the last item obtained|
|bag		|smallint	|If it is 0, this item is equipped on character. (0 is an implied bag for equipped items).|
|^|^					|If it isn't 0 and not exceeding 10000, this is the BagFamily of the item global store template.|
|^|^					|If it isn't 0 and exceeding 10000, this is the implied bag for particular applications(e.x. Homeland or Pet apps).\
							Such application registration will open an implied BagFamily ID for the application|
|position	|int			|If the bag field is zero, then the position stands for the following character slots on the user: |
|^|^					|1  OverHead|
|^|^					|2  Hat|
|^|^					|3  Facial|
|^|^					|4  Accessories|
|^|^					|5  Shirt|
|^|^					|6  Pants|
|^|^					|7  Boots|
|^|^					|8  Back|
|^|^					|9  Gloves|
|^|^					|10 Left Hand|
|^|^					|11 Right Hand|
|^|^					|... ...|
|^|^					|31 Current Mount|
|^|^					|32 Current Follow|
|^|^					|... ...|
|^|^					|41 Mount Head|
|^|^					|42 Mount Wings|
|^|^					|43 Mount Legs|
|^|^					|... ...|
|^|^					|If it isn't 0 and not exceeding 10000, The position is the slot in the BagFamily where the item is kept. |
|^|^					|If it isn't 0 and exceeding 10000, The position is the slot in the implied bag for particular applications.|
|^|^					|NOTE: This field is auto-incremental. e.g. the position doesn't shift if the item is deleted from the inventory|
|^|^					|NOTE: this position field is changed from tinyint to int|
|ClientData	|nvarchar	|item instance client data|
|ServerData	|nvarchar	|item instance server data|
|^|^						|NOTE: Client data and server data are introduced from the original implementation of app MCML profile\
							which rely on the fact that the app profile servers trust the calls from client applications.\
							Now the profile content is divided by item instances and further divided into two field client data and server data.\
							Each side has a piece of memory in the each item instance and be responsible for the writing of each piece of memory.\
							The opposite side can only read the data. For example a growing plant may have the homeland position and rotation data\
							written by client application script. While the leveling data is written by the server according to the latest server\
							related data and time. In most curcomstances, client data is set and read by client script. Item system only keeps that\
							memory for client app because the data is totally user generated and can accept cheated data. Server data is written by\
							application server and read by client script that both side understand the same data structure.|
|**D** Soulbound	|bool		|is soul bound|
|**D** Scale		|float		|object scale|
|**D** ContainedInBagid	|int		|If the item is in a bag, the GUID of the bag item; otherwise 0|
|Copies			|smallint	|Current number of item copies in the instance stack. |
|**D** Duration	|tinyint		|Current duration |
|**D** Charges		|tinyint		|Current charges|
|**D** Comfortability  |tinyint	|Current item comfortability|



---++ Item Description File
GlobalStore.descFile
Reference a description file where this item can be downloaded safely. This file will contain asset file urls(maybe multiple files) 
and urls to MCML pages if the item is interactive descFile will be stored in local server. Only the file existence is checked 
for asset loading. If not exists or corrupted, download the assetFile again.

If the description file is nil or "", use the default description file by the class and subclass of the item template.

Default decription requirement:

|class		|subclass	|		name|
| 1 | Clothes and Hand-held|^|
| 1	| 1	| OverHead|
| 1	| 2	| Hat|
| 1	| 3	| Facial|
| 1	| 4	| Accessories|
| 1	| 5	| Shirt|
| 1	| 6	| Pants|
| 1	| 7	| Boots|
| 1	| 8	| Back|
| 1	| 9	| Gloves|
| 1	| 10 | Hand-held|
| 2 | Consumable|^|
| 2	| 1	| General Food|
| 2	| 2	| General Potion|
| 3			|/			| Collectable |
| 4			|/			| Readings|
| 5			|/			| Mount|
| 6			|/			| Mount MakeUps|
| 7			|/			| Mount Food|
| 8			|/			| Follow|
| 9			|/			| Monthly-paid special|
| 10		|/			| Interactive |
| 11		| Out-door  |^|
| 11		| 1			| House |
| 11		| 2			| Plants |
| 12		| In-door  |^|
| 12		| 1			| Decorate |
| 12		| 2			| Furniture |
| 12		| 3			| Tools |
| 13		|/			| Honors |

For class 1 items:

The following file name with additional "_U" can be optional

|class		|subclass	|		name|
| 1	| 1	| OverHead |
|^|^|icon: [gsID]_Overhead_[*whatever*]_U.png\
	model: [gsID]_Overhead_[*whatever*]_U.x\
	texture: [gsID]_Overhead_[*whatever*]_U.dds|
| 1	| 2	| Hat |
|^|^|icon: [gsID]_Hat_[*whatever*]_U.png\
	model: [gsID]_Hat_[*whatever*]_U.x\
	texture: [gsID]_Hat_[*whatever*]_U.dds|
| 1	| 3	| Facial |
|^|^|icon: [gsID]_Facial_[*whatever*].png\
	texture: [gsID]_Facial_[*whatever*].dds(recommanded)/png|
| 1	| 4	| Accessories |
|^|^|icon: [gsID]_Accessories_[*whatever*]_[dd:StyleID]_U.png\
	texture: [gsID]_Accessories_[*whatever*]_[dd:StyleID]_U.dds|
| 1	| 5	| Shirt |
|^|^|icon: [gsID]_[*whatever*]_[dd:StyleID]_U.png\
	textures: [gsID]_[*whatever*]_[dd:StyleID]_TU_U.dds\
			  [gsID]_[*whatever*]_[dd:StyleID]_TL_U.dds\
			  [gsID]_[*whatever*]_[dd:StyleID]_AU_U.dds\
			  [gsID]_[*whatever*]_[dd:StyleID]_AL_U.dds|
| 1	| 6	| Pants |
|^|^|icon: [gsID]_[*whatever*]_[dd:StyleID]_U.png\
	textures: [gsID]_[*whatever*]_[dd:StyleID]_LU_U.dds
			  [gsID]_[*whatever*]_[dd:StyleID]_LL_U.dds|
| 1	| 7	| Boots |
|^|^|icon: [gsID]_[*whatever*]_[dd:StyleID]_U.png\
	texture: [gsID]_[*whatever*]_[dd:StyleID]_FO_U.dds|
| 1	| 8	| Back |
|^|^|icon: [gsID]_Wings_[*whatever*]_[dd:StyleID]_U.png\
	texture: [gsID]_Wings_[*whatever*]_[dd:StyleID]_U.dds|
| 1	| 9	| Gloves |
|^|^|icon: [gsID]_[*whatever*]_[dd:StyleID]_U.png\
	texture: [gsID]_[*whatever*]_[dd:StyleID]_HA_U.dds|
| 1	| 10 | Hand-held |
|^|^|icon: [gsID]_HandHeld_1H_[*whatever*].png\
	model: [gsID]_HandHeld_1H_[*whatever*].x\
	texture: [gsID]_HandHeld_1H_[*whatever*].dds|

|class		|subclass	|		name|
| 2	| 1	| General Food|
|^|^|icon: [gsID]_Food_[*whatever*].png|
| 2	| 2	| General Potion|
|^|^|icon: [gsID]_Potion_[*whatever*].png|


|class		|subclass	|		name|
| 11		| 1			| House |
|^|^|icon: [gsID]_House_[*whatever*].png\
	model: [gsID]_House_[*whatever*]_T[n].x\
	textures: [gsID]_House_[*whatever*]_1.dds\
			  [gsID]_House_[*whatever*]_2.dds\
			  [gsID]_House_[*whatever*]_3.dds\
			  [gsID]_House_[*whatever*]_n.dds\
	or model: [gsID]_House_[*whatever*].x\
	texture: [gsID]_House_[*whatever*].dds|
	
	TODO: multi-level house
	
| 11		| 2			| Plants |
|^|^|icon: [gsID]_Plants_[*whatever*].png\
	model: [gsID]_Plants_[*whatever*].x\
	textures: [gsID]_Plants_[*whatever*].dds\

|class		|subclass	|		name|
| 12		| 1			| Decorate |
| 12		| 2			| Furniture |
| 12		| 3			| Tools |