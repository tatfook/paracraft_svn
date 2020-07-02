--[[
Title: The dock page
Author(s): LiXizhi
Date: 2012/12/28
Desc:  
There dock has 2 mode: one for editor and one for creator
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/QuickSelectBar.lua");
local QuickSelectBar = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.QuickSelectBar");
QuickSelectBar.ShowPage(true)
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Items/ItemClient.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Effects/ObtainItemEffect.lua");
local ObtainItemEffect = commonlib.gettable("MyCompany.Aries.Game.Effects.ObtainItemEffect");
local ItemClient = commonlib.gettable("MyCompany.Aries.Game.Items.ItemClient");
local Desktop = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop");
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local QuickSelectBar = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.QuickSelectBar");

-- this should be the same as the items per line. 
QuickSelectBar.static_view_len = 9;
QuickSelectBar.static_view_page_index = 1;
QuickSelectBar.custombtn_nodes = {
	{},{},{},{},{},{},{},{},{},
};
QuickSelectBar.maxHp = 8;
QuickSelectBar.lastHp = 8;
QuickSelectBar.curHp = 8;

QuickSelectBar.maxHunger = 8;
QuickSelectBar.lastHunger = 8;
QuickSelectBar.curHunger = 8;

QuickSelectBar.maxExp = 100;
QuickSelectBar.curExp = 0;

QuickSelectBar.progress_bar_width = 358; 
local custombtn_game_nodes = {}
local custombtn_editor_nodes = {}

-- whether the data is modified. 
QuickSelectBar.IsModified = false;
local page;

local max_item_count = 32;

-- called when block texture changes. 
function QuickSelectBar.OnBlockTexturePackChanged(self, event)
	QuickSelectBar.Refresh();
end

function QuickSelectBar.OnInit()
	page = document:GetPageCtrl();
	
	GameLogic.events:AddEventListener("OnHandToolIndexChanged", QuickSelectBar.OnHandToolIndexChanged, QuickSelectBar, "QuickSelectBar");
	GameLogic.events:AddEventListener("SetBlockInRightHand", QuickSelectBar.OnSetBlockInRightHand, QuickSelectBar, "QuickSelectBar");
	GameLogic.events:AddEventListener("block_texture_pack_changed", QuickSelectBar.OnBlockTexturePackChanged, QuickSelectBar, "QuickSelectBar");
	GameLogic.events:AddEventListener("game_mode_change", QuickSelectBar.OnGameModeChanged, QuickSelectBar, "QuickSelectBar");
	GameLogic.events:AddEventListener("OnHintSelectBlock", QuickSelectBar.OnHintSelectBlock, QuickSelectBar, "QuickSelectBar");
	GameLogic.events:AddEventListener("OnPlayerReplaced", QuickSelectBar.OnPlayerReplaced, QuickSelectBar, "QuickSelectBar");
end

------------------------
-- input hooked event handler
------------------------
function QuickSelectBar:OnGameModeChanged(event)
	if(page) then
		if(page:IsVisible()) then 
			if(not GameLogic.GameMode:IsShowGoalTracker()) then
				QuickSelectBar.ShowPage(false);
				return;
			end
		else
			if(GameLogic.GameMode:IsShowGoalTracker()) then
				QuickSelectBar.ShowPage(true);
				return;
			end
		end
	end
	QuickSelectBar.Refresh();
end

local last_hind_time;
local last_block_index;
local count_down = 6;
function QuickSelectBar:OnHintSelectBlock(event)
	if(page) then
		last_block_index = event.index or 1;
		
		count_down = 6;

		QuickSelectBar.hint_timer = QuickSelectBar.hint_timer or commonlib.Timer:new({callbackFunc = function(timer)
			count_down = count_down - 1;
			if(GameLogic.GetPlayerController():GetHandToolIndex() == last_block_index or count_down<0) then
				timer:Change();
			else
				QuickSelectBar:AnimateBlockHint(last_block_index);
			end
		end})
		
		if(not QuickSelectBar.hint_timer:IsEnabled()) then
			QuickSelectBar.hint_timer:Change(0, 600);
		end
	end
end

function QuickSelectBar:OnPlayerReplaced()
	if(page) then
		page:Refresh(0.1);
	end
end

function QuickSelectBar:AnimateBlockHint(index)
	if(page) then
		local ctl = page:FindControl("handtool_highlight_bg");
		if(ctl) then
			local x, y = ctl:GetAbsPosition();
			x = x + ((index or 1)-GameLogic.GetPlayerController():GetHandToolIndex())*41;
			local m_x, m_y = ParaUI.GetMousePosition();
			--ObtainItemEffect:new({background="Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;464 43 18 18", duration=800, color="#ffffffff", width=18,height=18, 
				--from_2d={x=m_x, y=m_y}, to_2d={x=x+12, y=y+8}}):Play();

			ObtainItemEffect:new({background="Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;74 45 40 40:12 12 12 12", duration=500, color="#ffffffff", width=42,height=42, 
				from_2d={x=x, y=y}, to_2d={x=x, y=y}, fadeIn=200, fadeOut=200}):Play();

			ObtainItemEffect:new({background="Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;141 137 30 34", duration=500, color="#ffffffff", width=30,height=34, 
				from_2d={x=x+5, y=y-80}, to_2d={x=x+5, y=y-10}, fadeIn=100, fadeOut=100}):Play();
		end
	end
end

function QuickSelectBar:OnSetBlockInRightHand(event)
	if(page and event.block_id ~= self.last_block_id) then
		local ctl = page:FindControl("handtool_tooltip");
		if(ctl) then
			local block_id = GameLogic.GetPlayerController():GetBlockInRightHand();
			if(block_id and block_id>0) then
				ctl.x = (GameLogic.GetPlayerController():GetHandToolIndex()-1)*41;
				ctl.visible = true;
			
				local item = ItemClient.GetItem(block_id);
				local text;
				if(item) then
					text = item:GetDisplayName() or tostring(block_id);
				else
					text = tostring(block_id);
				end
				ctl.width = math.min(100, _guihelper.GetTextWidth(text)*1.2+5);

				ctl.text = text;
				if(not QuickSelectBar.tooltip_timer) then
					QuickSelectBar.tooltip_timer = commonlib.Timer:new({callbackFunc = function(timer)
						local ctl = page:FindControl("handtool_tooltip");
						if(ctl) then
							ctl.visible = false;
						end
					end})
				end
				QuickSelectBar.tooltip_timer:Change(4000,nil);
			else
				ctl.visible = false;
				if(QuickSelectBar.tooltip_timer) then
					QuickSelectBar.tooltip_timer:Change();
				end
			end
		end
	end
end

function QuickSelectBar:OnHandToolIndexChanged(event)
	if(page) then
		local ctl = page:FindControl("handtool_highlight_bg");
		if(ctl) then
			ctl.x = (GameLogic.GetPlayerController():GetHandToolIndex()-1)*41;
		end
	end
end

function QuickSelectBar.ShowPage(bShow)
	--if(bShow and not GameLogic.GameMode:IsShowQuickSelectBar()) then
		--return true;
	--end

	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Creator/Game/Areas/QuickSelectBar.html", 
			name = "QuickSelectBar.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = false,
			bShow = bShow,
			zorder = -5,
			click_through = true, 
			directPosition = true,
				align = "_ctb",
				x = 0,
				y = 0,
				width = 400,
				height = 96,
		});
