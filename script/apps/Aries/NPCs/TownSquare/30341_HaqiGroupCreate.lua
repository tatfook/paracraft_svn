--[[
Title: HaqiGroupCreate
Author(s): Leio
Date: 2010/01/09

use the lib:
30341_HaqiGroupCreate_0_0.html 创建家族-尚未领取种子 状态1
30341_HaqiGroupCreate_0_1.html 创建家族-尚未领取种子 状态2
30341_HaqiGroupCreate_1.html 创建家族-已经领取种子 没有果实
30341_HaqiGroupCreate_2.html 创建家族-满足创建家族
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupCreate.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupManage.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/paraworld.family.lua");
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupClient.lua");
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30342_HaqiGroupJoin.lua");
NPL.load("(gl)script/apps/Aries/Chat/BadWordFilter.lua");

-- create class
local libName = "HaqiGroupCreate";
local HaqiGroupCreate = {
	selected_instance = nil,
	state = nil,
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.HaqiGroupCreate", HaqiGroupCreate);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
function HaqiGroupCreate.OnInit()
	self.page = document:GetPageCtrl();
end
-- HaqiGroupCreate.main
function HaqiGroupCreate.main()
end
-- HaqiGroupCreate.PreDialog
function HaqiGroupCreate.PreDialog()
	local self = HaqiGroupCreate;
	
	Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nil, "", function (msg)
		if(msg and msg.users and msg.users[1]) then
			--user info
			local result = msg.users[1];
			if(result.family)then
				--未加入任何家族
				if(result.family == "")then
					self.state = 2;
				else
					--已经加入家族
					local args = {
						idorname = result.family,
					}
					paraworld.Family.Get(args,"",function(msg)
						if(msg)then
							local admin = msg.admin;
							if(admin == Map3DSystem.User.nid)then
								--族长
								self.state = 0;
							else
								--已经加入家族 但是不是族长
								self.state = 1;
							end
						end
					end);
				end
			end
		end
	end)
end
function HaqiGroupCreate.ShowCreateDialog()
	local self = HaqiGroupCreate;
	local url;
	local width,height;
	commonlib.echo("=====test");
	commonlib.echo({self.IsState_2(),self.IsState_0(),self.IsState_1()});
	if(self.IsState_2())then
		url = "script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupCreate_2.html";
	else
		if(self.IsState_0())then
			url = "script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupCreate_0_0.html";
		elseif(self.IsState_1())then
			url = "script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupCreate_1.html";
		end
	end
	commonlib.echo(url);
	if(url)then
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = url, 
			name = "HaqiGroupCreate.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -537/2,
				y = -400/2,
				width = 537,
				height = 320,
		});
	end
	return false;
end
--尚未领取种子
function HaqiGroupCreate.IsState_0()
	return not hasGSItem(30097);
end
--已经领取种子 没有果实
--TODO:如何判断 种在家园的麻烦果种子
function HaqiGroupCreate.IsState_1()
	return hasGSItem(30097) and not hasGSItem(17045);
end
--满足创建家族
function HaqiGroupCreate.IsState_2()
	return hasGSItem(17045);
end
--创建家族 在未领取种子的情况下
function HaqiGroupCreate.DoCreate_Nonefeed()
	--close page
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="HaqiGroupCreate.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
			
	local petLevel = 0;
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean)then
		petLevel = bean.level;
	end
	--龙未达到10级
	if(petLevel < 10)then
		local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你的抱抱龙尚未达到10级，不能创建家族。要先照顾好自己的抱抱龙才能创建家族哦。</div>";
		_guihelper.Custom_MessageBox(s,function(result)
			
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return;
	end
	MyCompany.Aries.Quest.NPCs.HaqiGroupClient.GetUserInfo(nil,function(msg)	
		local hasJoined = false;
		if(msg.family and msg.family ~= "")then
			hasJoined = true;
		end
		--已经加入家族
		if(hasJoined)then
			local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你已经加入其他家族了，不能创建家族。如果想创建自己的家族请先退出其他家族吧。</div>";
			_guihelper.Custom_MessageBox(s,function(result)
				
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			return;
		end
		
		System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupCreate_0_1.html", 
				name = "HaqiGroupCreate.ShowPage.30341_HaqiGroupCreate_0_1", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 1,
				isTopLevel = true,
				allowDrag = false,
				directPosition = true,
					align = "_ct",
					x = -537/2,
					y = -400/2,
					width = 537,
					height = 320,
		});
	end)
