--[[
Title: 
Author(s): leio
Date: 2013/1/18
Desc:  

NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/TotemPage.lua");
local TotemPage = commonlib.gettable("MyCompany.Aries.Desktop.TotemPage");
TotemPage.ShowLearnPage()

NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/TotemPage.lua");
local TotemPage = commonlib.gettable("MyCompany.Aries.Desktop.TotemPage");
TotemPage.ShowPage()
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local TotemPage = commonlib.gettable("MyCompany.Aries.Desktop.TotemPage");
NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
local ProfileManager = commonlib.gettable("System.App.profiles.ProfileManager");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
TotemPage.state = "";--"tolearn" "forget"
TotemPage.menus = {
	{ label = "全部", selected = true, keyname = nil, },
	--{ label = "测试", keyname = "folder_1", },
}
TotemPage.bags = {
	["folder_1"] = {
		["subfolder_1"] = 
		{
			{
				bag = 14, class = 3, subclass = {21}, 
			},
		},
	},
}
function TotemPage.GetSkills()
	if(CommonClientService.IsTeenVersion())then
		if(not TotemPage.skills)then
			TotemPage.skills = {
				{ gsid = 50377, exid = nil, name = "符印攻击", label = "符印攻击", },
				{ gsid = 50378, exid = nil, name = "符印防御", label = "符印防御", },
				{ gsid = 50379, exid = nil, name = "符印生命", label = "符印生命", },
				{ gsid = 50380, exid = nil, name = "符印超魔", label = "符印超魔", },
				{ gsid = 50381, exid = nil, name = "符印暴击", label = "符印暴击", },
				{ gsid = 50382, exid = nil, name = "符印韧性", label = "符印韧性", },
				{ gsid = 50383, exid = nil, name = "符印命中", label = "符印命中", },
				{ gsid = 50384, exid = nil, name = "符印闪避", label = "符印闪避", },
				{ gsid = 50385, exid = nil, name = "符印治疗", label = "符印治疗", },
			};
		end
	else
		if(not TotemPage.skills)then
			TotemPage.skills = {
				{ gsid = 50351, exid = 3001, name = "巨龙之牙", label = "巨龙之牙图腾:增加绝对防御和致命一击", },
				{ gsid = 50352, exid = 3002, name = "巨龙之爪", label = "巨龙之爪图腾:增加魔法暴击率", },
				{ gsid = 50353, exid = 3003, name = "巨龙之鳞", label = "巨龙之鳞图腾:减少伤害", },
				{ gsid = 50354, exid = 3004, name = "巨龙之心", label = "巨龙之心图腾:增加治疗和被治疗", },
			};
		end
	end
	return TotemPage.skills;
end
function TotemPage.OnInit()
	TotemPage.page = document:GetPageCtrl();
end
function TotemPage.OnInit_LearnPage()
	TotemPage.learn_page = document:GetPageCtrl();
end
function TotemPage.PowerExtendedCost_Handle(msg)
	if(msg)then
		local msg_data = msg.msg or {};
		local input_msg = msg.input_msg or {};
		if(msg_data.issuccess)then
			TotemPage.state = "forget"; 
			if(TotemPage.temp_learned)then
				_guihelper.MessageBox(
					if_else(System.options.version=="teen","恭喜你转换强化属性成功！","恭喜你转换信仰成功！")
					, function(res)
					if(res and res == _guihelper.DialogResult.OK) then
						if(TotemPage.learn_page)then
							TotemPage.learn_page:Refresh(1);
						end				
					end
				end, _guihelper.MessageBoxButtons.OK);
			else
				_guihelper.MessageBox(if_else(System.options.version=="teen","恭喜你学习强化属性成功！","恭喜你学习信仰成功！"), function(res)
					if(res and res == _guihelper.DialogResult.OK) then
						if(TotemPage.learn_page)then
							TotemPage.learn_page:Refresh(1);
						end				
					end
				end, _guihelper.MessageBoxButtons.OK);
			end
		else
			if(TotemPage.temp_learned)then
				_guihelper.MessageBox(if_else(System.options.version=="teen","转换强化属性失败！","转换信仰失败！"));
			else
				_guihelper.MessageBox(if_else(System.options.version=="teen","学习强化属性失败！","学习强化属性失败！"));
			end
		end
		if(TotemPage.learn_page)then
			TotemPage.learn_page:Refresh(1);
		end
	end
end
function TotemPage.HasLearned(nid)
	local skills = TotemPage.GetSkills()
	local k,v;
	for k,v in ipairs(skills) do
		if(nid and nid ~= ProfileManager.GetNID()) then
			if(ItemManager.IfOPCOwnGSItem(nid, v.gsid)) then
				return true,v;
			end
		else
			if(hasGSItem(v.gsid))then
				return true,v;
			end
		end
	end
end
function TotemPage.DS_Func_Items(index)
	if(not TotemPage.items)then return 0 end
	if(index == nil) then
		return #(TotemPage.items);
	else
		return TotemPage.items[index];
	end
end
function TotemPage.OnClickFolder(folder_key,subfolder_key,need_refresh)
	local bag_list = BagHelper.GetBagList(folder_key,subfolder_key,TotemPage.bags);
	TotemPage.items = BagHelper.SearchBagList_Memory(nil,bag_list);
	CommonClientService.Fill_List(TotemPage.items,25);
	TotemPage.folder_key = folder_key;
	TotemPage.subfolder_key = subfolder_key;
	if(TotemPage.page and need_refresh)then
		TotemPage.page:Refresh(0);
	end
end
function TotemPage.DS_Func_skills(index)
	if(not TotemPage.skills)then return 0 end
	if(index == nil) then
		return #(TotemPage.skills);
	else
		return TotemPage.skills[index];
	end
end
function TotemPage.ShowLearnPage(state)
	TotemPage.GetSkills();
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	TotemPage.state = state or "tolearn"; 
	local url;
	if(CommonClientService.IsTeenVersion())then
		url = string.format("script/apps/Aries/Desktop/CombatCharacterFrame/TotemLearnPage.teen.html");
	else
		url = string.format("script/apps/Aries/Desktop/CombatCharacterFrame/TotemLearnPage.html");
	end
	local params = {
		url = url, 
		app_key = MyCompany.Aries.app.app_key, 
		name = "TotemPage.ShowLearnPage", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		cancelShowAnimation = true,
		style = style,
		bToggleShowHide = true,
		-- zorder = 0,
		allowDrag = true,
		-- isTopLevel = true,
		enable_esc_key = true,
		directPosition = true,
			align = "_ct",
			x = -690/2,
			y = -443/2,
			width = 690,
			height = 443,
	}
    System.App.Commands.Call("File.MCMLWindowFrame", params);
	TotemPage.temp_learned = TotemPage.HasLearned();
end
function TotemPage.ShowPage()
	TotemPage.GetSkills();
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	local url = string.format("script/apps/Aries/Desktop/CombatCharacterFrame/TotemPage.teen.html");
	local params = {
		url = url, 
		app_key = MyCompany.Aries.app.app_key, 
		name = "TotemPage.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		cancelShowAnimation = true,
		style = style,
		bToggleShowHide = true,
		-- zorder = 0,
		allowDrag = true,
		-- isTopLevel = true,
		enable_esc_key = true,
		directPosition = true,
			align = "_ct",
			x = -668/2,
			y = -420/2,
			width = 668,
			height = 420,
	}
    System.App.Commands.Call("File.MCMLWindowFrame", params);
end

-- 
function TotemPage.AutoShowPage()
	if(not TotemPage.HasLearned())then
        TotemPage.ShowLearnPage();
    else
        TotemPage.ShowPage()
    end
end
    