end

function QuickSelectBar.Refresh(nDelayTime)
	if(page) then
		page:Refresh(nDelayTime or 0.01);
	end
end

-- @param key_index: 1-9
function QuickSelectBar.OnSelectByKeyIndex(key_index)
	if(key_index and key_index>=1 and key_index<=QuickSelectBar.static_view_len) then
		local index  = (QuickSelectBar.static_view_page_index-1)*QuickSelectBar.static_view_len + key_index;
		GameLogic.GetPlayerController():SetHandToolIndex(key_index);
	end
end

-- bind the current progress bar to a given progress interface. 
-- the IProgress must have GetMaxValue() and GetValue() and GetEvents() method. 
function QuickSelectBar.BindProgressBar(IProgress)
	if(QuickSelectBar.IProgress) then
		QuickSelectBar.IProgress:GetEvents():RemoveEventListener("OnChange", QuickSelectBar.OnProgressChanged, QuickSelectBar);
	end
	QuickSelectBar.IProgress = IProgress;
	if(IProgress) then
		if(page) then
			page:FindControl("progress_wnd").visible = true;
		end
		QuickSelectBar.IProgress:GetEvents():AddEventListener("OnChange", QuickSelectBar.OnProgressChanged, QuickSelectBar, "QuickSelectBar");
		QuickSelectBar:OnProgressChanged();
	else
		if(page) then
			page:FindControl("progress_wnd").visible = false;
		end
	end
