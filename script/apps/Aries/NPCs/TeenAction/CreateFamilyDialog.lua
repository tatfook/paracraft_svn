--[[
Title: CreateFamilyDialog
Author(s): Leio
Date: 2011/11/07
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TeenAction/CreateFamilyDialog.lua");
local CreateFamilyDialog = commonlib.gettable("MyCompany.Aries.Quest.NPCs.TeenAction.CreateFamilyDialog");
-------------------------------------------------------
]]
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local CreateFamilyDialog = commonlib.gettable("MyCompany.Aries.Quest.NPCs.TeenAction.CreateFamilyDialog");
function CreateFamilyDialog.ShowPage(param1)
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	local can_pass = DealDefend.CanPass();
	if(not can_pass)then
		return
	end
	param1 = tonumber(param1) or 0;
	System.App.Commands.Call("Profile.Aries.ShowNPCDialog_Teen_Native",{
		dialog_url = "script/apps/Aries/NPCs/TeenAction/CreateFamilyDialog.html",
		npc_id = param1,
	});
end
--检查创建家族的条件
function CreateFamilyDialog.CheckGroup(name,content)
	local name_info_len = ParaMisc.GetUnicodeCharNum(name);
    if(name_info_len == 0)then
	    _guihelper.MessageBox("<div style='margin-left:15px;margin-top:15px;text-align:center'>你需要先给你的家族起个名字哦！</div>");
        return;
    end
    if(tonumber(name))then
		_guihelper.MessageBox("<div style='margin-left:15px;margin-top:15px;text-align:center'>家族名称不能全部为数字。</div>");
        return;
    end
     if(name_info_len > 6)then
	    _guihelper.MessageBox("<div style='margin-left:15px;margin-top:15px;text-align:center'>家族名称不能超过6个字。</div>");
        return;
    end
    local content_info_len = ParaMisc.GetUnicodeCharNum(content);
	if(content_info_len > 30)then
	    _guihelper.MessageBox("<div style='margin-left:15px;margin-top:15px;text-align:center'>家族宣言不能超过30个字。</div>");
        return;
    end
    name = MyCompany.Aries.Chat.BadWordFilter.FilterString(name);
    content = MyCompany.Aries.Chat.BadWordFilter.FilterString(content);
    name = string.gsub(name,"%s","");
    content = string.gsub(content,"%s","");
    if(name == "")then
		_guihelper.MessageBox("<div style='margin-left:15px;margin-top:15px;text-align:center'>家族名称不能为空。</div>");
        return;
    end
	return true;
end

--创建家族
function CreateFamilyDialog.DoCreate(name,desc)
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
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="CreateFamilyDialog.ShowCreatePage", 
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
--检查创建家族的条件
function CreateFamilyDialog.DoCreateBefore()
	Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nil, "", function(msg)
		if(msg and msg.users and msg.users[1]) then
			local user = msg.users[1];
			local combatlel = user.combatlel or 0;
			local emoney = user.emoney or 0;
			local pmoney = user.pmoney or 0;
			local family = user.family;
			if(family and family ~= "")then
				_guihelper.MessageBox("你已经加入其他家族了，不能创建家族。如果想创建自己的家族请先退出其他家族吧。");
				return
			end
			local money = emoney + pmoney;
			--if(combatlel < 20)then
				--_guihelper.MessageBox("你的等级不够，不能创建家族！");
				--return
			--end
			local __,__,__,copies = hasGSItem(984);
			copies = copies or 0;
			if(copies < 300)then
				_guihelper.Custom_MessageBox("你的金币不够，不能创建家族！是否充值？",function(result)
					if(result == _guihelper.DialogResult.Yes)then
						NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.lua");
						local PurchaseMagicBean = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseMagicBean");
						PurchaseMagicBean.Show()     
					end
				end,_guihelper.MessageBoxButtons.YesNo);  
				return
			end
			CreateFamilyDialog.ShowCreatePage();
		end
	end)
end
--显示创建家族的面板
function CreateFamilyDialog.ShowCreatePage()
	System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/NPCs/TeenAction/CreateFamilyPage.html", 
				name = "CreateFamilyDialog.ShowCreatePage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = true,
				directPosition = true,
					align = "_ct",
					x = -500/2,
					y = -170/2,
					width = 500,
					height = 170,
		});		
end