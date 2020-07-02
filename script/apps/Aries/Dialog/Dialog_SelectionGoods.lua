--[[
Title: dialog box for selection multi-items
Author(s): WD
Date: 2011/10/24
Desc:
Use Lib: 
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Dialog/Dialog_SelectionGoods.lua");
local Dialog_SelectionGoods = commonlib.gettable("MyCompany.Aries.Dialog.Dialog_SelectionGoods");
Dialog_SelectionGoods.ShowPage();
-------------------------------------------------------
]]

-- create class
local Dialog_SelectionGoods = commonlib.gettable("MyCompany.Aries.Dialog.Dialog_SelectionGoods");


function Dialog_SelectionGoods:Init()
	self.page = document:GetPageCtrl();

	self.page:SetValue("txtItemsCount", Dialog_SelectionGoods.incoming_items_count or 1)
	self.page:SetValue("trackbarMultiItems", Dialog_SelectionGoods.incoming_items_count or 1)
end

function Dialog_SelectionGoods.ShowPage(hold_items_count,callback)
	--hold_items_count = hold_items_count or 100;--100 for test
	if(not hold_items_count or hold_items_count == "" or hold_items_count <= 0)then return 0;end
	local self = Dialog_SelectionGoods;
	
	self.hold_items_count = hold_items_count;
	self.incoming_items_count = hold_items_count;
	self.callback = callback;

	self.nfirst = 1;
	self.nforth = self.hold_items_count;
	self.nhalf = "";
	if(self.hold_items_count < 30 and self.hold_items_count > 6)then
		self.nsecond = "";
		self.nhalf = math.floor(self.hold_items_count / 2) + 1;
		self.nthird = "";
	elseif (self.hold_items_count < 7)then
		self.nsecond = "";
		self.nthird = "";
	else
		local mod_factor = 3;
		local _n = math.floor(hold_items_count / mod_factor);

		self.nsecond =  _n;
		self.nthird = _n * 2;
	end

	if(System.options.version =="kids")then
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Dialog/Dialog_SelectionGoods.kids.html" , 
			name = "Dialog_SelectionGoods.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = false,
			directPosition = true,
			isTopLevel = true,
			align = "_ct",
			x = -230 * 0.5,
			y = -164 * 0.5,
			width = 230,
			height = 164,});
	else
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Dialog/Dialog_SelectionGoods.html" , 
			name = "Dialog_SelectionGoods.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = false,
			directPosition = true,
			isTopLevel = true,
			zorder = 7,
			align = "_ct",
			x = -230 * 0.5,
			y = -164 * 0.5,
			width = 230,
			height = 164,});
	end

	local trackbarMultiItems = self.page:FindControl("trackbarMultiItems")
	if(trackbarMultiItems)then
		trackbarMultiItems.max = MyCompany.Aries.Dialog.Dialog_SelectionGoods.nforth;
		trackbarMultiItems.value = MyCompany.Aries.Dialog.Dialog_SelectionGoods.incoming_items_count;
		if(self.hold_items_count < 50)then
			trackbarMultiItems.min_step = 1;
		else
			trackbarMultiItems.min_step = 210 / self.hold_items_count;
		end
	end
	
end

function Dialog_SelectionGoods.OnKeyup(ctrl)
	local self = Dialog_SelectionGoods;

	local ctrl = self.page:FindControl(ctrl);
    if(not tonumber(ctrl.text))then
		self.page:SetUIValue("txtItemsCount",self.incoming_items_count or 1)
		return;
    end

	if(tonumber(ctrl.text) > self.hold_items_count)then
		self.incoming_items_count = self.hold_items_count;	
		self.page:SetUIValue("txtItemsCount",self.incoming_items_count)
			
	elseif(tonumber(ctrl.text) < 1)then
		self.incoming_items_count = 1;
		self.page:SetUIValue("txtItemsCount",self.incoming_items_count)
	else
		self.incoming_items_count = tonumber(ctrl.text);
	end

	self.incoming_items_count = math.floor(self.incoming_items_count);
	self.page:SetUIValue("trackbarMultiItems",math.floor(self.incoming_items_count))
end

function Dialog_SelectionGoods.OnClick(ctrl_name)
	local self = Dialog_SelectionGoods;

	if(ctrl_name  == "1")then --apply current selection
		if(self.callback and type(self.callback) == "function")then
			self.callback(self.page:GetValue("txtItemsCount"));
			self:CloseWindow();
		end
	elseif (ctrl_name == "0")then --close dialog
		self:CloseWindow();
	end
end

function Dialog_SelectionGoods:CalResult()
	self.incoming_items_count = (self.page:GetValue("trackbarMultiItems") or 0);
	local trackbarMultiItems = self.page:FindControl("trackbarMultiItems")
	local cal_result;
	if((self.hold_items_count - self.incoming_items_count) < trackbarMultiItems.min_step)then
		cal_result = self.hold_items_count;
	else
		cal_result = math.floor(self.incoming_items_count)
	end
	return cal_result;
end

function Dialog_SelectionGoods.OnChangeCount()
	local self = Dialog_SelectionGoods;
	self.page:SetUIValue("txtItemsCount",self:CalResult())
end

function Dialog_SelectionGoods:Update(delta)
	self.page:Refresh(delta or 0.1);
end
function Dialog_SelectionGoods:CloseWindow()
	self.page:CloseWindow();
end

