--[[
Title: code behind for page 30096_ExiledPanda_list_panel.html
Author(s): LiXizhi
Date: 2010/1/4
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Playground/30096_ExiledPanda_list_panel.lua");
-- call this function to send the panda to the recollect zone. 
MyCompany.Aries.Quest.NPCs.ExiledPanda_list_panel.ExilePet();
-------------------------------------------------------
]]
local ExiledPanda_list_panel = commonlib.gettable("MyCompany.Aries.Quest.NPCs.ExiledPanda_list_panel");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;

local page;
local game_name = "100_ExiledPandas";
-- gsid of the panda
local pet_gsid = 10114;

function ExiledPanda_list_panel.OnInit()
	page = document:GetPageCtrl();
	ExiledPanda_list_panel.GetRank();
end

function ExiledPanda_list_panel.DS_Func(index)
	local self = ExiledPanda_list_panel;
	if(not self.ranks)then return nil end
	if(index == nil) then
		return #(self.ranks);
	else
		return self.ranks[index];
	end
end

function ExiledPanda_list_panel.GetRank()
	local self = ExiledPanda_list_panel;

	if(self.IsRankFetched) then
		return
	else
		self.IsRankFetched = true;
	end
	local msg = {
		gamename = game_name,
	}
	paraworld.minigame.GetRank(msg,"minigame",function(msg)	
		if(msg and msg.ranks)then
			self.ranks = msg.ranks;
			if(page)then
				page:Refresh();
			end
		end
	end);
end

-- send the panda to exile recollect zone. 
function ExiledPanda_list_panel.ExilePet()
	-- submit to newly adopted panda list. {score = nid}
	local msg = {
		gamename = game_name,
		-- use global time as score. 
		score = ParaGlobal.timeGetTime(),
	}
	commonlib.echo("begin send minigame score:");
	commonlib.echo(msg);
	paraworld.minigame.SubmitRank(msg,"minigame",function(msg)	
		commonlib.echo("after send minigame score:");
		commonlib.echo(msg);
	end);
end

-- add record to the beginning of the list
function ExiledPanda_list_panel.AddRecord(nid)
	if(not self.ranks)then return nil end
	
	local this_index;
	local index, rank;
	for index, rank in ipairs(self.ranks) do 
		if(rank.nid == nid) then
			this_index = index;
			break;
		end
	end
	if(not this_index) then
		-- insert to the begining of the list. 
		commonlib.insertArrayItem(self.ranks, 1, {nid = nid, score=0})
	else
		-- move to the beginning of the list. 
		commonlib.moveArrayItem(self.ranks, 1, this_index)
	end
	
	if(page)then
		page:Refresh();
	end
end


-- remove record from the list
function ExiledPanda_list_panel.RemoveRecord(nid)
	if(not self.ranks)then return nil end
	
	local this_index;
	local index, rank;
	for index, rank in ipairs(self.ranks) do 
		if(rank.nid == nid) then
			this_index = index;
			break;
		end
	end
	if(this_index) then
		commonlib.removeArrayItem(self.ranks, this_index)
		if(page)then
			page:Refresh();
		end
	end
end

-- show user info panel
function ExiledPanda_list_panel.ShowInfo(nid)
	if(not nid or nid == "")then return end
	System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = nid});
end

-- search for a given user
function ExiledPanda_list_panel.SearchPetOwner()
	NPL.load("(gl)script/apps/Aries/Dialog/EnterUserIDPage.lua");
	MyCompany.Aries.Dialogs.EnterUserIDPage.Show(function(result, nid)
		if(result == "ok") then
			-- whether the current user has panda
			local user_has_panda = hasGSItem(pet_gsid);
			if(user_has_panda) then
				_guihelper.MessageBox("你家中已经有熊猫啦，不能再领养了哦！")
			else
				-- verify the client data of  nid's panda, to see if it is exiled. 
				local has_panda = ItemManager.IfOPCOwnGSItem(nid, pet_gsid);
				-- TODO: determine if nid has exiled a panda. 
				local exiled = true;
				if(has_panda and exiled) then
					-- add record to the beginning of the list. 
					ExiledPanda_list_panel.AddRecord(nid);
				else
					_guihelper.MessageBox("这个哈奇没有丢失熊猫哦！")
				end
			end
		end
	end)
end

-- search for a given user
function ExiledPanda_list_panel.AdoptPet(nid)
	if(ExiledPanda_list_panel.submitting) then return end
	
	-- whether the current user has panda
	local user_has_panda = hasGSItem(pet_gsid);
	if(user_has_panda) then
		_guihelper.MessageBox("你家中已经有熊猫啦，不能再领养了哦！")
	else
		-- adopt the panda of nid. 
		_guihelper.MessageBox("恭喜你成功领养了一只熊猫，记得在仓库里多准备好竹子，每天给熊猫梳理毛发，好好照顾它哦！")
		ExiledPanda_list_panel.submitting = true;
		
		ItemManager.PurchaseItem(pet_gsid, 1, function(msg)
			end,
			function(msg) 
				ExiledPanda_list_panel.submitting = false;
				if(msg) then
					if(msg.issuccess) then
						-- remove panda from list
						ExiledPanda_list_panel.RemoveRecord(nid);
						
						-- submit to newly adopted panda list. {score = nid}
						local msg = {
							gamename = "100_AdoptedPandas",
							--score = user_score,
							score = tonumber(nid),
						}
						commonlib.echo("begin send minigame score:");
						commonlib.echo(msg);
						paraworld.minigame.SubmitRank(msg,"minigame",function(msg)	
							commonlib.echo("after send minigame score:");
							commonlib.echo(msg);
						end);
					end
				end
			end);
	end
end