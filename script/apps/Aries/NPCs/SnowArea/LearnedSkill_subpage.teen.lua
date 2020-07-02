--[[
Title: code behind for make machine
Author(s): WD
Date: 2011/11/08

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/LearnedSkill_subpage.teen.lua");
local LearnedSkill_subpage = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.LearnedSkill_subpage");
--]]

local ItemManager = Map3DSystem.Item.ItemManager;
local GetItemByID = ItemManager.GetGlobalStoreItemInMemory;
local GetItemsCount = ItemManager.GetItemCountInBag;
local GetItemsInBag = ItemManager.GetItemsInBag;
local GetItemByBagAndOrder = ItemManager.GetItemByBagAndOrder;
local hasGSItem = ItemManager.IfOwnGSItem;
local GetExtTemp = ItemManager.GetExtendedCostTemplateInMemory;
local MSG = _guihelper.MessageBox;
local echo = commonlib.echo;
local math_floor = math.floor

NPL.load("(gl)script/apps/Aries/Desktop/GenericTooltip.lua");
local GenericTooltip = CommonCtrl.GenericTooltip:new();

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");
local CastMachine = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.CastMachine");
local LearnedSkill_subpage = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.LearnedSkill_subpage");
local SPEC_SKILL_CSV = "config/Aries/Others/specskill.csv";
local MAKE_ITEM_CSV = "config/Aries/Others/make_item.csv";
local SKILL_BAG_ID = 0
local MAX_LEARNED_SPEC = 2;
local CHECK_CLASS = 0;

LearnedSkill_subpage._DEBUG = LearnedSkill_subpage._DEBUG or false;
function LearnedSkill_subpage:LOG(caption,obj)
	if(self._DEBUG)then
		echo(caption);
		echo(obj);
	end
end
LearnedSkill_subpage.LearnedSkill = {}
--LearnedSkill_subpage.visible = false;

LearnedSkill_subpage.MakableItems = {};

LearnedSkill_subpage.ItemsCates = 
{
	[21106] = {class={18},subclass={2},title_name = "符文师",desc = "",checkable=true,},
	[21107] = {class={3},subclass={10},title_name = "药剂师",desc = "",checkable=true,},
	[21105] = {class={3},subclass={5},title_name = "厨师",desc = "",checkable=true,},
	[21108] = {class={3},subclass={6},title_name = "珠宝匠",desc = "",checkable=true,},
	[21109] = {title_name = "草药师",desc = "",checkable=false,},
	[21110] = {title_name = "矿工",desc = "",checkable=false,},
};

LearnedSkill_subpage.MakeSkill = {}
LearnedSkill_subpage.MAKABLE = LearnedSkill_subpage.MAKABLE or false;

function LearnedSkill_subpage:Init()
	self.page = document.GetPageCtrl();
end

LearnedSkill_subpage.EXP_CALC_FACTOR = .016
LearnedSkill_subpage.TARGET_COLOR= {
	[0] = "#757575",[1] = "#25b025",[2] = "#cccc00",[3] = "#d17110",
}
--EXP_CALC = SPEC_LVL / (2 * SPEC_LVL - TARGET_REQUIRED_LVL) - (SPEC_LVL - TARGET_REQUIRED_LVL) * EXP_CALC_FACTOR
function LearnedSkill_subpage:_GetColor(f)
	
	if(f <= 0)then
		return LearnedSkill_subpage.TARGET_COLOR[0]
	elseif(f < .5)then
		return LearnedSkill_subpage.TARGET_COLOR[1]
	elseif(f < .8 and f >= .5)then
		return LearnedSkill_subpage.TARGET_COLOR[2]
	elseif(f >= .8)then
		return LearnedSkill_subpage.TARGET_COLOR[3]
	end 
	return LearnedSkill_subpage.TARGET_COLOR[0];
end

