--[[
Title: code behind for learning or forget skill
Author(s): WD, LiXizhi
Date: 2011/11/08
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/ForgetSkill.teen.lua");
local ForgetSkill = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.ForgetSkill");
ForgetSkill.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Player/main.lua");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local GetItemsInBag = ItemManager.GetItemsInBag;
local MSG = _guihelper.MessageBox;
local echo = commonlib.echo;

NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/LearnedSkill_subpage.teen.lua");
local LearnedSkill_subpage = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.LearnedSkill_subpage");

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");
local ForgetSkill = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.ForgetSkill");


ForgetSkill._DEBUG = ForgetSkill._DEBUG or false;
function ForgetSkill:LOG(caption,obj)
	if(self._DEBUG)then
		echo(caption);
		echo(obj);
	end
end

function ForgetSkill:Init()
	self.page = document.GetPageCtrl();
end

function ForgetSkill.ShowPage()
	local self = ForgetSkill;
	local width,height = 468,470;

	LearnedSkill_subpage:LoadData()

	local params = {
	url = "script/apps/Aries/NPCs/SnowArea/ForgetSkill.teen.html", 
	name = "ForgetSkill.ShowPage", 
	app_key=MyCompany.Aries.app.app_key, 
    isShowTitleBar = false,
    DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
    style = CommonCtrl.WindowFrame.ContainerStyle,
	enable_esc_key = true,
    allowDrag = true,
	isTopLevel = true,
    directPosition = true,
    align = "_ct",
    x = -width * .5,
    y = -height * 0.5,
    width = width,
    height = height,}
	System.App.Commands.Call("File.MCMLWindowFrame", params);


	if(params._page)then
		params._page.OnClose = ForgetSkill.Clean;
	end

end


function ForgetSkill:OnForgetSkill(gsid)
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	if(not DealDefend.CanPass())then
		return
	end
	if(not gsid)then return end
	gsid = tonumber(gsid)
	local _,guid,__,copies = hasGSItem(gsid)

	local spec_name = ""
	local gsitem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsitem)then
		spec_name = gsitem.template.name or "";
	end

	self:LOG("guid:",guid)
	self:LOG("copies:",copies)
	local title_name = LearnedSkill_subpage.ItemsCates[gsid].title_name or "unknown";
	_guihelper.MessageBox(string.format("你确定遗忘专业【%s】,不再做一名%s？",spec_name,title_name),function(res) 
		if(res and res == _guihelper.DialogResult.OK) then
			ItemManager.DestroyItem(guid,copies,function(msg1) 
				self:LOG("msg1:",msg1)
			end,function(msg2)
				self:LOG("msg2:",msg2)
				GetItemsInBag( 0, "0", function(msg) 
							local has21109,_,__,_ = hasGSItem(21109)
							local has21110,_,__,_ = hasGSItem(21110)
							self:LOG("has21109:",has21109)
							self:LOG("has21110:",has21110)

							if(gsid == 21109 or gsid == 21110)then
								CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", { action_type = "gatherer_skill_lost", wndName = "main",});
							end
									
							if(self.page)then
								self.page:Refresh(0);
							end		
					end, "access plus 0 seconds");end);
		end
	end)
end

-- learn a new skill.
function ForgetSkill:PurchaseNewSkill(gsid)
	if(not gsid)then return end
	gsid = tonumber(gsid)
	local bHas,guid,__,copies = hasGSItem(gsid)
	if(bHas) then
		return;
	end
	local spec_name = ""
	local gsitem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsitem)then
		spec_name = gsitem.template.name or "";
	end
	local skill = LearnedSkill_subpage:GetMakeSkill(gsid);
	if(skill and skill.exid) then
		local exid = skill.exid;

		local level;
		local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
		if(exTemplate and exTemplate.pres)then	
			local k,v;
            for k,v in pairs(exTemplate.pres) do
				if (tonumber(v.key)==-14) then
					level = tonumber(v);
				end
			end
		end

		if(not level or Player.GetLevel() >= level) then
			local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
			if(command and gsid) then
				command:Call({exid = exid, gsid = gsid, npc_shop = true});
			end
		elseif(level) then
			_guihelper.MessageBox(format("你的等级不够。 %d级之后才能学习, 快去升级吧!", level));
		end
		
	end
end

function ForgetSkill:Refresh(delta)
	if(self and self.page)then
		self.page:Refresh(delta or 0.1);
	end
end

function ForgetSkill:CloseWindow()
	if(self and self.page)then
		self.page:CloseWindow();
	end
end

function ForgetSkill:Clean()

end
