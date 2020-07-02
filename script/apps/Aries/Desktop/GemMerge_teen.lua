--[[
Title: 
Author(s): WD
Date: 2011/07/25
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/GemMerge_teen.lua");
MyCompany.Aries.Desktop.GemMerge_teen.ShowPage();
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_gems_subpage.lua");
NPL.load("(gl)script/ide/timer.lua");

local GemMerge_teen = commonlib.gettable("MyCompany.Aries.Desktop.GemMerge_teen");
local Avatar_gems_subpage = commonlib.gettable("MyCompany.Aries.Desktop.Avatar_gems_subpage");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local ItemManager = Map3DSystem.Item.ItemManager;
local MSG = _guihelper.MessageBox;
local echo = commonlib.echo;

GemMerge_teen.timer =  commonlib.Timer:new({callbackFunc = function(timer)
	GemMerge_teen.PlayAnimation = false;
	if(GemMerge_teen.mergeSuccess) then
		Avatar_gems_subpage:ZeroIncomingGem(true);
		GemMerge_teen.page:SetValue("RefinedGemGsid",Avatar_gems_subpage.IncomingGem.high_level_gsid or 0);
		Avatar_gems_subpage:Update();
	else
		MSG("很遗憾，没有成功合成宝石！");
	end

	GemMerge_teen.page:SetValue("AlphaPPT","0");
	GemMerge_teen:Refresh();
end})


GemMerge_teen.mergeOdd = "";
GemMerge_teen.modValueRange = {-4,-3,-2,-1,0,};
GemMerge_teen.timeLucky = GemMerge_teen.timeLucky or 0;
GemMerge_teen.modValue = GemMerge_teen.modValue or 0;

GemMerge_teen.HoldQidou = "";
GemMerge_teen.CostQidou = "";
GemMerge_teen.PlayAnimation = false;
GemMerge_teen.mergeSuccess = false;
GemMerge_teen.starCount = -1;

local seed = math.randomseed;
local random = math.random;
local SLOTS_COUNT  = 5;

function GemMerge_teen:ResetIncomingGems(index)
	local i;

	for i = 1,SLOTS_COUNT do
		self.page:SetValue("IncomingGemGsid" .. i,0);
	end

	for i = 1,index do
		self.page:SetValue("IncomingGemGsid" .. i,Avatar_gems_subpage.IncomingGem.gsid or 0);
	end
end

function GemMerge_teen:Init()
	self.page = document:GetPageCtrl();

	if(Avatar_gems_subpage) then
		self:ResetIncomingGems(Avatar_gems_subpage.IncomingGem.copies);
		self:CalcQidou();

		if(Avatar_gems_subpage.IncomingGem.copies == 1) then
		self.page:SetValue("RefinedGemGsid", 0);
		end

		if(Avatar_gems_subpage.IncomingGem.copies > 1) then
			self.mergeOdd = Avatar_gems_subpage.GemsOdds[Avatar_gems_subpage.IncomingGem.copies] + (self.timeLucky or 0)  + (self.modValue or 0);
			if(self.mergeOdd > 100) then
				self.mergeOdd = "100";
			else
				self.mergeOdd = self.mergeOdd;
			end
		else
			self.mergeOdd = 0;
		end
	end
	
	self.HoldQidou = MyCompany.Aries.Player.GetMyJoybeanCount();
	self.page:SetValue("pgbGemMergeOdds",self.mergeOdd or 0);
end

--[[
	pop gem refine window
--]]
function GemMerge_teen:ShowPage()
	local self = GemMerge_teen;
	seed(os.time());

	local value = random(1,5);	
	self.timeLucky,self.starCount = Player.GetTimeLucky();
	self.modValue = self.modValueRange[value];

	Avatar_gems_subpage:BindParent("GemMerge",self);

	--make sure the value of width and height is copy from design page
	local width,height = 758,470;

	Avatar_gems_subpage.GemsOdds = {[2] = 10, [3] = 25,[4] = 40,[5] = 90,};

    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Desktop/GemMerge_teen.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "CombatCharacterFrame.ShowPage", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = CommonCtrl.WindowFrame.ContainerStyle,
		enable_esc_key = true,
        zorder = 2,
        allowDrag = true,
		isTopLevel = true,
        directPosition = true,
        align = "_ct",
        x = -width * 0.5,
        y = -height * 0.5,
        width = width,
        height = height,});

	Avatar_gems_subpage:GetAllItems();
	Avatar_gems_subpage:Update();
end

--[[
	refresh whole page of gem refine
--]]
function GemMerge_teen:Refresh(delta)
	self.page:Refresh(delta or 0.1);
end

--compuation for cost money
function GemMerge_teen:CalcQidou()
	self.CostQidou = Avatar_gems_subpage.CostQidouUnit * Avatar_gems_subpage.IncomingGem.copies;
	if(self.CostQidou == 0) then
		self.CostQidou = "";
	end
end

function GemMerge_teen:CloseWindow()
	self.mergeOdd = 0;
	self.CostQidou = "";

	--clear gems subpage state
	Avatar_gems_subpage:ResetStates(1);
	self.page:CloseWindow();
end

function GemMerge_teen.GemRefine()
	local self = GemMerge_teen;

	if(Avatar_gems_subpage:IsEmpty()) then
		MSG("你还没有宝石！");
		return;
	end
	if(Avatar_gems_subpage.IncomingGem.gsid == 0) then
		MSG("你还没有选择一颗待合成的宝石！");
		return;
	end

	if(Avatar_gems_subpage.IncomingGem.level == 5) then
		MSG("五级宝石不需要合成哦！");
		return;
	end

	if(Avatar_gems_subpage.IncomingGem.copies < 2) then
		MSG("宝石合成至少要有2颗宝石以上哦！");
		return;
	end

	if(self.HoldQidou >= self.CostQidou) then
		if(Avatar_gems_subpage.IncomingGem.guid  and Avatar_gems_subpage.IncomingGem.high_level_gsid) then
			self.page:SetValue("AlphaPPT","1");
			self.PlayAnimation = true;
			self:Refresh();
					
			self:_refine(function(msg) self.timer:Change(3000);end,function(msg)end);
		end

	else
		--echo("你的银币不足以合成宝石！");	
		MSG("你的银币不足以合成宝石！");	
	end
end

--[[
	before update data source,must calc incoming gems copies
--]]
function GemMerge_teen:CancelItem(arg)
	Avatar_gems_subpage.IncomingGem.copies = Avatar_gems_subpage.IncomingGem.copies  - 1;
	Avatar_gems_subpage:Update(
		function() 
			self:Refresh(); 
		end);
end

function GemMerge_teen:_refine(bag_cb,timeout_cb)
	ItemManager.CraftGem2({[Avatar_gems_subpage.IncomingGem.guid]=Avatar_gems_subpage.IncomingGem.copies},
	Avatar_gems_subpage.IncomingGem.high_level_gsid,
	function(msg)
		if(msg) then
			if(msg.issuccess and msg.errorcode==0)then
				self.mergeSuccess = true;
			else
				self.mergeSuccess = false;
			end
		end
		
	end,bag_cb,timeout_cb);
end