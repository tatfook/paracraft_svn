--[[
Title: code behind for make machine
Author(s): WD
Date: 2011/11/08

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/CastMachine_subpage.teen.lua");

--]]

local ItemManager = Map3DSystem.Item.ItemManager;
local GetItemByID = ItemManager.GetGlobalStoreItemInMemory;
local GetItemsCount = ItemManager.GetItemCountInBag;
local GetItemsInBag = ItemManager.GetItemsInBag;
local hasGSItem = ItemManager.IfOwnGSItem;
local GetExtTemp = ItemManager.GetExtendedCostTemplateInMemory;
local MSG = _guihelper.MessageBox;
local echo = commonlib.echo;

local CastMachine_subpage = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.CastMachine_subpage");

CastMachine_subpage.file_path = "config/Aries/Others/make_item.csv";
CastMachine_subpage.filter = CastMachine_subpage.filter or 1;
CastMachine_subpage.DisplayItems = {};
CastMachine_subpage.ParentTable = {name = "",parent = {},};
CastMachine_subpage.IncomingItem = {};
CastMachine_subpage.MaterialsTable = {};
CastMachine_subpage.SkillLevel = 5;
CastMachine_subpage.MAX_SKILL_LEVEL= 21999;

CastMachine_subpage.EXTERNAL_DATA = true;
--test
CastMachine_subpage.Items = {
	--初级
	[1] = {
		{name = "字母E",exID = 729, gsid = 30202,  isNew = true, },

		{name = "蟹壳钢琴",exID = 477, gsid = 30187,  },
		{name = "时光沙漏",exID = 475, gsid = 30185,  },
		
		{name = "丛丛草",exID = 221, gsid = 30026, },
		{name = "不倒翁",exID = 438, gsid = 30102,  },
		{name = "晃晃木马",exID = 439, gsid = 30101,  },
		{name = "向日葵抱枕",exID = 431, gsid = 30166, },
		{name = "荷叶抱枕",exID = 432, gsid = 30167,  },
		{name = "大叶子靠枕",exID = 433, gsid = 30168, },
		
		{name = "巧克力花圃",exID = 397, gsid = 30136, },
		{name = "奶酪复古电话",exID = 398, gsid = 30137, },
		{name = "孔方挂饰",exID = 384, gsid = 30120, },
		{name = "长寿椅",exID = 341, gsid = 30109, },
		{name = "工夫茶几",exID = 344, gsid = 30112,},
		{name = "水蓝栅栏",exID = 216, gsid = 30021, },
		{name = "水蓝小栅栏",exID = 217, gsid = 30022, },
		{name = "棕色栅栏",exID = 218, gsid = 30033, },
		{name = "棕色小栅栏",exID = 219, gsid = 30042, },
		{name = "青草垛",exID = 220, gsid = 30025, },
		{name = "树墩墩",exID = 222, gsid = 30030, },
		{name = "小红花凳",exID = 223, gsid = 30032, },
		{name = "花圃",exID = 224, gsid = 30012, },
	},
	--1 级
	[2] = {
		{name = "字母F",exID = 731, gsid = 30203,  isNew = true, },
		{name = "字母G",exID = 730, gsid = 30204,  isNew = true, },

		{name = "梦香床",exID = 434, gsid = 30169, },
		{name = "橘子糖挂钟",exID = 399, gsid = 30138, },
		{name = "草莓地毯",exID = 400, gsid = 30139, },
		{name = "红鳞金鱼挂饰",exID = 385, gsid = 30119, },
		{name = "绿鳞金鱼挂饰",exID = 386, gsid = 30118, },
		{name = "炫彩陶罐",exID = 342, gsid = 30110,  },
		{name = "竹子栅栏",exID = 225, gsid = 30052, },
		{name = "黄色幸福石",exID = 226, gsid = 30034, },
		{name = "绿色生命石",exID = 227, gsid = 30035, },
		{name = "橙色力量石",exID = 228, gsid = 30036, },
		{name = "紫色魅力石",exID = 229, gsid = 30037, },
		{name = "红色爱心石",exID = 230, gsid = 30038, },
		{name = "蓝色智慧石",exID = 231, gsid = 30039, },
		{name = "白色未来石",exID = 232, gsid = 30040, },
		{name = "青青小石椅",exID = 233, gsid = 30067, },
		{name = "青青小石凳",exID = 234, gsid = 30068, },
		{name = "冰雪花圃",exID = 235, gsid = 30013, },
	},
	[3] = {
		{name = "洗碗台",exID = 751, gsid = 30237,  isNew = true, },
		{name = "字母C",exID = 733, gsid = 30200,  isNew = true, },
		{name = "字母D",exID = 732, gsid = 30201,  isNew = true, },

		{name = "泡泡机",exID = 238, gsid = 30050, },
		{name = "水泡大吊灯",exID = 476, gsid = 30186,  },
		{name = "藤蔓浴缸",exID = 435, gsid = 30170, },
		{name = "拐棍糖秋千",exID = 401, gsid = 30140, },
		{name = "玲珑宫灯",exID = 339, gsid = 30107, },
		{name = "小花鼓",exID = 340, gsid = 30108,  },
		{name = "石雕狮子",exID = 345, gsid = 30113, },
		{name = "石边花盆",exID = 297,gsid = 30103,},--297 30103
		{name = "泡泡池塘",exID = 236, gsid = 30028, },
		{name = "紫藤萝栅栏",exID = 237, gsid = 30053, },
		{name = [[“哈”字气球]],exID = 239, gsid = 30043, },
		{name = [[“奇”字气球]],exID = 240, gsid = 30044, },
		{name = [[“小”字气球]],exID = 241, gsid = 30045, },
		{name = [[“镇”字气球]],exID = 242, gsid = 30046, },
		{name = [[“欢”字气球]],exID = 243, gsid = 30047, },
		{name = [[“迎”字气球]],exID = 244, gsid = 30048, },
		{name = [[“你”字气球]],exID = 245, gsid = 30049, },
		{name = "遮阳伞",exID = 246, gsid = 30088, },
		--247
		{name = "四平八稳冰砖",exID = 248, gsid = 30090, },
		{name = "尖尖冰砖",exID = 249, gsid = 30091, },
		{name = "冰雕心语",exID = 250, gsid = 30059, },
		{name = "冰雕礼盒",exID = 251, gsid = 30060, },
		{name = "青青小石桌",exID = 252, gsid = 30066, },
		{name = "短腿小沙发",exID = 253, gsid = 30085, },
		{name = "短腿小茶几",exID = 254, gsid = 30084, },
		{name = "三层小柜",exID = 255, gsid = 30087, },
	},
	[4] = {
		{name = "字母A",exID = 734, gsid = 30198,  isNew = true, },
		{name = "字母B",exID = 735, gsid = 30199,  isNew = true, },

		{name = "能量池",exID = 478, gsid = 30184, },
		{name = "魔方奶酪床",exID = 402, gsid = 30141, },
		{name = "七彩伞",exID = 298, gsid = 30104, },--298 30104
		{name = "逗逗雪人",exID = 256, gsid = 30069, },
		{name = "丫丫雪人",exID = 257, gsid = 30070, },
		{name = "妮妮雪人",exID = 258, gsid = 30071, },
		{name = "乐乐雪人",exID = 259, gsid = 30072, },
		{name = "大红花凳",exID = 260, gsid = 30092, },
		{name = "古井木桶",exID = 261, gsid = 30058, },
		{name = "冰晶树",exID = 262, gsid = 30078, },
		{name = "雪绒花地毯",exID = 263, gsid = 30081, },
		{name = "毛线娃娃",exID = 264, gsid = 30082, },
		{name = "灯笼花",exID = 265, gsid = 30024, },
		{name = "靓靓衣橱",exID = 266, gsid = 30086, },
		{name = "暖暖雪绒床",exID = 267, gsid = 30083, },
		{name = "许愿灯",exID = 268, gsid = 30095, },
	},
	[5] = {
		{name = "字母X",exID = 736, gsid = 30221,  isNew = true, },
		{name = "字母Y",exID = 737, gsid = 30222,  isNew = true, },

		{name = "檀香木床",exID = 346, gsid = 30114, },
		{name = "七彩树",exID = 299 , gsid = 30105,},--299 30105
		{name = "海苔冰灯",exID = 269, gsid = 30080, },
		{name = "冰晶烛台",exID = 270, gsid = 30079, },
		{name = "晃晃稻草人",exID = 271, gsid = 30065, },
	},
	[100] = {
		{name = "糖果小屋",exID = 597, gsid = 30135, },
		{name = "环保小屋",exID = 437, gsid = 30180, },
		{name = "新春小屋",exID = 300, gsid = 30007, },
		{name = "冰雪小屋",exID = 167, gsid = 30006, },
	},
	[101] = {
		{name = "简易捕兽网",exID = 318, gsid = 17079, },
		{name = "1级捕兽网",exID = 319, gsid = 17080, },
		{name = "2级捕兽网",exID = 320, gsid = 17081, },
		{name = "3级捕兽网",exID = 321, gsid = 17082, },
	},
}

