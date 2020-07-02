--[[
Title: AuntAngel
Author(s): WangTian
Date: 2009/8/24

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30087_AuntAngel.lua
------------------------------------------------------------
]]

-- create class
local libName = "AuntAngel";
local AuntAngel = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.AuntAngel", AuntAngel);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

-- AuntAngel.main
function AuntAngel.main()
end

-- AuntAngel.main
function AuntAngel.PreDialog()
end

-- do adopt dragon
function AuntAngel.DoAdoptDragon()
	local msg = {};
	paraworld.homeland.petevolved.Fosterage(msg, "AuntAngel.DoAdoptDragon", function(msg)
		log("========== AuntAngel.DoAdoptDragon ==========\n")
		commonlib.echo(msg);
		if(msg.issuccess == true) then
			UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
				if(elapsedTime == 500) then
					-- force update pet info
					MyCompany.Aries.Pet.GetRemoteValue(nil, function()
						System.Item.ItemManager.RefreshMyself();
					end, "access plus 0 day");
					-- force update userinfo
					System.App.profiles.ProfileManager.GetUserInfo(nil,nil,nil, "access plus 0 day");
				end
			end);
		end
	end);
end

-- do retrieve dragon
function AuntAngel.DoRetrieveDragon()
	local ItemManager = System.Item.ItemManager;
	local item = ItemManager.GetMyMountPetItem();
	if(item and item.guid > 0) then
		local msg = {
			petid = item.guid,
		};
		paraworld.homeland.petevolved.RetrieveAdoptedDragon(msg, "AuntAngel.DoRetrieveDragon", function(msg)
			log("========== AuntAngel.DoRetrieveDragon ==========\n")
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
					if(elapsedTime == 500) then
						-- force update pet info
						MyCompany.Aries.Pet.GetRemoteValue(nil, function()
							local ItemManager = System.Item.ItemManager;
							local item = ItemManager.GetMyMountPetItem();
							if(item and item.guid > 0) then
								item:FollowMe(nil, true); -- true for bForceFollow
							end
						end, "access plus 0 day");
						-- force update user bag 12
						System.Item.ItemManager.GetItemsInBag(12, "ForceUpdate_AuntAngel.DoRetrieveDragon", function(msg)
							---- NOTE andy: item system will automatically update all MCML pages with pe:slot tag
							--Map3DSystem.mcml_controls.GetClassByTagName("pe:slot").RefreshContainingPageCtrls();
						end, "access plus 0 day");
						
						-- calculate all obtains
						local obtain_gsid = 17030;
						local _, update;
						local bHaveUpdate = false;
						for _, update in ipairs(msg.updates) do
							bHaveUpdate = true;
							local item = System.Item.ItemManager.GetItemByGUID(update.guid);
							if(item and item.guid > 0) then
								obtain_gsid = item.gsid;
							end
						end
						local _, add;
						local bHaveAdd = false;
						for _, add in ipairs(msg.adds) do
							bHaveAdd = true;
							obtain_gsid = add.gsid;
						end
						
						if(bHaveUpdate or bHaveAdd) then
							local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(obtain_gsid)
							if(gsItem) then
								-- show the item notification
								MyCompany.Aries.Desktop.Dock.OnPurchaseNotification(obtain_gsid, 1);
								-- show the npc dialog style message
								local name = gsItem.template.name;
								MyCompany.Aries.Desktop.TargetArea.ShowDialogStyleMessageBox(30087, nil, string.format([[运气真不错啊，抱抱龙玩儿的时候给你捡到了一个%s，接他回去后要好好照顾他呀。]], name));
							end
							return;
						end
						
						local _, stat;
						local bHaveStat = false;
						for _, stat in pairs(msg.stats) do
							bHaveStat = true;
							if(stat.gsid and stat.cnt) then
								local stat_name = "爱心值";
								-- -3:爱心值；-4:力量值；-5:敏捷值；-6:智慧值
								if(stat.gsid == -3) then
									stat_name = "爱心值";
								elseif(stat.gsid == -4) then
									stat_name = "力量值";
								elseif(stat.gsid == -5) then
									stat_name = "敏捷值";
								elseif(stat.gsid == -6) then
									stat_name = "智慧值";
								end
								if(stat.cnt > 0) then
									MyCompany.Aries.Desktop.TargetArea.ShowDialogStyleMessageBox(30087, nil, string.format([[这段时间抱抱龙过的可好了，吃饱了，洗得香香的，心情倍儿棒，出去玩的时候还提升了%d点%s，回去要好好照顾他啊！]], stat.cnt, stat_name));
								else
									MyCompany.Aries.Desktop.TargetArea.ShowDialogStyleMessageBox(30087, nil, string.format([[喔噢！你没有按时来接你的抱抱龙，他因为思念你，%s降了%d点。不过他还是吃得饱饱的了。]], stat_name, -stat.cnt));
								end
							end
						end
						if(bHaveStat) then
							return;
						end
						
						if(not bHaveUpdate and not bHaveAdd and not bHaveStat) then
							MyCompany.Aries.Desktop.TargetArea.ShowDialogStyleMessageBox(30087, nil, [[好吧好吧，看你和你的抱抱龙这么粘呼，快把他接走吧，他吃饱了洗干净了，心情也很棒。回去要好好照顾他啊。]]);
						end
					end
				end);
			end
		end);
	end
end
