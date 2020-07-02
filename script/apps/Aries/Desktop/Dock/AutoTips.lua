--[[
Title: AutoTips
Author(s): spring, refactored by LiXizhi
Date: 2011/08/03
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
AutoTips.CheckShowPage();
AutoTips.ShowPage("EnterComm")
AutoTips.ShowAutoTips(bShow)
local system_looptip = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips.system_looptip"
local system_magicbaginfo = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips.system_magicbaginfo");
------------------------------------------------------------
]]

-- create class

local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

NPL.load("(gl)script/apps/Aries/mcml/pe_goal_pointer.lua");
local goal_manager = commonlib.gettable("MyCompany.Aries.mcml_controls.goal_manager");

-- 魔法口袋是否可取，公共变量初始化
local system_magicbaginfo = commonlib.createtable("MyCompany.Aries.Desktop.AutoTips.system_magicbaginfo", {cantake=true,});

-- 循环提示词，index初始化
--  hasrune 本次登录第一次获取符文标志, visible 主动提示窗打开标志, entercopy 本次登录第一次进入副本标志, 
--	currentcopy 记录当前副本是pvp/pve, i2d3d 2D/3D切换提示, notime_tip PVE战斗时间结束提示, cardshelp_tip 卡片背包帮助是否看过
--  inventoryhelp_tip 装备背包帮助是否看过
local system_looptip = commonlib.createtable("MyCompany.Aries.Desktop.AutoTips.system_looptip", {
	hasrune=false, 
	visible=false,
	entercopy=false,
	currentcopy="",
	i2d3d=false,
	notime_tip=false,
	cardshelp_tip=false,
	inventoryhelp_tip=false,
	tesselate_tip = false,
	loop_tip_index =0,
	firsttip=true,
	npcshop_tip={},
	rightbottom_tip=false,
	LowDurability=false,
});

AutoTips.interval = 10000;

local autotips={};
--local tips={};

-- AutoTips.main
function AutoTips.main()
	local self = AutoTips; 
end

-- only the first call will load from config file
function AutoTips.DoInit()
	if(AutoTips.IsInited) then
		return 
	else
		AutoTips.IsInited = true;
	end

	local self = AutoTips; 
	local nid = Map3DSystem.User.nid;
	local key = string.format("AutoTips:SetActiveTimer_%d",nid);

	local config_file;
	if(System.options.version=="kids") then
		config_file="config/Aries/Tips/autotip.kids.xml";
		self.timer_enabled = MyCompany.Aries.Player.LoadLocalData(key, false);
		if(not self.timer)then
			self.timer = commonlib.Timer:new();
		end
		self.timer.callbackFunc = self.TimerCallback;
	else
		config_file="config/Aries/Tips/autotip.teen.xml";
	end
	
	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading autotips config file: %s\n", config_file);
		return;
	end
		
	local xmlnode="/tips/leveltip";
	
	autotips={
		leveltip={},
		firsttip={},
		dragontip={},
		family={isread= false,},
	}; -- 初始化 autotips 
	
	self.current_tips={};
	-- leveltip	
	local each_tip,i=nil,1;	
	for each_tip in commonlib.XPath.eachNode(xmlRoot, xmlnode) do	
		autotips.leveltip[i]={};	
		autotips.leveltip[i].combatlevel = tonumber(each_tip.attr.combatlevel);
		local _tip = each_tip.attr.tip;
		autotips.leveltip[i].tip = _tip;
		autotips.leveltip[i].world = each_tip.attr.world;
		if (each_tip.attr.pos) then
			autotips.leveltip[i].pos = commonlib.LoadTableFromString(each_tip.attr.pos);
		else
			autotips.leveltip[i].pos = nil;
		end
		autotips.leveltip[i].npcid = each_tip.attr.npcid;
		autotips.leveltip[i].facing = tonumber(each_tip.attr.facing);
		autotips.leveltip[i].tipbtn = each_tip.attr.tipbtn;
		autotips.leveltip[i].btntype = string.lower(each_tip.attr.btntype or "");		
		autotips.leveltip[i].catalog = string.lower(each_tip.attr.shopcatalog or "");
		autotips.leveltip[i].action= each_tip.attr.action;
		--  学习技能提示
		if (each_tip.attr.skill) then
			autotips.leveltip[i].skill = commonlib.LoadTableFromString(each_tip.attr.skill);
		else
			autotips.leveltip[i].skill = nil;
		end
		--  获得物品提示
		if (each_tip.attr.item) then
			autotips.leveltip[i].item = tonumber(each_tip.attr.item);
		else
			autotips.leveltip[i].item = nil;
		end
		autotips.leveltip[i].id= string.format("level%d",i);
		autotips.leveltip[i].isread= false;
		i=i+1;
	end		

	-- firsttip
	xmlnode="/tips/firsttip";
	i=1;
	for each_tip in commonlib.XPath.eachNode(xmlRoot, xmlnode) do
		if (each_tip.attr.type) then
			autotips.firsttip[i]={};
			autotips.firsttip[i].type = string.lower(each_tip.attr.type);
			local _tip = each_tip.attr.tip;
			autotips.firsttip[i].tip = _tip;
			autotips.firsttip[i].tipgsid = each_tip.attr.tipgsid;
			autotips.firsttip[i].npcid = each_tip.attr.npcid;
			autotips.firsttip[i].world = each_tip.attr.world;
			if (each_tip.attr.pos) then
				autotips.firsttip[i].pos = commonlib.LoadTableFromString(each_tip.attr.pos);
			else
				autotips.firsttip[i].pos = nil;
			end
			autotips.firsttip[i].facing = tonumber(each_tip.attr.facing);
			autotips.firsttip[i].tipbtn = each_tip.attr.tipbtn;
			autotips.firsttip[i].btntype = string.lower(each_tip.attr.btntype);
			autotips.firsttip[i].catalog = string.lower(each_tip.attr.shopcatalog or "");
			autotips.firsttip[i].id = string.format("first%d",i);
			autotips.firsttip[i].isread = false;
			autotips.firsttip[i].priority = tonumber(each_tip.attr.priority or 10);
			i=i+1;		
		end
	end

	if(System.options.version=="kids") then
		-- dragontip
		xmlnode="/tips/dragontip";
		i=1;
		for each_tip in commonlib.XPath.eachNode(xmlRoot, xmlnode) do
			autotips.dragontip[i]={};
			autotips.dragontip[i].level = tonumber(each_tip.attr.level);
			local _tip = each_tip.attr.tip;
			autotips.dragontip[i].tip = _tip;
			autotips.dragontip[i].world = each_tip.attr.world;
			if (each_tip.attr.pos) then
				autotips.dragontip[i].pos = commonlib.LoadTableFromString(each_tip.attr.pos);
			else
				autotips.dragontip[i].pos = nil;
			end
			autotips.dragontip[i].facing = tonumber(each_tip.attr.facing);
			autotips.dragontip[i].tipbtn= each_tip.attr.tipbtn;
			autotips.dragontip[i].btntype= string.lower(each_tip.attr.btntype);
			autotips.dragontip[i].id = string.format("dragon%d",i);
			autotips.dragontip[i].isread= false;
			i=i+1;	
		end
	end
	--commonlib.echo("========================autotips:")
	--commonlib.echo(autotips)