--[[
	装备，符文，消耗品，家具，其他
]]
CastMachine_subpage.ItemsCates = 
{
	[1] = {class={1},subclass={2,5,6,7,8,9,10,11,12,14,15,16,17,18,19,70,71},},
	[2] = {class={18},subclass={2},},
	[3] = {class={3},subclass={2,5,7,9,10},},
	[4] = {class={8,9},subclass={2,4}},
	[5] = {},
};
function CastMachine_subpage:GetSkillLevel(level)
	if(hasGSItem(level))then 
		return level-21100;
	else
		if(level == 21100)then return 1;end
		return self:GetSkillLevel(level-1);
	end
end

function CastMachine_subpage:Init()
	self.page = document:GetPageCtrl();
	--self.SkillLevel = self:GetSkillLevel(self.MAX_SKILL_LEVEL);

	if(not self.initialized)then
		local i,v; 

		if(not self.EXTERNAL_DATA)then
			for i,v in ipairs(self.Items)do
				local i2,v2;
				for i2,v2 in ipairs(v)do
					v2.is_selected = false;
					local item = GetItemByID(v2.gsid);
					if(item)then
						v2.texture = item.icon;
					end
				end
			end
		else

			self:LoadData();

			--[[
			local level_flag;
			for level_flag = 1,self.SkillLevel do
				for i,v in ipairs(self.Items[level_flag])do
					local item = GetItemByID(v.gsid)
					if(item)then
						v.name = item.template.name or "undefined name";
						v.texture = item.icon;
						v.is_selected = false;
					end
					if(#v.exid_list > 0)then
						v.exID = v.exid_list[1];
					end
				end
			end
			]]
		end

		
		self.initialized = 0;
	end
	self.DisplayItems = self.Items[self.filter]

	if(#self.DisplayItems > 0 and not self.IncomingItem.gsid)then
		self.IncomingItem = self.DisplayItems[1];
		self.ParentTable.parent.page:SetValue("selectItem",self.IncomingItem.gsid or 0);
		self.IncomingItem.is_selected = true;
	end

	if(self.ID() and self.ExID())then
		self:GetMaterials(self.IncomingItem.exID,self.IncomingItem.gsid);	
	end
end

function CastMachine_subpage:LoadData()
	if(self.isCfgLoaded)then 
		return self.Items;
	end
	self.isCfgLoaded = true;
	local file = ParaIO.open(self.file_path, "r");
	self.Items = {};

	if(file:IsValid())then
		local strValue = file:readline();
		local level_flag = 0;
		while(strValue)do
			--strValue = string_trim(strValue,[["]]);
			--commonlib.echo(strValue);
			if(string.sub(strValue,0,5) == "LEVEL")then
				--level_flag = level_flag + 1;
			else
				local new_table = {gsid,exid_list={}};
				local numb;
				for numb in string.gmatch(strValue,"(%d+)[%,]?") do
					if(not new_table.gsid)then
						new_table.gsid = tonumber(numb);
						local item = GetItemByID(new_table.gsid)
						if(item)then
							new_table.class = item.template.class;
							new_table.subclass = item.template.subclass;
							new_table.name = item.template.name;
							new_table.texture = item.icon;
						end
					else
						new_table.exID = tonumber(numb);
						--table.insert(new_table.exid_list,tonumber(numb));	
					end
				end
				--if(not self.Items[level_flag])then 
					--self.Items[level_flag] = {};
				--end

				local i,v,i2,v2
				for i,v in ipairs(self.ItemsCates)do
					if(not self.Items[i])then 
						self.Items[i] = {};
					end	
					if( i ~= 5)then
						
						if(self:IsContain(v.class,new_table.class) and self:IsContain(v.subclass,new_table.subclass))then
							table.insert(self.Items[i],new_table)
						end
					else
										
						local b;
						for i2,v2 in ipairs(self.ItemsCates)do
							if(self:IsContain(v2.class,new_table.class) and self:IsContain(v2.subclass,new_table.subclass))then
								b = 0
								break;
							end
						end
						if(not b)then
							table.insert(self.Items[i],new_table)
						end
					end
				end

				--table.insert(self.Items,new_table);	
				--table.insert(self.Items[level_flag],new_table);	
			end
				
			strValue = file:readline();
		end
		file:close();
	end
	return self.Items;
end

function CastMachine_subpage:SetTexture(gsid)
	local item = GetItemByID(gsid);
	if(item)then
	self.IncomingItem.texture = item.icon;
	end
end

function CastMachine_subpage:GetDataSource(index)
	self.Items_Count = 0;
	if(self.DisplayItems)then
		self.Items_Count = #self.DisplayItems;
	end
	local displaycount = math.ceil(self.Items_Count / self.PageSize) * self.PageSize;
	if(displaycount == 0)then
		displaycount = self.PageSize;
	end

	local i;
	for i = self.Items_Count + 1,displaycount do
		self.DisplayItems[i] = { gsid = 0,name="",exID=0,is_selected=false, };
	end

	if(index == nil) then
		return #(self.DisplayItems);
	else
		return self.DisplayItems[index];
	end
end

function CastMachine_subpage.GetDataSource2(index)
	if(index == nil) then
		return #(CastMachine_subpage.MaterialsTable);
	else
		return CastMachine_subpage.MaterialsTable[index];
	end
end

function CastMachine_subpage.Filter()
	local self = CastMachine_subpage;
	return self.filter;
end

function CastMachine_subpage:ResetStates()
	self.IncomingItem = {};
	self.DisplayItems = {}
	self.filter = 1;
end

function CastMachine_subpage:IsContain(tb,numb)
	if(not tb or not numb)then return end
	local i,v
	for i,v in ipairs(tb)do
		if(v == numb)then
			return true
		end
	end
	return false;
end

function CastMachine_subpage:Update(newfilter,refresh_cb)
	if(newfilter and newfilter ~= self.filter)then
		self.filter = tonumber(newfilter);
		self.DisplayItems = self.Items[self.filter]

		local i,v
		for i,v in ipairs(self.DisplayItems)do
			if(v.is_selected)then
				v.is_selected = false;
			end
		end

		if(refresh_cb)then
			refresh_cb();
		else
			self:Refresh()
		end

	end
end

function CastMachine_subpage:BindParent(name,parent)
	if(not name and type(name) ~= "string")then
		commonlib.echo("must specify parent name for bind.");
		return;
	end

	if(not parent) then
		commonlib.echo("the parent is nil.");
		return;
	end

	self.PageSize = 11;
	self.ParentTable.name = name;
	self.ParentTable.parent = parent;

	if(self.page == nil) then
		self.page = parent.page;	
	end
end

function CastMachine_subpage:Refresh(delta)
	if(self and self.page)then
		self.page:Refresh(delta or 0.1);
	end
end

function CastMachine_subpage:OnClickItem(arg)
	if(arg)then
		local i,v; 
		for i,v in ipairs(self.DisplayItems)do
			if(v.gsid == arg)then
				
				--echo("+++++++++++++++++++++item++++++++++++++++++")
				--echo(v);
				--print(v.exID);
				v.is_selected = true;
				self.IncomingItem = v;
				--echo(self.IncomingItem)
				self:GetMaterials(self.ExID(),self.ID());
			else
				v.is_selected = false;
			end
		end

		if(self.ParentTable.parent)then
			self.ParentTable.parent:Refresh(); 
		end
	end
end

function CastMachine_subpage:GetMaterials(exid,gsid)
	--echo("++++++++++++++++++++++++++++exid gsid+++++++++++++++++++++++++++")
	--print(exid);
	local temp = GetExtTemp(exid);
	self.MaterialsTable = {};
	--echo("++++++++++++++++++++++++++++GetExtTemp+++++++++++++++++++++++++++")
	--echo(temp);

	if(temp)then
		local tos = temp.tos;
		if(tos)then
			local i3,v3;
			for i3,v3 in ipairs(tos)do
				if(v3.key == self.IncomingItem.gsid)then
					local froms = temp.froms;
					local i4,v4;
					--commonlib.echo(froms);
					for i4,v4 in ipairs(froms)do
						local _, __, ___, copies = hasGSItem(v4.key)
						local item = GetItemByID(v4.key);
						local name,texture;
						if(item)then
							name = item.template.name;
							texture = item.icon;
						end
						local material = {gsid = v4.key,value = v4.value,name = name or "",texture = texture or "",hold_count = copies or 0,};
						table.insert(self.MaterialsTable,material);
					end
					break;
				end
			end
		end
	end	

	--echo("++++++++++++++++++++++++++++MaterialsTable+++++++++++++++++++++++++++")
	--echo(self.MaterialsTable)
end

function CastMachine_subpage.GetNameNumber(name,hold_count,value)
	return string.format("%s(%d/%d)",name or "",hold_count or 0,value or 0);
end

function CastMachine_subpage.CanMake()
	if(#CastMachine_subpage.MaterialsTable == 0)then return false; end
	local make = true;
	local i,v;
	for i, v in ipairs(CastMachine_subpage.MaterialsTable)do
		if(v.hold_count < v.value)then
			make = false;
			break;
		end
	end
	return make;
end

function CastMachine_subpage.GetPrice()
	return CastMachine_subpage.IncomingItem.price or "";
end

function CastMachine_subpage.Name()
	return CastMachine_subpage.IncomingItem.name or "undefined name";
end

function CastMachine_subpage.Texture()
	return CastMachine_subpage.IncomingItem.texture or "";
end

function CastMachine_subpage.ID()
	return CastMachine_subpage.IncomingItem.gsid;
end

function CastMachine_subpage.ExID()
	return CastMachine_subpage.IncomingItem.exID;
end