function LearnedSkill_subpage:BuildSpecskillList()
	if(not self)then echo("unpass self object") return end
	self:LoadData()

	local i,v,k,v1,i2,v2
	for i,v in ipairs(self.MakeSkill)do
		--if spec is learned,mount a table to LearnedSkill
		-- @note: always show the 
		--if(hasGSItem(v.gsid))then
		if(v.gsid~=21109 and v.gsid~=21110) then
			local tb = {spec_id = v.gsid,name = v.name,list = {}}

			for k,v1 in pairs(self.MakableItems)do
				if(k == v.gsid)then
					for i2,v2 in ipairs(v1)do
						local units = self:GetMakeableUnits(v2.exID);
						local temp = self.ExchangeTempList[v2.exID];
						local canmake = false;
						local exp = self.MakableItemsNameTable[v2.name].exp;
						local spec_exp = self.GetItemUnits(v.gsid) or 0
						
						if( spec_exp >= exp and units > 0)then
							canmake = true;
						end

						local f;
						if( (2 * spec_exp - exp) == 0) then
							f = 0;
						else
							f = spec_exp / ( 2 * spec_exp - exp) - ( spec_exp - exp) * self.EXP_CALC_FACTOR
						end
						f = math.abs(f);

						local colour = self:_GetColor(f)
						if(not canmake)then colour = self.TARGET_COLOR[0] end 
						table.insert(tb.list,
							{text=v2.name,gsid = v2.gsid,spec_gsid=v.gsid,
							exp = exp or 0,is_selected = false,
							colour = colour,units = units,mount_exp = f,
							canmake= canmake,spec_exp = spec_exp or 0,})
					end
					break;
				end
			end
		
			self:UpdateSpec(tb)
		end
	end

	self:LOG("LearnedSkill_subpage.LearnedSkill",self.LearnedSkill)
end

--[[
	if skill is not exist add new.then check makable units needs to update
]]
function LearnedSkill_subpage:UpdateSpec(tb)
	local i,v,b
	for i,v in ipairs(self.LearnedSkill)do
		if(v.spec_id == tb.spec_id)then
			local i2,v2
			for i2,v2 in ipairs(v.list)do
				local i3,v3
				for i3,v3 in ipairs(tb.list)do
					if(v2.gsid == v3.gsid)then
						if(v2.units ~= v3.units)then
							v2.units = v3.units;
						end
						if(v2.canmake ~= v3.canmake)then
							v2.canmake = v3.canmake;
						end
						if(v2.colour ~= v3.colour)then
							v2.colour = v3.colour
						end
						if(v2.mount_exp ~= v3.mount_exp)then
							v2.mount_exp = v3.mount_exp
						end
						if(v2.spec_exp ~= v3.spec_exp)then
							v2.spec_exp = v3.spec_exp
						end
					end
				end
			end
			b = 0
		end
	end

	if(not b)then
		table.insert(self.LearnedSkill,tb)
	end
end

function LearnedSkill_subpage:GetMakeableUnits(exID)
	if(not exID)then return 0 end
	local k,v,i1,v1,i2,v2,units
	local temp = self.ExchangeTempList[exID];
	if(temp and temp.froms)then
		local tb = {};
		for i2,v2 in ipairs(temp.froms)do
			if(v2.key and v2.key >0)  then
				local copies = self.GetItemUnits(v2.key)
				table.insert(tb,{units = v2.value,copies = copies or 0,});
			end
		end
		units = self.calcUnits(tb);		
	end
	return units or 0
end

--[[
	tb = {
		{units,copies},
	}
]]
function LearnedSkill_subpage.calcUnits(tb)
	local i,v; 
	local v1;
	for i,v in ipairs(tb)do
		local f = math_floor(v.copies / v.units)
		if(not v1)then v1 = f or 0; end
		if(f < v1)then
			v1 = f;
		end
	end
	return v1;
end

function LearnedSkill_subpage.GetItemUnits(gsid)
	local has, _, _, copies = hasGSItem(gsid);
	return copies or 0
end