end
--接受考验
function HaqiGroupCreate.DoAccept()
	
	--close page
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="HaqiGroupCreate.ShowPage.30341_HaqiGroupCreate_0_1", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
	--送种子
	ItemManager.PurchaseItem(30097,1,function() end,function(msg)
		if(msg) then
		    log("+++++++Purchase 30097_TroubleTreeSeed return: +++++++\n")
		    commonlib.echo(msg);
		    if(msg.issuccess == true) then
		        local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>麻烦树种子已经放入你的背包中了，快快回家好好播种它吧。</div>";
				_guihelper.Custom_MessageBox(s,function(result)
					
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		    end
	    end
		    
		
	end);
end
--创建家族 在有麻烦果的情况下
function HaqiGroupCreate.DoCreate(name,desc)
	--创建家族api
	local msg = {
		name = name,
		desc = desc,
	}
	commonlib.echo("=====before create group in HaqiGroupCreate.DoCreate");
	commonlib.echo(msg);
	paraworld.Family.Create(msg,"group",function(msg)
		commonlib.echo("=====after create group in HaqiGroupCreate.DoCreate");
		commonlib.echo(msg);
		if(msg and msg.issuccess)then
			
			--销毁麻烦果
			local bHas, guid = hasGSItem(17045);
			if(bHas and guid) then
				ItemManager.DestroyItem(guid, 1, function(msg) end, function(msg)
					log("+++++++ Destroy 17045_TroubleTreeFruit return: +++++++\n")
					commonlib.echo(msg);
				end);
			end
			
			-- auto refresh the user self info in memory for family update
			System.App.profiles.ProfileManager.GetUserInfo(nil, nil, function(msg)
				-- force get family info
				MyCompany.Aries.Friends.GetMyFamilyInfo(function(msg)
					-- auto connect to family chat room
					MyCompany.Aries.Chat.FamilyChatWnd.ConnectToMyFamilyChatRoom();
				end, "access plus 0 day");
			end, "access plus 0 day");
			-- send nickname update to chat channel
			MyCompany.Aries.BBSChatWnd.SendUserNicknameUpdate();
			
			--close page
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="HaqiGroupCreate.ShowPage", 
					app_key=MyCompany.Aries.app.app_key, 
					bShow = false,bDestroy = true,});
			local id = msg.newid;
			local s = string.format([[<div style='margin-left:15px;margin-top:20px;text-align:center'>你的家族创建成功，家族编号为%s，点击右下方的“家族”按钮可以查看家族详情。</div>]],MyCompany.Aries.Quest.NPCs.HaqiGroupManage.FormatID(id));
			_guihelper.Custom_MessageBox(s,function(result)
				
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		elseif(msg and msg.errorcode == 432)then
		
			local s = [[<div style='margin-left:15px;margin-top:20px;text-align:center'>这个名字已经有了，试试其他名字吧。</div>]];
			_guihelper.Custom_MessageBox(s,function(result)
				
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		end
	end);
	
end
--家族名称/宣言是否有效
function HaqiGroupCreate.CheckGroup(name,content)
	local name_info_len = ParaMisc.GetUnicodeCharNum(name);
    if(name_info_len == 0)then
	    _guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>你需要先给你的家族起个名字哦！</div>");
        return;
    end
    if(tonumber(name))then
		_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>家族名称不能全部为数字。</div>");
        return;
    end
     if(name_info_len > 6)then
	    _guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>家族名称不能超过6个字。</div>");
        return;
    end
    local content_info_len = ParaMisc.GetUnicodeCharNum(content);
	if(content_info_len > 30)then
	    _guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>家族宣言不能超过30个字。</div>");
        return;
    end
    name = MyCompany.Aries.Chat.BadWordFilter.FilterString(name);
    content = MyCompany.Aries.Chat.BadWordFilter.FilterString(content);
    name = string.gsub(name,"%s","");
    content = string.gsub(content,"%s","");
    if(name == "")then
		_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>家族名称不能为空。</div>");
        return;
    end
    local s = string.format("<div style='margin-left:15px;margin-top:35px;text-align:center'>家族名称不能修改，你确定要使用%s作为家族名称吗？</div>",name);
    _guihelper.Custom_MessageBox(s,function(result)
		if(result == _guihelper.DialogResult.Yes)then
			HaqiGroupCreate.DoCreate(name,content);
		else
			commonlib.echo("no");
		end
	end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/ThinkOver_32bits.png; 0 0 153 49"});
end



-------------- schedule Carnation --------------

function HaqiGroupCreate.GiveCarnation()
	local i = HaqiGroupCreate.GetDailyIndex();
	if(i == 1) then
		-- 362 Carnation_LalaReward_30118_CarpDeco_Green 
		ItemManager.ExtendedCost(362, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 362: Carnation_LalaReward_30118_CarpDeco_Green return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	elseif(i == 2) then
		-- 363 Carnation_LalaReward_30119_CarpDeco_Red 
		ItemManager.ExtendedCost(363, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 363: Carnation_LalaReward_30119_CarpDeco_Red return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	elseif(i == 3) then
		-- 364 Carnation_LalaReward_30120_MoneyCoinDeco 
		ItemManager.ExtendedCost(364, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 364: Carnation_LalaReward_30120_MoneyCoinDeco return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	end
end

function HaqiGroupCreate.GiveCarnationToday()
	-- 50282_LalaRecvCarnationToday
	local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50282);
	if(gsObtain and gsObtain.inday == 1) then
		return true;
	else
		return false;
	end
end

function HaqiGroupCreate.NotGiveCarnationTodayAndHaveCarnation()
	-- 17085_CollectableCarnation
	if(not HaqiGroupCreate.GiveCarnationToday() and (hasGSItem(17085, 12))) then
		return true;
	else
		return false;
	end
end

function HaqiGroupCreate.GetRandomRewardName()
	local i = HaqiGroupCreate.GetDailyIndex();
	if(i == 1) then
		return "绿鳞金鱼挂饰";
	elseif(i == 2) then
		return "红鳞金鱼挂饰";
	elseif(i == 3) then
		return "孔方挂饰";
	end
end

function HaqiGroupCreate.GetRandomRewardGSID()
	local i = HaqiGroupCreate.GetDailyIndex();
	if(i == 1) then
		return 30118;
	elseif(i == 2) then
		return 30119;
	elseif(i == 3) then
		return 30120;
	end
end

function HaqiGroupCreate.GetDailyIndex()
	local nid = System.App.profiles.ProfileManager.GetNID();
	local serverdate = MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	serverdate = string.gsub(serverdate, "%D", "");
	local days = tonumber(serverdate);
	
	local i = math.mod(math.mod((days * nid), 2287), 3) + 1; -- 2287: the 340th prime number
	return i;
end