end

function QuickSelectBar:OnProgressChanged()
	local IProgress = QuickSelectBar.IProgress;
	if(IProgress and page) then
		self.maxExp = IProgress:GetMaxValue();
		self.curExp = IProgress:GetValue();
		QuickSelectBar.UpdateExpUI();
	end
end

function QuickSelectBar.OnClickAccelerateProgress()
	if(QuickSelectBar.IProgress) then
		QuickSelectBar.IProgress:GetEvents():DispatchEvent({type = "OnClickAccelerateProgress" , });
	end
end

function QuickSelectBar.UpdateExpUI()
	local self = QuickSelectBar;
	local cur_value = self.curExp;
	local max_value = self.maxExp;
	cur_value = math.min(cur_value,max_value);
	local _bar = ParaUI.GetUIObject("mc_exp_bar");
	if(_bar:IsValid() == true) then
		local width = self.progress_bar_width;
		width = math.ceil( (cur_value / max_value) * width );
		width = math.max(8,width);
		_bar.width = width;
		_bar.tooltip = format("%d/%d", cur_value, max_value);
	end	
end

function QuickSelectBar.GetExpUICursorPos()
	local self = QuickSelectBar;
	local _bar = ParaUI.GetUIObject("mc_exp_bar");
	if(_bar:IsValid() == true) then
		local width = self.progress_bar_width;
		local cur_value = self.curExp;
		local max_value = self.maxExp;
		width = math.ceil( (cur_value / max_value) * width );
		width = math.max(8,width);
		local x, y  = _bar:GetAbsPosition();
		return x + width, y;
	end	
end

function QuickSelectBar.UpdateHpUI()
	local s = "mc_hp_";
	local self = QuickSelectBar;
	local last_value = self.lastHp;
	local cur_value = self.curHp;
	local max_value = self.maxHp;
	local background;
	local bv,sv,addition;
	if(last_value < cur_value) then
		background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;118 68 18 18"
		bv = cur_value;
		sv = last_value;
		addition = true;
	elseif(last_value > cur_value) then
		background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;158 68 18 18"
		bv = last_value;
		sv = cur_value;
		addition = false;
	end
	local downNum = math.floor(sv) + 1;
	local upNum = math.ceil(bv);
	local i,name;
	for i = downNum, upNum do
		name = s..tostring(i);
		local img = ParaUI.GetUIObject(name);
		if(addition) then
			if(i ~= upNum or upNum == bv  ) then
				img.background = background;
			else
				img.background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;138 68 18 18"
			end
		else
			if(i ~= downNum or (downNum - 1) == sv) then
				img.background = background;
			else
				img.background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;138 68 18 18"
			end
		end		
	end
	self.lastHp = self.curHp;
end

function QuickSelectBar.UpdateHungerUI()
	local s = "mc_hunger_";
	local self = QuickSelectBar;
	local last_value = self.lastHunger;
	local cur_value = self.curHunger;
	local max_value = self.maxHunger;
	local background;
	local bv,sv,addition;
	if(last_value < cur_value) then
		background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;118 45 18 22"
		bv = cur_value;
		sv = last_value;
		addition = true;
	elseif(last_value > cur_value) then
		background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;158 45 18 22"
		bv = last_value;
		sv = cur_value;
		addition = false;
	end
	local downNum = math.floor(sv) + 1;
	local upNum = math.ceil(bv);
	local i,name;
	for i = downNum, upNum do
		name = s..tostring(i);
		local img = ParaUI.GetUIObject(name);
		if(addition) then
			if(i ~= upNum or upNum == bv  ) then
				img.background = background;
			else
				img.background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;138 45 18 22"
			end
		else
			if(i ~= downNum or (downNum - 1) == sv) then
				img.background = background;
			else
				img.background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;138 45 18 22"
			end
		end		
	end
	self.lastHunger = self.curHunger;
end
