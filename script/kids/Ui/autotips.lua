--[[
Title: autotips
Author(s): LiXizhi
Date: 2007/7/24
Parameters:
------------------------------------------------------------
NPL.load("(gl)script/kids/Ui/autotips.lua");
autotips.Show();
autotips.AddTips("nextaction", "press Ctrl key to sit!", 0);
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
local L = CommonCtrl.Locale("KidsUI");

if(not autotips) then autotips={}; end

-- how many categories to display at a given time. 
autotips.MaxCategories = 1;
autotips.tips = {
	[1] = {name="", text = "", priority=-1},
	[2] = {name="", text = "", priority=-1},
	[3] = {name="", text = "", priority=-1},
}

autotips.predefinedTips = L:GetTable("autotips");

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function autotips.Show(bShow)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("autotips_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		local width, height = 300, 38;
		_this=ParaUI.CreateUIObject("container","autotips_cont", "_lb", 10, -230, width, height);
		_this.background="Texture/whitedot.png";
		_guihelper.SetUIColor(_this, "255 255 255 20")
		_this:AttachToRoot();
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("text", "lable", "_lt", 3, 3, 60, 16)
		_this.text = L"Tips:";
		_this:GetFont("text").color = "100 0 0";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "text", "_lt", 50, 3, width-53, 16)
		--_this:GetFont("text").color = "0 100 0";
		_parent:AddChild(_this);
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
	end	
end

-- destory the control
function autotips.OnDestory()
	ParaUI.Destroy("autotips_cont");
end

-- add a tip to a given category, there can only be one text in any category at a given time. 
-- a tip in a given category is only displayed if it has higher priority than the one in the table
-- @param category: string
-- @param text: string or nil, it will clear whatever in the category.
-- @param priority: number or nil. the larger the higher. loweset is 0.
function autotips.AddTips(category, text, priority)
	if(not category) then
		category = "UI";
	end
	if(not priority) then
		priority = 0;
	end
	local i;
	for i=1, autotips.MaxCategories do
		if(not autotips.tips[i]) then
			break;
		else
			if(autotips.tips[i].name == category) then
				if(not text) then
					autotips.tips[i].text = text;
					autotips.tips[i].priority = -1;
					-- reorder category to the back
					local last = autotips.tips[i];
					local k;
					for k=i, autotips.MaxCategories-1 do
						autotips.tips[k] = autotips.tips[k+1];
						if(k==(autotips.MaxCategories-1)) then
							autotips.tips[k+1] = last;
						end
					end
				elseif(priority >=autotips.tips[i].priority) then
					autotips.tips[i].text = text;
					autotips.tips[i].priority = priority;
					-- reorder category to the front by priority
					local k = i-1;
					while k>=1 do
						if(autotips.tips[k+1].priority > autotips.tips[k].priority) then
							autotips.tips[k], autotips.tips[k+1] = autotips.tips[k+1], autotips.tips[k];
						else
							break;
						end
						k = k-1;
					end
				end
				break;
			elseif(i==autotips.MaxCategories and text~=nil)then
				-- override existing ones whose priority is smaller than the new one. 
				local k = autotips.MaxCategories;
				while k>=1 do
					if(autotips.tips[k].priority <= priority) then
						autotips.tips[k].name= category;
						autotips.tips[k].text = text;
						autotips.tips[k].priority = priority;
						break;
					end
					k = k-1;
				end
				break;
			end
		end
	end
	
	local _this=ParaUI.GetUIObject("autotips_cont");
	if(_this:IsValid()) then
		local displayText="";
		for i=1, autotips.MaxCategories do
			if(not autotips.tips[i]) then
				break;
			else
				if(autotips.tips[i].text~=nil and autotips.tips[i].text~="") then
					displayText = displayText..autotips.tips[i].text.."\n";
				end
			end
		end	
		if(displayText == "") then
			-- automatically pick a predefined tip to display
			if(not autotips.nextTipTime or autotips.nextTipTime<ParaGlobal.GetGameTime()) then
				autotips.nextTipTime = ParaGlobal.GetGameTime()+20000; -- 20 seconds
				if(not autotips.TipIndex) then
					autotips.TipIndex = 1;
				else
					autotips.TipIndex = math.mod(autotips.TipIndex, table.getn(autotips.predefinedTips))+1;
				end
			end
			displayText = autotips.predefinedTips[autotips.TipIndex];
		end
		_this:GetChild("text").text = displayText;
	end
end