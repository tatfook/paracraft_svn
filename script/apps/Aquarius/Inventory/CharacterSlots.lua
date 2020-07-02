--[[
Title: inventory page for aquarius item system
Author(s): WangTian
Date: 2009/2/10
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Inventory/GlobalStore.lua");
------------------------------------------------------------

Desc: 
ParaWorld item system allows all users to pick, carry, use, sell, buy, wear items, and more important to contribute the item to the 
community and even the item itself. The big picture of a ParaWorld is a set of worlds which consists of various items and the related application 
upon them. Those items includes models, characters, animations and many others that can be either officially packed or user generated.

ParaWorld item system uses an item-in-bag metaphore that all avaiable items are in bag slots. Character inventory consists of several catagories 
according to the classification of items. Items are classified with a 3 level hierarchy that uniquely identify the item type.
Lorne's document lists all available minorclass, subclass and class combinations and the minor/subclass name. Please refer to Lorne's document 
策划部-《ParaWorld》物品系统设计文档-Lorne-090202.xls

Listing all items in the inventory will be overkill: different kind of items appears in one big gridview list. So we separate the items with the 
previous discribed class.subclass.minorclass. Each category is a bag with the same capacity. This capacity is upgraded with the character's 
contribution or leveling. But the number of slots is relatively large comparing to MMORPGs. 

All items have class and subclass. On the db server side, there are class*subclass bags. Inventory is then designed with the same 2 level hierarchy 
padding two level selectors on the side. Items with the same class.subclass store in the same bag(they may have different minorclass).
Since the inventory bag can contain only one type of items, so swapping self items can't be performed between bags.
]]

local GlobalStorePage = {};
commonlib.setfield("MyCompany.Aquarius.GlobalStorePage", GlobalStorePage);

-- validate bag capacity ContainerSlots
function GlobalStorePage.GetItems()
end