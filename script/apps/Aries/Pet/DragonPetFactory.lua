--[[
Title: DragonPetFactory
Author(s): Leio
Date: 2009/10/23
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Pet/DragonPetFactory.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Pet/DragonPet_New.lua");
NPL.load("(gl)script/apps/Aries/Pet/main.lua");
local DragonPetFactory = commonlib.gettable("MyCompany.Aries.Pet.DragonPetFactory");
function DragonPetFactory.GetInstance(nid,callbackFunc,cache_policy)
	if(System.options.mc) then
		return;
	end
	if(not nid)then
		nid = Map3DSystem.App.profiles.ProfileManager.GetNID();
	end
	if(not cache_policy)then
		cache_policy = "access plus 30 seconds";
	end
	local ItemManager = Map3DSystem.Item.ItemManager;
	if(nid == Map3DSystem.App.profiles.ProfileManager.GetNID())then
		--�Լ�������
		ItemManager.GetItemsInBag(0, "DragonPetFactory_GetItemsInBag"..(nid or 0), function(msg)
			--��ȡ����item������
			local pet_item = ItemManager.GetMyMountPetItem(nid);
			local s = string.format("================get dragon pet item in DragonPetFactory:%s",tostring(nid));
			commonlib.echo(s);
			local pet_dragon;
			if(pet_item)then
				local petid = pet_item.guid;
				pet_dragon = MyCompany.Aries.Pet.DragonPet_New:new{
					nid = nid,
					petid = petid,
				}
				pet_dragon:GetRemoteValue(function(msg)
					
					--ƥ�������״̬
					local now_state = pet_item:WhereAmI();
					local state;
					if(now_state == "mount") then
						state = "ride";
					elseif(now_state == "home") then
						state = "home";
					elseif(now_state == "follow") then
						state = "follow";
					else
						state = "home";
					end
		
					pet_dragon:ChangeState(state);
					pet_dragon:InitPetState();
					--�����Զ�˵�����Զ�����Զ�̳ɳ�����
					pet_dragon:StartMonitor();
					if(callbackFunc and type(callbackFunc) == "function")then
						local msg = {
							pet_dragon = pet_dragon,
							pet_item = pet_item,
						}
						callbackFunc(msg);
					end
				end, cache_policy);
			end
		end,cache_policy)
	else
		ItemManager.GetItemsInOPCBag(nid, 0, "DragonPetFactory_GetItemsInOPCBag"..nid, function(msg)
			--��ȡ����item������
			local pet_item = ItemManager.GetOPCMountPetItem(nid);
			local s = string.format("================get dragon pet item in DragonPetFactory:%s",tostring(nid));
			commonlib.echo(s);
			local pet_dragon;
			if(pet_item)then
				local petid = pet_item.guid;
				pet_dragon = MyCompany.Aries.Pet.DragonPet_New:new{
					nid = nid,
					petid = petid,
				}
				pet_dragon:GetRemoteValue(function(msg)
					--��Ϊ�������˵�������в���������������ڼ�״̬������ֱ������Ϊhome״̬
					pet_dragon:ChangeState("home");
					pet_dragon:InitPetState();
					
					if(callbackFunc and type(callbackFunc) == "function")then
						local msg = {
							pet_dragon = pet_dragon,
							pet_item = pet_item,
						}
						callbackFunc(msg);
					end
				end, cache_policy);
			else
				-- NOTE 2009/11/13: also call the callback function if the mount pet is not fetched from sophie
				if(callbackFunc and type(callbackFunc) == "function")then
					-- no message is proceed
					callbackFunc();
				end
			end
		end,cache_policy);
	end
end