function LearnedSkill_subpage:LoadData()
	--load specskill data
	if(not self.SPEC_CFG_LOADED)then
		self.SPEC_CFG_LOADED = 0
		local file = ParaIO.open(SPEC_SKILL_CSV, "r");

		local function isRepeatSkill(gsid)
			local i,v 
			for i,v in ipairs(LearnedSkill_subpage.MakeSkill)do
				if(v.gsid == gsid)then return true end
			end
			return false;
		end --isRepeatSkill

		if(file and file:IsValid())then
			local strValue = file:readline();
			while(strValue)do
				local new_table = {};
				local v;
				for v in string.gfind(strValue, "([^,]+)") do
					if(not new_table.name)then
						new_table.name = v;
					elseif(not new_table.gsid)then	
						v = tonumber(v)
						new_table.gsid = v;
					elseif(not new_table.desc)then
						new_table.desc = v;
					elseif(not new_table.exid)then
						new_table.exid = tonumber(v);
					end
				end

				if(not new_table.desc)then
					new_table.desc = "这里是描叙";
				end

				if(new_table.gsid and not isRepeatSkill(new_table.gsid))then
					self.ItemsCates[new_table.gsid].desc = new_table.desc
					table.insert(self.MakeSkill,new_table);
				end

				strValue = file:readline();
			end --strValue
			file:close();
		else
			echo("can not found cfg file!")
			return;
		end  

		self:LOG("LearnedSkill_subpage.MakeSkill:",self.MakeSkill)
	end 

	--load makable item data
	if(not self.MAKABLE_ITEMS_LOADED)then
		self.MAKABLE_ITEMS_LOADED = 0;	
		if(not self.MakableItemsNameTable)then
			self.MakableItemsNameTable = {}
		end

		if(not self.ExchangeTempList)then
			self.ExchangeTempList = {}
		end

		local k,v
		for k,v in pairs(self.ItemsCates)do
			if(not self.MakableItems[k])then 
				self.MakableItems[k] = {};
			end	
		end


		file = ParaIO.open(MAKE_ITEM_CSV, "r");
		if(file and file:IsValid())then
			local strValue = file:readline();

			while(strValue)do
				local new_table = {};
				local numb;
				local units;--hold untis of self
				for numb in string.gmatch(strValue,"(%d+)[%,]?") do
						numb = tonumber(numb) or 0;
					if(not new_table.spec_id)then
						new_table.spec_id = numb
					elseif(not new_table.gsid)then
						new_table.gsid = numb
						local item = GetItemByID(new_table.gsid)
						if(item and item.template)then
							units = self.GetItemUnits(new_table.gsid);
							new_table.class = item.template.class;
							new_table.subclass = item.template.subclass;
							new_table.name = item.template.name or "unknown";
							--new_table.texture = item.icon;
							new_table.qty = item.template.stats[221] or -1
							new_table.units = units;
						end
					else
						new_table.exID = numb
					end
				end

				if(not self.MakableItemsNameTable[new_table.name] and new_table.gsid  ~= 0)then
					--cache templates data
					if(new_table.exID ~= 0 and not self.ExchangeTempList[new_table.exID])then
						self.ExchangeTempList[new_table.exID] = {};
						local temp = GetExtTemp(new_table.exID);

						if(temp)then
							self.ExchangeTempList[new_table.exID].tos = temp.tos or {};
							self.ExchangeTempList[new_table.exID].froms = temp.froms or {};
							self.ExchangeTempList[new_table.exID].pres = temp.pres or {};

							--get exp
							if(temp.pres)then
								local i3,v3
								for i3,v3 in ipairs(temp.pres)do
									--check experience
									if(v3.key and self.ItemsCates[v3.key])then
										new_table.exp = v3.value or 0
									end
								end
							end	
						end	
					end

					--static 
					self.MakableItemsNameTable[new_table.name] = {gsid = new_table.gsid,spec_id = new_table.spec_id,
																	exid=new_table.exID,qty = new_table.qty,
																	exp = new_table.exp or 0,}
				end

				 

				if(self.ItemsCates[new_table.spec_id] and not self._ContainsMakableItem(new_table))then
					if(CHECK_CLASS == 0 )then
						table.insert(self.MakableItems[new_table.spec_id],new_table);
					elseif(CHECK_CLASS == 1)then
						if(self:IsContain(v.class,new_table.class) and self:IsContain(v.subclass,new_table.subclass))then
							table.insert(self.MakableItems[new_table.spec_id],new_table);
						end
					end
				else
					echo(string.format("item %s to be filter. ", (new_table.gsid or "nil?")))
				end
				strValue = file:readline();
			end
			file:close();
		else
			echo("can not found cfg file!")
			return;
		end

		self:LOG("LearnedSkill_subpage.MakableItemsNameTable",self.MakableItemsNameTable)
		self:LOG("LearnedSkill_subpage.MakableItems:",self.MakableItems)
		self:LOG("LearnedSkill_subpage.ExchangeTempList",self.ExchangeTempList)
	end
end

function LearnedSkill_subpage._ContainsMakableItem(new_table)
	local SPEC_ITEMS = LearnedSkill_subpage.MakableItems[new_table.spec_id]
	local i,v 
	for i,v in ipairs(SPEC_ITEMS)do
		if(v.gsid == new_table.gsid or v.name == new_table.name)then 
			echo(string.format("gsid \"%s\"or name \"%s\"is repeated,pls check config file!!!",new_table.gsid,new_table.name))
			return true 
		end
	end
	return false;
end
function LearnedSkill_subpage:IsContain(tb,numb)
	if(not tb or not numb)then return end
	local i,v
	for i,v in ipairs(tb)do
		if(v == numb)then
			return true
		end
	end
	return false;
end