end

-- this function is called from mcml page to init the page. 
function AutoTips.OnInit(sTipType,page,tgsid)
	local self = AutoTips; 
	self.pageCtrl = page;
	AutoTips.DoInit();
	AutoTips.GetTip(sTipType,false,tgsid);
end


function AutoTips.ClosePage(chk)
	local self = AutoTips; 
    system_looptip.visible = false;

	if (chk) then
		local _index,_;
		for _index,_ in ipairs(self.current_tips) do
			if (self.current_tips[_index].id) then
				local _id = self.current_tips[_index].id;
				local tip_type,_tid = string.match(_id,"(%a+)(%d+)");
				_tid = tonumber(_tid);
				if (tip_type=="level") then
					if (not autotips.leveltip[_tid].isread) then
						autotips.leveltip[_tid].isread= true;
					end
				elseif (tip_type=="first") then
					if (not autotips.firsttip[_tid].isread) then
						autotips.firsttip[_tid].isread= true;
					end
				elseif (tip_type=="dragon") then
					autotips.dragontip[_tid].isread= true;			
				end
			end

			local btntype = self.current_tips[_index].btntype;
			if (btntype=="openfamliy") then
				if (not autotips.family.isread) then
					autotips.family.isread = true;
				end
			end
			if (System.options.version=="teen") then
				-- always break on first tip
				break;
			end
		end
	end

	if (System.options.version=="kids") then
		if(self.pageCtrl) then
			self.current_tips={};
			self.pageCtrl:CloseWindow();    
		end
	else
		local _index,_;
		local _tips={};
		for _index,_ in ipairs(self.current_tips) do
			if (self.current_tips[_index].id) then
				local _id = self.current_tips[_index].id;
				local tip_type,_tid = string.match(_id,"(%a+)(%d+)");
				_tid = tonumber(_tid);
				if (tip_type=="level") then
					if (not autotips.leveltip[_tid].isread) then
						table.insert(_tips,autotips.leveltip[_tid]);
					end
				elseif (tip_type=="first") then
					if (not autotips.firsttip[_tid].isread) then
						table.insert(_tips,autotips.firsttip[_tid]);
					end
				end
			end
		end			
		self.current_tips=commonlib.deepcopy(_tips);
		if (next(self.current_tips)~=nil) then
			if(self.pageCtrl) then
				self.pageCtrl:Refresh(0.01);
			end
		else
			if(self.pageCtrl) then
				self.current_tips={};
				self.pageCtrl:CloseWindow();    
			end
		end
	end
end


-- temporarily show or hide auto tips. if no auto tips is enabled at the moment, this function does nothing. 
function AutoTips.ShowAutoTips(bShow)
	if (bShow) then 
		if (system_looptip.visible and System.options.version=="kids") then
			System.App.Commands.Call("File.MCMLWindowFrame", {
			name = "Aries.AutoTip", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = true,
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = false,
			isTopLevel = false,
			directPosition = true,
				align = "_rb",
				x = -465,
				y = -200,
				width = 465,
				height = 210,
			})
		elseif  (system_looptip.visible) then
			System.App.Commands.Call("File.MCMLWindowFrame", {
			name = "Aries.AutoTip", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = true,
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = true,
			isTopLevel = false,
			directPosition = true,
				align = "_ct",
				x = -466/2,
				y = -260/2,
				width = 465,
				height = 260,
			})
		end
	else
		local _app = Map3DSystem.App.AppManager.GetApp(MyCompany.Aries.app.app_key);
		if(_app and _app._app) then
			_app = _app._app;
			local _wnd = _app:FindWindow("Aries.AutoTip") 
			if (_wnd) then
				local _wndFrame = _wnd:GetWindowFrame();
				if (_wndFrame) then
					-- close autotips
					_wnd:SendMessage(nil,{type=CommonCtrl.os.MSGTYPE.WM_CLOSE});
					--system_looptip.visible= true;
					--System.App.Commands.Call("File.MCMLWindowFrame", {name = "Aries.AutoTip", app_key = MyCompany.Aries.app.app_key, bShow = false});
				end
			end
		end
	end
end

-- helper function: 获得符文时调用
function AutoTips.CheckShowGetRune()
	local self = AutoTips;
	local nid = Map3DSystem.User.nid;
	local key = string.format("AutoTips:GetRune_%d",nid);
	if (not system_looptip.hasrune) then
		self.GetRuneTips = MyCompany.Aries.Player.LoadLocalData(key, 0);
		if (not self.GetRuneTips) then
			AutoTips.ShowPage("GetRune");
			self.GetRuneTips = 1;
			MyCompany.Aries.Player.SaveLocalData(key, self.GetRuneTips);	
		end
		system_looptip.hasrune=true;
	end
end

