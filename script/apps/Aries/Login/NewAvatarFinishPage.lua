--[[
Title: Aries Registration Page
Author(s): LiXizhi
Date: 2009/8/4
Desc:  script/apps/Aries/Login/NewAvatarFinishPage.html
Creating a new avatar, provide nick name, etc, for newly registered users. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/NewAvatarFinishPage.lua");
-------------------------------------------------------
]]
local NewAvatarFinishPage = commonlib.gettable("MyCompany.Aries.NewAvatarFinishPage")

---------------------------------
-- page event handlers
---------------------------------
-- singleton page
local page;
local MainLogin = commonlib.gettable("MyCompany.Aries.MainLogin");

-- init
function NewAvatarFinishPage.OnInit()
	page = document:GetPageCtrl();
	local player = ParaScene.GetPlayer();
	local x,y,z = player:GetPosition();
	local facing = player:GetFacing();
	NewAvatarFinishPage.asset_table.facing = facing;
	NewAvatarFinishPage.asset_table_orange.facing = facing;
	NewAvatarFinishPage.asset_table_green.facing = facing;
	NewAvatarFinishPage.asset_table_purple.facing = facing;

	local node = page:GetNode("userCanvas");
	if(node) then
		node:SetAttribute("ExternalOffsetX", x);
		node:SetAttribute("ExternalOffsetY", y);
		node:SetAttribute("ExternalOffsetZ", z + 1.2);
		
		node:SetAttribute("DefaultRotY", facing + 3.14);
		local i
		for i = 1, 3 do
			local node = page:GetNode("eggCanvas"..tostring(i));
			if(node) then
				node:SetAttribute("ExternalOffsetX", x);
				node:SetAttribute("ExternalOffsetY", y);
				node:SetAttribute("ExternalOffsetZ", z);
				node:SetAttribute("DefaultRotY", facing + 3.14);
			end
		end
	end

	UIAnimManager.PlayCustomAnimation(50, function(elapsedTime)
		if(elapsedTime == 50) then
			page:SetValue("ColorSelect", "1");
			local node = page:GetNode("selected_btn");
			node:SetAttribute("enabled", "true");
			NewAvatarFinishPage.OnSelectDragon("purple");
		end
	end);
end

function NewAvatarFinishPage.OnInitTeen()
	page = document:GetPageCtrl();
end

-- @param color: "purple" | "green" | "orange"
function NewAvatarFinishPage.ContinueGetDragon(color)
	NewAvatarFinishPage.Choice = color;
	page:Refresh(0.1);
end

-- select dragon
-- @param color: "purple" | "green" | "orange"
function NewAvatarFinishPage.OnSelectDragon(color)
	NewAvatarFinishPage.ContinueGetDragon(color);
	
	-- send log information
	paraworld.PostLog({action = "onselectdragon_click", color = tostring(color)}, "onselectdragon_click_log", function(msg)
	end);
end

function NewAvatarFinishPage.OnConfirm()
	--local color = NewAvatarFinishPage.Choice;
	--local ItemManager = System.Item.ItemManager;
	--ItemManager.PurchaseItem(10001, 1, function(msg)
		--if(msg) then
			--log("NOTE: free 2000 emoney is already collected in new user register together with 6 homeland items\n");
			--log("+++++++Purchase dragon after select "..color.." return: +++++++\n")
			--commonlib.echo(msg);
			--if(msg.issuccess == true) then
				---- send log information
				---- NOTE: remember to post the log for other two colors of dragon
				--paraworld.PostLog({action = "get_dragon_success"}, "get_dragon_success_log", function(msg)
				--end);
				----NewAvatarFinishPage.Choice = color;
				--NewAvatarFinishPage.bConfirmed = true;
				--page:Refresh(0.1);
			--end
		--end
	--end, function(msg) end, "sophie", "none", false);
	
	-- NOTE: free 2000 emoney is already collected in new user register together with 6 homeland items
	local color = NewAvatarFinishPage.Choice;
	local ItemManager = System.Item.ItemManager;
	local gsid;
	local gsid_key;
	if(color == "purple") then
		gsid = 11009;
		gsid_key = "11009_DragonBaseColor_Purple";
	elseif(color == "orange") then
		gsid = 11010;
		gsid_key = "11010_DragonBaseColor_Orange";
	elseif(color == "green") then
		gsid = 11011;
		gsid_key = "11011_DragonBaseColor_Green";
	end
	ItemManager.PurchaseItem(gsid, 1, function(msg)
		if(msg) then
			log("+++++++Purchase "..gsid_key.." return: +++++++\n")
			commonlib.echo(msg);
			-- 424: 购买数量超过限制 
			if(msg.issuccess == true or msg.errorcode == 424) then
				-- send log information
				-- NOTE: remember to post the log for other two colors of dragon
				paraworld.PostLog({action = "get_dragon_success"}, "get_dragon_success_log", function(msg)
				end);
				--NewAvatarFinishPage.Choice = color;
				NewAvatarFinishPage.bConfirmed = true;
				page:Refresh(0.1);
			end
		end
	end, function(msg) end, nil, "none", false);
end

function NewAvatarFinishPage.OnPrev()
	--page:CloseWindow();
	--
	---- proceed to next step. 
	--System.App.Commands.Call("File.MCMLWindowFrame", {
		--url = "script/apps/Aries/Login/NewAvatarDisplayPage.html", 
		--name = "NewAvatarDisplayPage", 
		--isShowTitleBar = false,
		--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		--style = CommonCtrl.WindowFrame.ContainerStyle,
		--zorder = 2,
		--allowDrag = false,
		--directPosition = true,
			--align = "_ct",
				--x = -640/2,
				--y = -430/2,
				--width = 640,
				--height = 430,
		--cancelShowAnimation = true,
	--});
end
	
function NewAvatarFinishPage.OnNext()
	page:CloseWindow();
	
	-- send log information
	paraworld.PostLog({action = "enter_community_success"}, "enter_community_success_log", function(msg)
	end);
	
	-- proceed to login page. 
	MainLogin:next_step({IsAvatarCreationRequested = false});
end	