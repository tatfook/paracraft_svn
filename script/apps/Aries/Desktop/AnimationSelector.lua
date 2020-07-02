--[[
Title: code behind for page AnimationSelector.html
Author(s): WangTian
Date: 2009/5/4
Desc:  script/apps/Aries/Desktop/AnimationSelector.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local AnimationSelectorPage = commonlib.gettable("MyCompany.Aries.Desktop.AnimationSelectorPage");
local ItemManager = commonlib.gettable("System.Item.ItemManager");

local anims = {
	[1] = { icon = "Texture/face/14.png",
			tooltip = "出拳",
			animfile = "character/Animation/v3/Punching.x",
	},
	[2] = { icon = "Texture/face/15.png",
			tooltip = "哭泣",
			animfile = "character/Animation/v3/Crying.x",
	},
	[3] = { icon = "Texture/face/16.png",
			tooltip = "俯卧撑",
			animfile = "character/Animation/v3/PushUps.x",
	},
	[4] = { icon = "Texture/face/18.png",
			tooltip = "讨论",
			animfile = "character/Animation/v3/Discussion.x",
	},
	[5] = { icon = "Texture/face/19.png",
			tooltip = "飞吻",
			animfile = "character/Animation/v3/Kiss.x",
	},
	[6] = { icon = "Texture/face/20.png",
			tooltip = "不可一世",
			animfile = "character/Animation/v3/InsufferablyArrogant.x",
	},
	[7] = { icon = "Texture/face/21.png",
			tooltip = "垂头丧气",
			animfile = "character/Animation/v3/DisappointmentShakingHisHead.x",
	},
	
	
	[8] = { icon = "Texture/face/01.png",
			tooltip = "跳舞一",
			animfile = "character/Animation/v3/Dance1.x",
	},
	[9] = { icon = "Texture/face/02.png",
			tooltip = "跳舞二",
			animfile = "character/Animation/v3/Dance2.x",
	},
	[10] = { icon = "Texture/face/03.png",
			tooltip = "弹钢琴",
			animfile = "character/Animation/v3/PlayingThePiano.x",
	},
	[11] = { icon = "Texture/face/24.png",
			tooltip = "睡觉",
			animfile = "character/Animation/v3/Sleep.x",
	},
	
	
	[12] = { icon = "Texture/face/05.png",
			tooltip = "紧张",
			animfile = "character/Animation/v3/Tension.x",
	},
	[13] = { icon = "Texture/face/06.png",
			tooltip = "欢呼",
			animfile = "character/Animation/v3/Cheers.x",
	},
	[14] = { icon = "Texture/face/07.png",
			tooltip = "很兴奋的点头",
			animfile = "character/Animation/v3/ExcitedAboutTheNod.x",
	},
	[15] = { icon = "Texture/face/08.png",
			tooltip = "欢迎",
			animfile = "character/Animation/v3/Welcome.x",
	},
	[16] = { icon = "Texture/face/09.png",
			tooltip = "再见",
			animfile = "character/Animation/v3/Goodbye.x",
	},
};

-- data source for head slot items
function AnimationSelectorPage.DS_Func_Animations(dsTable, index, pageCtrl)
    if(not dsTable.status) then
        -- use a default cache
        AnimationSelectorPage.GetItems(dsTable, pageCtrl, "access plus 5 minutes");
    elseif(dsTable.status == 2) then    
        if(index == nil) then
			return dsTable.Count;
        else
			return dsTable[index];
        end
    end
end

function AnimationSelectorPage.GetItems(output, pageCtrl, cache_policy)
	-- fetching inventory items
	output.status = 1;
	ItemManager.GetItemsInBag(91, "ariesanimation", function(msg)
		if(msg and msg.items) then
			local count = ItemManager.GetItemCountInBag(bag);
			if(count == 0) then
				count = 1;
			end
			-- fill the 21 tiles per page
			count = math.ceil(count/15) * 15;
			local i;
			for i = 1, count do
				local item = ItemManager.GetItemByBagAndOrder(91, i);
				if(item ~= nil) then
					local tooltip = "";
					if(type(item.GetTooltip) == "function") then
						tooltip = item:GetTooltip();
					end
					output[i] = {guid = item.guid, tooltip = tooltip};
				else
					output[i] = {guid = 0, tooltip = ""};
				end
			end
			output.Count = count;
			commonlib.resize(output, output.Count);
			-- fetched inventory items
			output.status = 2;
			pageCtrl:Refresh();
		else
			output.Count = 0;
			commonlib.resize(output, output.Count);
			-- fetched inventory items
			output.status = 2;
			pageCtrl:Refresh();
		end
	end, cache_policy);
end

local must_have_gsid = {
	[15001] = true,
	[15002] = true,
}
-- whether we can play a given gsid animation. 
function AnimationSelectorPage.CanPlay(gsid)

	if(System.options.version == "kids") then
		local Player = MyCompany.Aries.Player;
		-- transformed gsid
		local asset_gsid = Player.asset_gsid;
		if(asset_gsid == 10226) then
			return false;
		end
	end

	local bHas = ItemManager.IfOwnGSItem(gsid);
	if(must_have_gsid[gsid] and not bHas ) then
		return false;
	elseif(not bHas) then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem and gsItem.template.stats[180] and not MyCompany.Aries.VIP.IsVIPAndActivated()) then
			return false;
		end
	end
	return true;
end

function AnimationSelectorPage.PlayAnim(gsid)
	-- log("TODO: distinguish character animation and animation that played if user in mounted on pet\n")
	if(gsid) then
		if(not AnimationSelectorPage.CanPlay(gsid)) then
			_guihelper.MessageBox("需要激活魔法星才能使用这个动作");
			return;
		end

		if(System.options.version == "teen" and MyCompany.Aries.Player.IsMounted()) then
			_guihelper.MessageBox("请先从坐骑上下来， 才能做这个动作");
			return;
		end

		MyCompany.Aries.Player.PlayAnimationFromValue(nil, gsid);
		local x, y, z = MyCompany.Aries.Player.GetPlayer():GetPosition();
		local anim_value = string.format("%s:%f %f %f", gsid, x, y, z);
		-- broadcast to all clients
		Map3DSystem.GSL_client:AddRealtimeMessage({name="anim", value=anim_value});
		
		-- call hook for OnPlayCharAnim
		local hook_msg = { aries_type = "OnPlayCharAnim", gsid = gsid, wndName = "main"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
	end
end

-- play animation with item guid
function AnimationSelectorPage.OnClick(guid)
	if(guid) then
		local ItemManager = System.Item.ItemManager;
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			item:OnClick(mouse_button);
		end
	end
	MyCompany.Aries.Desktop.Dock.OnClickAction(false);
end

local all_anim_list_kids = {
	{
		{gsid=9001, }, 
		{gsid=9002, }, 
		{gsid=9003, }, 
		{gsid=9004, }, 
		{gsid=9005, }, 
		{gsid=9006, }, 
		{gsid=9007, }, 
		{gsid=9008, }, 
		{gsid=9009, }, 
		{gsid=9010, }, 
		{gsid=9011, }, 
		{gsid=9012, }, 
		{gsid=9013, }, 
		{gsid=9014, }, 
		{gsid=9015, }, 
		{gsid=9016, }, 
		{gsid=9017, }, 
		{gsid=9018, }, 
		{gsid=9019, },
		{gsid=9020, },
		{gsid=9021, },
		{gsid=15001, }, 
		{gsid=15002, }, 
	},
}

function AnimationSelectorPage.initAnimList()
	AnimationSelectorPage.animList = AnimationSelectorPage.animList or all_anim_list_kids;
	local Player = commonlib.gettable("MyCompany.Aries.Player");
	if(Player.asset_gsid and Player.asset_gsid == 10225) then
		if(not AnimationSelectorPage.animList[Player.asset_gsid]) then
			AnimationSelectorPage.animList[Player.asset_gsid] = commonlib.copy(AnimationSelectorPage.animList[1]);
			local newAnim = {gsid = 9022,};
			table.insert(AnimationSelectorPage.animList[Player.asset_gsid],newAnim);
		end
		AnimationSelectorPage.all_anim_kids_ds = AnimationSelectorPage.animList[Player.asset_gsid];	
	else
		AnimationSelectorPage.all_anim_kids_ds = AnimationSelectorPage.animList[1];
	end
end