function LearnedSkill_subpage:GetDataSource(index)
	if(index == nil) then
		return #(self.MakeSkill);
	else
		return self.MakeSkill[index];
	end
end

function LearnedSkill_subpage:GetMakeSkill(gsid)
	if(self.MakeSkill) then
		local k,v;
		for k,v in ipairs(LearnedSkill_subpage.MakeSkill) do
			if(v.gsid == gsid) then
				return v;
			end
		end
	end
end

function LearnedSkill_subpage:OnPurchaseSkillPoints(gsid, default_count)
	gsid = tonumber(gsid)
	if(not gsid)then return end

	if(not CastMachine.CanLearn(gsid)) then
		_guihelper.MessageBox(format("你的等级不够,需要%d级才能学习", CastMachine.GetLearnLevel(gsid)))
		return;
	end

	local cate_info = self:GetMakeSkill(gsid);
	if(cate_info) then
		local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
		if(command) then
			command:Call({gsid = gsid, count=default_count, exid = cate_info.exid, npc_shop = true, callback = function(params, msg)
				if(msg and msg.issuccess) then
					LOG.std(nil, "info", "SkillPage", "you have successfully purchased %d skillpoints gsid %d", gsid, default_count or 0);
					--CastMachine.EquipListView("view1");
					CastMachine.ShowPage();
					CastMachine:Refresh();
				end
			end });
		end
	end
end

function LearnedSkill_subpage:OnLearnNewSkill(gsid)
	if( LearnedSkill_subpage.LearnedSpecCounter() == MAX_LEARNED_SPEC)then
		MSG("你不能学习其他专业技能了。")
		return
	end

	if(not gsid)then return end
	gsid = tonumber(gsid)

	local spec_name = "unknown spec"
	local gsitem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsitem)then
		spec_name = gsitem.template.name or "unknown spec";
	end
	local title_name = self.ItemsCates[gsid].title_name or "unknown";
	_guihelper.MessageBox(string.format( "你确认学习专业【%s】,成为一名%s？",spec_name,title_name),function(res) 
		if(res and res == _guihelper.DialogResult.OK) then
			paraworld.auction.StudyMakeSkill({skillgsid = gsid},nil,function(msg) 
				if(msg and msg.issuccess)then
					if(gsid == 21109 or gsid == 21110)then
						CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", { action_type = "gatherer_skill_learned", wndName = "main",});
					end
					MyCompany.Aries.event:DispatchEvent({type = "custom_goal_client"},79014);
					ItemManager.GetItemsInBag( 0, "0", function(msg)
						--switch to spec page
						MyCompany.Aries.NPCs.SnowArea.CastMachine.OpMode = MyCompany.Aries.NPCs.SnowArea.CastMachine.VIEW_SPEC
						--update skill tree
						self:BuildSpecskillList()
						 
						LearnedSkill_subpage.deactiveSpecName = LearnedSkill_subpage.activeSpecName or ""
						LearnedSkill_subpage.activeSpecName = spec_name

						MyCompany.Aries.NPCs.SnowArea.CastMachine.Spec_Skill_name = spec_name;
						MyCompany.Aries.NPCs.SnowArea.CastMachine:AsyncUpdateItems()
					end, "access plus 0 seconds");
				elseif(msg.errorcode == 497)then
					echo(msg);
					MSG(string.format("未知的专业技能【%s】.",spec_name))
				elseif(msg.errorcode == 493)then
					echo(msg);
					MSG(string.format("学习专业技能【%s】参数出错.",spec_name))
				elseif(msg.errorcode == 433)then
					echo(msg);
					MSG(string.format("你当前的技能经验还不能学习该技能.",spec_name))
				elseif(msg.errorcode == 417)then
					echo(msg);
					MSG(string.format("专业技能【%s】已学.",spec_name))

				else
					echo(msg);
					MSG(string.format("学习专业技能【%s】出错.",spec_name))
				end

			end)
		end
	end)
end

function LearnedSkill_subpage.HasSkill(gsid)
	--local bHas = hasGSItem(gsid);
	--return bHas;
	return true;
end

function LearnedSkill_subpage.LearnedSpecCounter()
	--local n = 0;
	--local k,v;
	--for k,v in ipairs(LearnedSkill_subpage.MakeSkill) do
		--local bHas = hasGSItem(v.gsid);
		--if(bHas)then
			--n = n + 1;
		--end
	--end
	--return n;
	return 4;
end

function LearnedSkill_subpage:Clean()
	--self.LearnedSkill = {}
	--self.activeSpecName = nil
	--self.deactiveSpecName = nil
	self.MAKABLE = nil;
end