-- helper function: 队长进入PvE 副本时调用
function AutoTips.CheckShowEnterCopy()
	local self = AutoTips;
	local nid = Map3DSystem.User.nid;
	local key = string.format("AutoTips:EnterCopy_%d",nid);
	if (not system_looptip.entercopy) then
		self.EnterCopyTips = MyCompany.Aries.Player.LoadLocalData(key, 0);
		if (not self.EnterCopyTips) then
			AutoTips.ShowPage("EnterCopy");
			self.EnterCopyTips = 1
			MyCompany.Aries.Player.SaveLocalData(key, self.EnterCopyTips);			
		end
		system_looptip.entercopy=true;
	end
end

-- helper function: 第一个任务的跳转提示
function AutoTips.FirstQuestTeleDoor()
	local self = AutoTips;
	local nid = Map3DSystem.User.nid;
	local key = string.format("AutoTips:TeleDoor_%d",nid);
	if (not system_looptip.teledoor) then
		self.TeleDoorTips = MyCompany.Aries.Player.LoadLocalData(key, 0);
		if (not self.TeleDoorTips) then
			AutoTips.ShowPage("TeleDoor");
			self.TeleDoorTips = 1
			MyCompany.Aries.Player.SaveLocalData(key, self.TeleDoorTips);			
		end
		system_looptip.teledoor=true;
	end
end

-- helper function: 前2次耐久度为0，提示
function AutoTips.CheckEquipDurability()
	local self = AutoTips;
	local nid = Map3DSystem.User.nid;
	local key = string.format("AutoTips:EquipDurability_%d",nid);

	if (not system_looptip.LowDurability) then
		self.EquipDurabilityTips = MyCompany.Aries.Player.LoadLocalData(key, 0);
		if (self.EquipDurabilityTips<=2) then
			AutoTips.ShowPage("LowDurability",nil,true);
			self.EquipDurabilityTips = self.EquipDurabilityTips + 1;		
			MyCompany.Aries.Player.SaveLocalData(key, self.EquipDurabilityTips);
		else
			system_looptip.LowDurability=true;
		end
	end
end

-- @param bIgnoreLoopTips: true to ignore loop tips
function AutoTips.GetTip(myFirstType, bIgnoreLoopTips, tipgsid)
	local self = AutoTips; 
	local bean = MyCompany.Aries.Pet.GetBean();
	local myCombatLevel, myDragonLevel;

	if (bIgnoreLoopTips ==nil) then
		 bIgnoreLoopTips=true
	end
	if(bean) then
		myCombatLevel = bean.combatlel or 0;
		myDragonLevel = bean.level or 0;
	end
	--commonlib.echo("==============tiptype");
	--commonlib.echo(myFirstType);
	--commonlib.echo(tipgsid);
	--myFirstType="2d3d";
	--myCombatLevel=10;
	--myDragonLevel=12;
	local _tips={};
	
	local tipid;
	local school = MyCompany.Aries.Combat.GetSchoolGSID();	
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;

	if (myFirstType) then
		local myFirstType=string.lower(myFirstType);
		if (myFirstType=="lootequip" and tipgsid) then
			local tmptips={};
			tmptips.combatlevel = myCombatLevel;
			tmptips.tip = string.format("恭喜你获得了更高级的装备！点击<pe:item gsid=%d showdefaulttooltip='true' style='width:25px;height:25px;' />就可以穿上了！也可以打开背包查看！",tipgsid);
			tmptips.tipbtn= "打开背包";
			tmptips.btntype= "openequipbag";
			table.insert(_tips,tmptips);
		elseif (myFirstType=="petequip" and tipgsid) then
			local tmptips={};
			tmptips.combatlevel = myCombatLevel;
			tmptips.tip = string.format("恭喜你获得了新的战宠！快打开宠物背包看看吧！",tipgsid);
			tmptips.tipbtn= "查看宠物";
			tmptips.btntype= "openfollowpet";
			table.insert(_tips,tmptips);
		else
			local tmptips=autotips.firsttip;
			if (tmptips) then
				for tipid in pairs(tmptips) do
					if (tmptips[tipid].type==myFirstType) then
						table.insert(_tips,tmptips[tipid]);
					end
				end
			end
		end
	else
		local tmptips=autotips.leveltip;
		if (tmptips) then
			for tipid in pairs(tmptips) do
				if (tmptips[tipid].combatlevel==myCombatLevel) then
					if (tmptips[tipid].skill) then -- 如果提醒是学习魔法
						local skillgsid=tmptips[tipid].skill[school];
						local sHas = hasGSItem(skillgsid);
						if (not sHas) then -- 判断是否已学了本系该魔法，没学则提醒
							table.insert(_tips,tmptips[tipid]);
						end
					else -- 提醒类型不是学习魔法，则提醒
						if (tmptips[tipid].item) then  -- 如果提醒类型是获得物品
							local itemgsid = tonumber(tmptips[tipid].item);
							if (itemgsid == 50320) then -- 是否是黄金礼包
								local level_map = {
									[10] = 3,
									[9] = 5,
									[8] = 10,
									[7] = 15,
									[6] = 20,
									[5] = 25,
									[4] = 30,
								};
								if(System.options.version == "teen") then
									level_map = {
										[10] = 2,
										[9] = 5,
										[8] = 10,
										[7] = 15,
										[6] = 20,
										[5] = 25,
										[4] = 30,
										[3] = 35,
										[2] = 40,
									};
								end
								local bHas_17150, _, __, copies_17150 = hasGSItem(50320);
								if(bHas_17150 and copies_17150) then
									local closest_level = level_map[copies_17150];
									if(closest_level) then
										if(closest_level <= myCombatLevel) then
											canopen_17150 = true;
										else
											canopen_17150 = false;
										end
									end
								end
								if (canopen_17150) then
									-- table.insert(_tips,tmptips[tipid]);
									NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockTip.lua");
									local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");
									-- 17150_GoldenGiftPack
									local item_name = "";
									local gsItem = ItemManager.GetGlobalStoreItemInMemory(17150);
									if(gsItem) then
										item_name = gsItem.template.name;
									end
									local node = { name = "DockTip.collectable", gsid = 17150, title=string.format("你可以打开%s了！", item_name), btn="立即打开", onclick="OnClick_Item",  };
									DockTip.GetInstance():PushNode(node);
								end
							else -- 非黄金礼包
								local bHas = hasGSItem(itemgsid); 
								if (not bHas) then
									table.insert(_tips,tmptips[tipid]);
								end
							end
						else -- 其他提醒类型
							table.insert(_tips,tmptips[tipid]);					
						end -- 如果提醒类型是获得物品
					end				
				end -- if (tmptips[tipid].combatlevel==myCombatLevel)
			end -- for tipid in pairs(tmptips)
		end
		if(System.options.version=="kids") then
			local tmptips=autotips.dragontip;
			if (tmptips) then
				for tipid in pairs(tmptips) do
					if (tmptips[tipid].level==myDragonLevel) then
						table.insert(_tips,tmptips[tipid]);
					end
				end
			end
		end

		local my_nid = System.User.nid;
		local userinfo = System.App.profiles.ProfileManager.GetUserInfoInMemory(my_nid);
		if(System.options.version=="kids") then	
			if(not userinfo or not userinfo.family or userinfo.family == "") then
			else
				local Friends = commonlib.gettable("MyCompany.Aries.Friends");
				local MyFamilyInfo = Friends.MyFamilyInfo;
				if(MyFamilyInfo) then
					local contribute = 0;
					local i;
					for i = 1, #(MyFamilyInfo.members) do
						local member = MyFamilyInfo.members[i];
						if(member.nid == my_nid) then
							contribute = member.contribute;
							break;
						end
					end
					local familyid = MyFamilyInfo.id;		
					local IsSignFamily;
					if(System.options.version=="kids") then				
						NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupManage.lua");
						local HaqiGroupManage = commonlib.gettable("MyCompany.Aries.Quest.NPCs.HaqiGroupManage");
						IsSignFamily = HaqiGroupManage.IsSignInToday(familyid);
						local tmptips={};
						if (contribute<15 and (not IsSignFamily)) then
							tmptips.combatlevel = myCombatLevel;
							tmptips.tip = string.format("你的家族贡献度还不到15 啊，你的赛场成绩还不能记入家族主力排名，无法参与月底家族奖励分享！快去给家族做贡献，提升你们家族的活跃度！");
							tmptips.tipbtn= "家族贡献";
							tmptips.btntype= "openfamliy";
							tmptips.isread= autotips.family.isread;				
							table.insert(_tips,tmptips);
						end
					else
						--NPL.load("(gl)script/apps/Aries/Family/FamilyManager.lua");
						--local FamilyManager = commonlib.gettable("Map3DSystem.App.Family.FamilyManager");
						--local manager = FamilyManager.CreateOrGetManager();
						--if(manager)then
							--IsSignFamily = manager:IsSignInToday(familyid);
						--end
					end		
					--commonlib.echo("==========tmptips");
					--commonlib.echo(tmptips);

				end -- if(MyFamilyInfo) 
			end --if(not userinfo or not userinfo.family or userinfo.family
		end 
	end

	local _,_tip;
	for _,_tip in ipairs(self.current_tips) do
		local _isread = _tip.isread;
		if (not _isread) then
			table.insert(_tips,_tip);
		end
	end
	self.current_tips = commonlib.deepcopy(_tips);
	if (next(self.current_tips)~=nil) then
		table.sort(self.current_tips, function(a, b)
			return ((a.priority or 0) > (b.priority or 0));
		end);
	end
end

function AutoTips.DS_Func_AutoTip(index)
	local self = AutoTips;
	if(index == nil) then
		return #(self.current_tips);
	else
		return self.current_tips[index];
	end	
end

function AutoTips.GetTipsNum()
	local self = AutoTips;
	return #(self.current_tips);
end

function AutoTips.ClickBtn(index)
	local self = AutoTips;
	local btntype;
	if (self.current_tips[index]) then
		btntype = self.current_tips[index].btntype;
		if (self.current_tips[index].id) then
			local _id = self.current_tips[index].id;
			local tip_type,_tid = string.match(_id,"(%a+)(%d+)");
			_tid = tonumber(_tid);
			if (tip_type=="level") then
				autotips.leveltip[_tid].isread= true;
			elseif (tip_type=="first") then
				autotips.firsttip[_tid].isread= true;
			elseif (tip_type=="dragon") then
				autotips.dragontip[_tid].isread= true;			
			end
		end
	else
		LOG.std(nil, "warn", "Autotips", "no current_tips[index]!");
	end

	if (btntype) then		
		if (btntype=="openfamliy") then
			autotips.family.isread = true;
		end
		if(System.options.version=="kids") then
			AutoTips.KidsClickBtn(index,btntype)
		else
			AutoTips.TeenClickBtn(index,btntype)
		end
	end
	AutoTips.ClosePage(true)
end

function AutoTips.KidsClickBtn(index,btntype)
	local self = AutoTips;	
	if (btntype=="iknow") then
		return
	elseif (btntype=="jumpto") then
		local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
		local canpass = WorldManager:CanTeleport_CurrentWorld();
		if(not canpass)then
			_guihelper.MessageBox("<div style='margin-left:15px;margin-top:15px;text-align:center'>你还在副本世界中，不能跳转！先离开副本世界吧。</div>");
			return
		end

		local _npcid=self.current_tips[index].npcid;
		if (_npcid) then
			_npcid=tonumber(_npcid);
			local worldname,position,camera = WorldManager:GetWorldPositionByNPC(_npcid);
			WorldManager:GotoWorldPosition(worldname,position,camera,nil,nil,true);			
			return
		else

			local world=self.current_tips[index].world;
			NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
			local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
			canpass = QuestHelp.InSameWorldByKey(world);

			if(not canpass)then
				_guihelper.Custom_MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>该目标不在当前岛屿，可以先去问问法斯特船长，是否需要传送到船长身边？</div>",function(result)
					if(result == _guihelper.DialogResult.Yes)then
						NPL.load("(gl)script/apps/Aries/Quest/NPCList.lua");
						local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");
						local cur_path = ParaWorld.GetWorldDirectory();
						local cur_worldnm = string.match(cur_path,"/([%w%_]+)/$");
						local thisCaptainID = WorldManager:GetWorldCaptainID(cur_worldnm);
						-- local thisCaptainID = captainID[string.lower(cur_worldnm)];
						local npc, __, npc_data = NPCList.GetNPCByIDAllWorlds(thisCaptainID);

						--commonlib.echo(npc);
						if(npc)then
							local facing = npc.facing or 0;
							facing = facing + 1.57
							local radius = 5;
							local end_pos = npc.position;
							if(end_pos)then
								local  x,y,z = end_pos[1],end_pos[2],end_pos[3];
								x = x + radius * math.sin(facing);
								z = z + radius * math.cos(facing);
								if(x and y and z)then

									local Position = {x,y,z, facing+1.57};
									local CameraPosition = { 15, 0.27, facing + 1.57 - 1};
									local msg = { aries_type = "OnMapTeleport", 
												position = Position, 
												camera = CameraPosition, 
												bCheckBagWeight = true,
												wndName = "map", 
												end_callback = function()
													-- automatically open dialog when talking to npc. added by Xizhi to simplify user actions.
													local npc_id = tonumber(npc.npc_id);
													if(npc_id) then
														local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");
														TargetArea.TalkToNPC(npc_id, nil, false);
													end	
												end
											};
										CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
								end
							end
						end
					end
				end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/Coming_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
				return
			end
			
			local pos = self.current_tips[index].pos;
			local facing = self.current_tips[index].facing;
			local school = MyCompany.Aries.Combat.GetSchoolGSID();		
			if (tonumber(pos[1])==20191.23 and tonumber(pos[2])==3.85 and tonumber(pos[3])==20044.01) then
				if (school==986) then --烈火系
					pos={ 20171.40, 3.90, 20069.92};
					facing = facing-0.7;
				elseif (school==987) then --寒冰系
					pos={ 20183.28, 3.84, 20038.03};
					facing = facing-1.75;
				elseif (school==988) then --风暴系
					pos={ 20209.76, 3.92, 20035.80};
					facing= facing +1.57;
				elseif (school==990) then --生命系
					pos={ 20190.68, 3.95, 20103.42};
				elseif (school==991) then --死亡系
					pos={ 20216.69, 3.84, 20067.86};
				end
			end

			local CameraPosition = { 15, 0.27, facing+0.57};
			local msg = { aries_type = "OnMapTeleport", 
						position = pos, 
						camera = CameraPosition, 
						bCheckBagWeight = true,
						wndName = "map", 
					};
			CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
		end
	elseif (btntype=="openequipbag") then
		MyCompany.Aries.Desktop.Dock.ShowCharPage(3);
	elseif (btntype=="openitembag") then
		MyCompany.Aries.Desktop.Dock.ShowCharPage(4);
	elseif (btntype=="openridepet") then
		NPL.load("(gl)script/apps/Aries/Inventory/MainWnd.lua");
		MyCompany.Aries.Inventory.ShowMainWnd(true, 2);
		NPL.load("(gl)script/apps/Aries/Inventory/TabMountExPage.lua");
		MyCompany.Aries.Inventory.TabMountExPage.ShowItemView("1","3");
	elseif (btntype=="openfollowpet") then
		MyCompany.Aries.Desktop.Dock.DoShowPetManager();
	elseif (btntype=="openfamliy") then
		System.App.Commands.Call("Profile.Aries.MyFamilyWnd");
	elseif (btntype=="backhome") then
		System.App.Commands.Call("Profile.Aries.MyHomeLand");
	elseif (btntype=="gethulu") then
		MyCompany.Aries.Desktop.MiJiuHuLu.ShowPage(2);
	elseif (btntype=="findpartner") then
		NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
		local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
		LobbyClientServicePage.selected_game_type = "PvE";
		LobbyClientServicePage.__ShowPage();
	elseif (btntype=="openshop") then
		NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.lua");
		MyCompany.Aries.HaqiShop.ShowMainWnd();
	elseif (btntype=="eatdate") then
		NPL.load("(gl)script/apps/Aries/Desktop/HPMyPlayerArea.lua");
		local HPMyPlayerArea = commonlib.gettable("MyCompany.Aries.Desktop.HPMyPlayerArea");
		HPMyPlayerArea.ShowHpPotionPage();
	elseif (btntype=="openstar") then
		NPL.load("(gl)script/apps/Aries/Help/MagicStarHelp/MagicStarHelp.lua");
		local MagicStarHelp = commonlib.gettable("MyCompany.Aries.Help.MagicStarHelp");
		MagicStarHelp.ShowPage();
	elseif (btntype=="opencardbag") then
		NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCharMainFramePage.lua");
		local CombatCharacterFrame = commonlib.gettable("MyCompany.Aries.Desktop.CombatCharacterFrame");
		if (CombatCharacterFrame) then
			CombatCharacterFrame.ShowMainWnd(2);
			--显示学会技能的卡片背包
			NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardDeckSubPage.lua");
			MyCompany.Aries.Inventory.Cards.MyCardsManager.SetCombatCardPage();
			self.ClosePage();
		end
	elseif (btntype=="openrunebag") then

		NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCharMainFramePage.lua");
		local CombatCharacterFrame = commonlib.gettable("MyCompany.Aries.Desktop.CombatCharacterFrame");
		if (CombatCharacterFrame) then
			CombatCharacterFrame.ShowMainWnd(2);
			--显示获得符文的卡片背包
			NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardDeckSubPage.lua");
			local state = MyCompany.Aries.Inventory.Cards.MyCardsManager.GetPropByTemplateGsid(msg.gsid);
			MyCompany.Aries.Inventory.Cards.MyCardsManager.SetRunePage();
			self.ClosePage();
		end
	end
end

function AutoTips.TeenClickBtn(index,btntype)
	local self = AutoTips;
	if (btntype=="iknow") then
		return
	elseif (btntype=="jumpto") then
		local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
		local canpass = WorldManager:CanTeleport_CurrentWorld();
		if(not canpass)then
			_guihelper.MessageBox("<div style='margin-left:15px;margin-top:15px;text-align:center'>你还在副本世界中，不能跳转！先离开副本世界吧。</div>");
			return
		end
		--commonlib.echo("===========tips")
		--commonlib.echo(self.current_tips[index])

		local _npcid=self.current_tips[index].npcid;
		if (_npcid) then
			_npcid=tonumber(_npcid);
			local worldname,position,camera = WorldManager:GetWorldPositionByNPC(_npcid);
			WorldManager:GotoWorldPosition(worldname,position,camera,nil,nil,true);			
			return
		else
			local world=self.current_tips[index].world;

			NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
			local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
			canpass = QuestHelp.InSameWorldByKey(world);

			if(not canpass)then
				_guihelper.Custom_MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>该目标不在当前岛屿，可以先去问问法斯特船长，是否需要传送到船长身边？</div>",function(result)
						if(result == _guihelper.DialogResult.Yes)then
							NPL.load("(gl)script/apps/Aries/Quest/NPCList.lua");
							local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");
							local cur_path = ParaWorld.GetWorldDirectory();
							local cur_worldnm = string.match(cur_path,"/([%w%_]+)/$");
							local thisCaptainID = WorldManager:GetWorldCaptainID(cur_worldnm);
							-- local thisCaptainID = captainID[string.lower(cur_worldnm)];
							local npc, __, npc_data = NPCList.GetNPCByIDAllWorlds(thisCaptainID);

							--commonlib.echo(npc);
							if(npc)then
								local facing = npc.facing or 0;
								facing = facing + 1.57
								local radius = 5;
								local end_pos = npc.position;
								if(end_pos)then
									local  x,y,z = end_pos[1],end_pos[2],end_pos[3];
									x = x + radius * math.sin(facing);
									z = z + radius * math.cos(facing);
									if(x and y and z)then

										local Position = {x,y,z, facing+1.57};
										local CameraPosition = { 15, 0.27, facing + 1.57 - 1};
										local msg = { aries_type = "OnMapTeleport", 
													position = Position, 
													camera = CameraPosition, 
													bCheckBagWeight = true,
													wndName = "map", 
													end_callback = function()
														-- automatically open dialog when talking to npc. added by Xizhi to simplify user actions.
														local npc_id = tonumber(npc.npc_id);
														if(npc_id) then
															local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");
															TargetArea.TalkToNPC(npc_id, nil, false);
														end	
													end
												};
											CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
									end
								end
							end
						end
					end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/Coming_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
				return
			end
			
			local pos = self.current_tips[index].pos;
			local facing = self.current_tips[index].facing;
			local school = MyCompany.Aries.Combat.GetSchoolGSID();	
			--commonlib.echo(tips[index]);
			if (tonumber(pos[1])==20054.77 and tonumber(pos[2])==70.8 and tonumber(pos[3])==20182.7) then
				if (school==986) then --烈火系
					pos={ 20047.63, 73.45, 20280.23};
					facing = facing-0.1;
				elseif (school==987) then --寒冰系
					pos={ 20075.52, 73.46, 20252.24};
					facing = facing-1.75;
				elseif (school==988) then --风暴系
					pos={ 20008.72, 73.46, 20207.73};
					facing= facing +1.57;
				elseif (school==990) then --生命系
					pos={ 20017.62, 73.45, 20284.05};
				elseif (school==991) then --死亡系
					pos={ 19995.97, 73.42, 20258.38};
				end
			end

			local CameraPosition = { 15, 0.27, facing+0.57};
			local msg = { aries_type = "OnMapTeleport", 
						position = pos, 
						camera = CameraPosition, 
						bCheckBagWeight = true,
						wndName = "map", 
					};
			CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
		end
	elseif (btntype=="openequipbag") then
		local CharacterBagPage = commonlib.gettable("MyCompany.Aries.Inventory.CharacterBagPage");
		CharacterBagPage.ShowPage();
	elseif (btntype=="openitembag") then	
		local CharacterBagPage = commonlib.gettable("MyCompany.Aries.Inventory.CharacterBagPage");
		CharacterBagPage.ShowPage(nil,"UsefulItem",2);
	elseif (btntype=="openfollowpet") then
		NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetPane.lua");
		local CombatPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetPane");
		CombatPetPane.ShowPage();
	elseif (btntype=="openridepet") then
		NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CharacterBagPage.lua");
		local CharacterBagPage = commonlib.gettable("MyCompany.Aries.Inventory.CharacterBagPage");
		CharacterBagPage.ShowPage(nil,"Pet")
	elseif (btntype=="openvip") then
		NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/MagicStarPage.lua");
		local MagicStarPage = commonlib.gettable("MyCompany.Aries.Inventory.MagicStarPage");
		MagicStarPage.ShowPage();
	elseif (btntype=="openfamliy") then
		local FamilyMembersPage = commonlib.gettable("Map3DSystem.App.Family.FamilyMembersPage");
		FamilyMembersPage.ShowPage();
--	elseif (btntype=="backhome") then
--		System.App.Commands.Call("Profile.Aries.MyHomeLand");
--	elseif (btntype=="gethulu") then
--		MyCompany.Aries.Desktop.MiJiuHuLu.ShowPage();
	elseif (btntype=="findpartner") then
--		MyCompany.Aries.Desktop.EXPBuffArea.ShowLobbyPage();
		local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
		LobbyClientServicePage.ShowPage();
	elseif (btntype=="openshop") then
		System.App.Commands.Call("Profile.Aries.ShowShopPage");
	elseif (btntype=="opencardbag") then
		local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");
		MyCardsManager.ShowPage();
	elseif (btntype=="opencharinfo") then
		local ProfilePane = commonlib.gettable("MyCompany.Aries.ProfilePane");
		AutoTips.OpenCharInfo = true;
		ProfilePane.ShowPage();
	elseif (btntype=="equipupgrade") then
		NPL.load("script/apps/Aries/NPCs/ShoppingZone/Avatar_equip_upgrade.lua");
		MyCompany.Aries.NPCs.ShoppingZone.Avatar_equip_upgrade.ShowPage();
	elseif (btntype=="gemtesselate") then
		NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemAttachPage.lua");
		local GemAttachPage = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemAttachPage");
		GemAttachPage.ShowPage();
	elseif (btntype=="bearshop") then
		NPL.load("(gl)script/apps/Aries/HaqiShop/NPCShopPage.lua");
		local NPCShopPage = commonlib.gettable("MyCompany.Aries.NPCShopPage");
		local _cataid=self.current_tips[index].catalog;		
		NPCShopPage.ShowPage(-1,nil,_cataid);
	elseif (btntype=="open_encyclopedia") then
		NPL.load("(gl)script/apps/Aries/NPCs/MagicSchool/CombatSkillLearn.lua");
		local tipgsid = self.current_tips[index].tipgsid;
		if (tipgsid) then
			MyCompany.Aries.AuctionHouse.ShowPage("view",nil,tipgsid);
		else
			MyCompany.Aries.AuctionHouse.ShowPage();
		end
	elseif (btntype=="openauctionhouse") then
		NPL.load("script/apps/Aries/NPCs/ShoppingZone/ItemsConsignment.lua");
		MyCompany.Aries.NPCs.ShoppingZone.ItemsConsignment.ShowPage("buy");
	elseif (btntype=="buyhighclassmount") then
		NPL.load("script/apps/Aries/HaqiShop/NPCShopPage.lua");
		MyCompany.Aries.NPCShopPage.ShowPage(31803,"menu1");
	elseif (btntype=="cooking") then
		NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/ItemBuildPage.lua");
		local ItemBuildPage = commonlib.gettable("MyCompany.Aries.Desktop.ItemBuildPage");
		ItemBuildPage.ShowPage();
	elseif (btntype=="magiccard") then
		NPL.load("(gl)script/apps/Aries/Inventory/Cards/MagicCardShopPage.lua");
		local MagicCardShopPage = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MagicCardShopPage");
		MagicCardShopPage.ShowPage();
	elseif (btntype=="singlemode") then
		NPL.load("(gl)script/apps/Aries/CombatRoom/CreateRoomPage.lua");
		local CreateRoomPage = commonlib.gettable("MyCompany.Aries.CombatRoom.CreateRoomPage");
		CreateRoomPage.ShowPage();
	elseif (btntype=="pointer_encyclopedia") then
		goal_manager.SetCurrentGoal("encyclopedia");
	elseif (btntype=="pointer_herocopy") then
		goal_manager.SetCurrentGoal("herocopy");
	elseif (btntype=="pointer_teambtn") then
		goal_manager.SetCurrentGoal("teambtn");
	elseif (btntype=="pointer_lifeskill_pill") then
		goal_manager.SetCurrentGoal("skillbtn_pill");
	end
end

function AutoTips.IsShowTip()
	local self = AutoTips; 
	local bean = System.App.profiles.ProfileManager.GetUserInfoInMemory();
	local myCombatLevel, myDragonLevel;
	if(bean) then
		myCombatLevel = bean.combatlel or 0;
		myDragonLevel = bean.level or 0;
	end
	
	local tmptips=self.current_tips;
	local _,_tip;
	for _,_tip in ipairs(tmptips) do
		--commonlib.echo(_tip);
		local combatlevel = _tip.combatlevel;
		local _tid = _tip.id;
		local isFirst=false;
		if (_tid) then
			local _test=string.match(_tid,"first");
			--commonlib.echo(_tid);
			--commonlib.echo(_test);
			if (_test) then
				isFirst=true
			end
		end
		local isread = _tip.isread;
		if ((combatlevel or isFirst) and (not isread)) then
			if( combatlevel==myCombatLevel or isFirst)  then
				return true;
			end
		end
	end

	if(System.options.version=="kids") then
		local tmptips=self.current_tips;
		for _,_tip in pairs(tmptips) do
			local dragonlevel = _tip.level;
			local isread = _tip.isread;
			if (dragonlevel and (not isread)) then
				if (dragonlevel==myDragonLevel) then
					return true;
				end
			end
		end
	end
	return false;
end

-- only show if there is tips to show at the current level. 
-- call this function whenever the user levels up. 
-- @param bIgnoreLoopTips: default to true. if true, it will ignore loop tips. 
-- @param nDelaySeconds: TODO: if nil, we will show immediately, otherwise we will wait nDelaySeconds and then show. 
function AutoTips.CheckShowPage(myFirstType, bIgnoreLoopTips, nDelaySeconds)
	-- init current tips, and ignore loop tips. 
	local self = AutoTips; 
	if(bIgnoreLoopTips == nil) then
		bIgnoreLoopTips = true;
	end
	local _tips_bak= commonlib.deepcopy(self.current_tips);
	commonlib.echo("==========checkshow tips");
	--commonlib.echo(_tips_bak)

	AutoTips.GetTip(myFirstType, bIgnoreLoopTips); 
	--commonlib.echo(self.current_tips)

	if (next(self.current_tips)==nil) then
		self.current_tips = commonlib.deepcopy(_tips_bak);
	end

	if (AutoTips.IsShowTip()) then
		local _app = Map3DSystem.App.AppManager.GetApp(MyCompany.Aries.app.app_key);
		if(_app and _app._app) then
			_app = _app._app;
			local _wnd = _app:FindWindow("Aries.AutoTip") 
			if (_wnd) then
				local _wndFrame = _wnd:GetWindowFrame();
				if (_wndFrame) then
					-- close autotips
					_wnd:SendMessage(nil,{type=CommonCtrl.os.MSGTYPE.WM_CLOSE});
				end
			end
		end

		-- nDelaySeconds does not work: cancel it.
		if(nDelaySeconds) then
			UIAnimManager.PlayCustomAnimation(nDelaySeconds*1000, function(elapsedTime)
				if(elapsedTime == nDelaySeconds*1000) then
					AutoTips.ShowPage(myFirstType);
				end
			end);
		else
			AutoTips.ShowPage(myFirstType);
		end
	end	

end

function AutoTips.SetActiveTimer()
	local self = AutoTips; 
	if(self.timer_enabled)then
		self.timer_enabled = false;
	else
		self.timer_enabled = true
		self.timer:Change(self.interval, self.interval);
	end
	local nid = Map3DSystem.User.nid;
	local key = string.format("AutoTips:SetActiveTimer_%d",nid);
	MyCompany.Aries.Player.SaveLocalData(key, self.timer_enabled);
end

function AutoTips.TimerIsEnabled()
	local self = AutoTips; 
	return self.timer_enabled;
end

function AutoTips.ShowPage(tiptype,tgsid,IsForceDisplay)
	local self = AutoTips; 
	local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
	local isInCombat = MsgHandler.IsInCombat();

	NPL.load("(gl)script/apps/Aries/Quest/QuestDialogPage.lua");
	local QuestDialogPage = commonlib.gettable("MyCompany.Aries.Quest.QuestDialogPage");
	local isDialogNPC = QuestDialogPage.IsDialogShown();

	--commonlib.echo("========AutoTips tiptype")
	--commonlib.echo(tiptype)
	--commonlib.echo(isInCombat)
	--commonlib.echo(tgsid)
	--commonlib.echo("========AutoTips isDialogNPC isInCombat")
	--commonlib.echo(isInCombat)
	--commonlib.echo(isDialogNPC)
	--commonlib.echo(IsForceDisplay)

	if(System.options.version=="kids") then
		-- 战斗中，不弹出提示
		if (isInCombat) then 
			return
		end

		-- NPC 对话中，不弹出提示
		if (isDialogNPC) then 
			return
		end
	else
		if (IsForceDisplay) then
		else
			-- 战斗中，不弹出提示
			if (isInCombat) then 
				return
			end

			-- NPC 对话中，不弹出提示
			if (isDialogNPC) then 
				return
			end
		end
	end

	-- 如果没有提示内容，则不弹出提示
	AutoTips.DoInit();
	AutoTips.GetTip(tiptype,false,tgsid);
	--commonlib.echo("========AutoTips tips")
	--commonlib.echo(tiptype)
	--commonlib.echo(self.current_tips)

	if (next(self.current_tips)==nil) then
		return
	end

	local self = AutoTips; 
	
	if(System.options.version=="kids") then
		self.timer:Change();
		AutoTips.KidsShowPage(tiptype,tgsid)
		self.timer:Change(self.interval,self.interval);
	else
		AutoTips.TeenShowPage(tiptype,tgsid)
	end
	
	system_looptip.visible = true;
end

--timer callback function
function AutoTips.TimerCallback(timer)
	local self = AutoTips;
	if(not system_looptip.visible or not self.timer_enabled) then return end
	AutoTips.ClosePage(true)
end

function AutoTips.KidsShowPage(tiptype,tgsid)
	local bean = MyCompany.Aries.Pet.GetBean();
	local myCombatLevel, myDragonLevel;
	if(bean) then
		myCombatLevel = bean.combatlel or 0;
		myDragonLevel = bean.level or 0;
	end

	local tipurl;
	if (tiptype) then
		if (tgsid) then
			tipurl="script/apps/Aries/Desktop/Dock/AutoTip.kids.html?tiptype="..tiptype.."&gsid="..tgsid;
		else
			tipurl="script/apps/Aries/Desktop/Dock/AutoTip.kids.html?tiptype="..tiptype;
		end
	else
		if (myCombatLevel==0)  then
			tipurl="script/apps/Aries/Desktop/Dock/AutoTip.kids.html?tiptype=entercomm";
		elseif ((myCombatLevel== 5) and (not system_looptip.i2d3d))then
			system_looptip.i2d3d=true;
			tipurl="script/apps/Aries/Desktop/Dock/AutoTip.kids.html?tiptype=2d3d";
		else
			tipurl="script/apps/Aries/Desktop/Dock/AutoTip.kids.html";
		end
	end
	
	System.App.Commands.Call("File.MCMLWindowFrame", {
	url = tipurl, 
	name = "Aries.AutoTip", 
	app_key=MyCompany.Aries.app.app_key, 
	isShowTitleBar = false,
	DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
	style = CommonCtrl.WindowFrame.ContainerStyle,
	zorder = 1,
	allowDrag = false,
	isTopLevel = false,
	directPosition = true,
		align = "_rb",
		x = -465,
		y = -200,
		width = 465,
		height = 210,
	})
end

function AutoTips.TeenShowPage(tiptype,tgsid)
	local bean = MyCompany.Aries.Pet.GetBean();
	local myCombatLevel, myDragonLevel;
	if(bean) then
		myCombatLevel = bean.combatlel or 0;
		myDragonLevel = bean.level or 0;
	end

	local tipurl;
	if (tiptype) then
		if (tgsid) then
			tipurl="script/apps/Aries/Desktop/Dock/AutoTip.teen.html?tiptype="..tiptype.."&gsid="..tgsid;
		else
			tipurl="script/apps/Aries/Desktop/Dock/AutoTip.teen.html?tiptype="..tiptype;
		end
	else
		if (myCombatLevel==0)  then
			tipurl="script/apps/Aries/Desktop/Dock/AutoTip.teen.html";
		--elseif ((myCombatLevel== 5) and (not system_looptip.i2d3d))then
			--system_looptip.i2d3d=true;
			--tipurl="script/apps/Aries/Desktop/Dock/AutoTip.teen.html?tiptype=2d3d";
		else
			tipurl="script/apps/Aries/Desktop/Dock/AutoTip.teen.html";
		end
	end

	--commonlib.echo("==============show autotips:"..tipurl)
	System.App.Commands.Call("File.MCMLWindowFrame", {
	url = tipurl, 
	name = "Aries.AutoTip", 
	app_key=MyCompany.Aries.app.app_key, 
	isShowTitleBar = false,
	DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
	style = CommonCtrl.WindowFrame.ContainerStyle,
	zorder = 1,
	allowDrag = true,
	isTopLevel = false,
	directPosition = true,
		align = "_ct",
		x = -466/2,
		y = -260/2,
		width = 465,
		height = 260,
	})
	--System.App.Commands.Call("File.MCMLWindowFrame", {
	--url = tipurl, 
	--name = "Aries.AutoTip", 
	--app_key=MyCompany.Aries.app.app_key, 
	--isShowTitleBar = false,
	--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
	--style = CommonCtrl.WindowFrame.ContainerStyle,
	--zorder = 1,
	--allowDrag = false,
	--isTopLevel = false,
	--directPosition = true,
		--align = "_rb",
		--x = -465,
		--y = -200,
		--width = 465,
		--height = 210,
	--})
end
