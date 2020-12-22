--[[
Title: class npc
Author(s): chenjinxian
Date: 2020/12/16
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ParaWorld/GeneralNPC.lua");
local GeneralNPC = commonlib.gettable("MyCompany.Aries.Game.Tasks.ParaWorld.GeneralNPC");
local npc = GeneralNPC:new():Init();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Entity/EntityNPC.lua");
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/keepwork.rawfile.lua");
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/keepwork.npc.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ParaWorld/ParaWorldLoginAdapter.lua");
local ParaWorldLoginAdapter = commonlib.gettable("MyCompany.Aries.Game.Tasks.ParaWorld.ParaWorldLoginAdapter");
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local EntityNPC = commonlib.gettable("MyCompany.Aries.Game.EntityManager.EntityNPC");
local KeepWorkItemManager = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkItemManager.lua");
local GeneralNPC = commonlib.inherit(nil, commonlib.gettable("MyCompany.Aries.Game.Tasks.ParaWorld.GeneralNPC"));
local ActRedhat = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ActRedhat/ActRedhat.lua")

function GeneralNPC:ctor()
end

function GeneralNPC:Init(npcName, npcModel, _x, _y, _z)
	local x, y, z = BlockEngine:ConvertToRealPosition_float(_x, _y, _z);
	local entity = EntityManager.EntityNPC:Create({x=x,y=y,z=z, item_id = block_types.names["villager"]});
	local assetfile = EntityManager.PlayerAssetFile:GetValidAssetByString(npcModel);
	entity:SetPersistent(false);
	entity:SetServerEntity(false);
	entity:SetCanRandomMove(false);
	entity:EnablePhysics(false);
	entity.bContinueMoveOnCollision = false;
	entity:SetMainAssetPath(assetfile);
	entity:Attach();
	local headon_mcml = string.format(
		[[<pe:mcml><div style="margin-left:-100px;margin-top:-60px;width:200px;height:20px;">
			<div style="margin-top:20px;width:200px;height:20px;text-align:center;font-size:15px;base-font-size:15;font-weight:bold;shadow-quality:8;color:%s;shadow-color:#8000468e;text-shadow:true">%s</div>
		</div></pe:mcml>]],
		"#fcf73c", npcName);
	entity:SetHeadOnDisplay({url=ParaXML.LuaXML_ParseString(headon_mcml)})
	--[[
	entity.OnClick = function(entity, x, y, z, mouse_button)
		_guihelper.MessageBox(L"找到了一顶帽子~");
		entity:Destroy();
		return true;
	end
	]]
	
	self.entity = entity;
	return self;
end

function GeneralNPC:SetClickFunction(func)
	if (self.entity) then
		self.entity.OnClick = function(entity, x, y, z, mouse_button)
			entity:Destroy();
			if (func) then
				func();
			end
			return true;
		end
	end
end

function GeneralNPC:DestroyNPC()
	if (self.entity) then
		self.entity:Destroy();
	end
end

function GeneralNPC.ShowChristmasHatNPC(christmas_timer)
	local positions = {};
	local projectId = GameLogic.options:GetProjectId();
	if (projectId == tostring(ParaWorldLoginAdapter.GetDefaultWorldID())) then
		positions = {
			{19197,11,19150},
			{19154,11,19131},
			{19190,11,19088},
			{19119,13,19086},
			{19093,29,19095},
			{19201,28,19117},
			{19250,30,19095},
			{19276,35,19103},
			{19249,42,19094},
			{19264,13,19161},
			{19271,33,19171},
			{19289,57,19172},
			{19315,69,19154},
			{19305,12,19167},
			{19222,12,19232},
			{19238,25,19226},
			{19227,31,19222},
			{19222,38,19247},
			{19235,42,19219},
			{19226,50,19248},
			{19245,56,19243},
			{19241,63,19223},
			{19266,41,19236},
			{19233,41,19265},
			{19210,32,19275},
			{19233,22,19280},
			{19214,21,19297},
			{19280,64,19293},
			{19224,83,19261},
			{19150,38,19281},
			{19127,69,19262},
			{19136,93,19261},
			{19088,12,19303},
			{19125,30,19191},
			{19094,30,19150},
			{19098,70,19128},
			{19320,12,19116},
			{19253,13,19311},
			{19092,20,19246},
			{19101,30,19154},
		};
	elseif (projectId == "23501") then
		positions = {
			{19214,47,19185},
			{19204,11,19273},
			{19278,13,19252},
			{19116,23,19250},
			{19291,12,19107},
			{19210,29,19161},
			{19170,11,19112},
			{19177,14,19169},
			{19152,15,19185},
			{19177,14,19183},
			{19122,14,19223},
			{19182,15,19243},
			{19199,24,19185},
			{19186,24,19213},
			{19209,34,19185},
			{19271,14,19226},
			{19220,14,19236},
			{19137,11,19159},
			{19159,15,19153},
			{19101,11,19089},
			{19256,12,19137},
			{19254,12,19297},
			{19128,11,19289},
			{19209,25,19106},
			{19230,43,19234},
		}
	elseif (projectId == "23540") then
		positions = {
			{19108,11,19308},
			{19265,11,19271},
			{19234,17,19255},
			{19206,18,19299},
			{19213,35,19246},
			{19204,44,19253},
			{19213,24,19203},
			{19193,11,19126},
			{19281,11,19144},
			{19267,11,19164},
			{19272,12,19215},
			{19281,17,19271},
			{19265,22,19243},
			{19211,48,19258},
			{19250,47,19179},
			{19208,41,19178},
			{19224,41,19176},
			{19276,41,19185},
			{19261,42,19202},
			{19250,18,19182},
			{19204,26,19196},
			{19199,24,19172},
			{19192,29,19141},
			{19247,29,19233},
			{19215,32,19260},
		}
	end

	if (GameLogic.GetFilters():apply_filters('is_signed_in')) then
		local len = #positions;
		local frequency = 5;
		local interval = len / frequency;
		if (interval > 0) then
			local exid = 30000;
			local gsid = 90000;
			local npcList = {};
			local key = "Christmas_Hat_Time";
			local bOwn,guid,bagid,copies = KeepWorkItemManager.HasGSItem(gsid);
			if (copies and copies > 200) then
				return;
			end

			local clientData = KeepWorkItemManager.GetClientData(gsid) or {};
			function createNPC(interval)
				for i = 1, #npcList do
					npcList[i]:DestroyNPC();
				end
				for i = 1, interval do
					local index = math.random((i-1)*frequency+1, i*frequency);
					local x, y, z = positions[index][1], positions[index][2], positions[index][3]
					local npc = GeneralNPC:new():Init("驯鹿", "character/v3/Elf/Female/ElfFemale.xml", x, y+1, z);
					npc:SetClickFunction(function()
						KeepWorkItemManager.DoExtendedCost(exid, function()
							--_guihelper.MessageBox(L"获得了一顶帽子~");
							ActRedhat.ShowPage()
							if (not bOwn) then
								clientData[key] = os.time();
								KeepWorkItemManager.SetClientData(gsid, clientData);
							end
							bOwn,guid,bagid,copies = KeepWorkItemManager.HasGSItem(gsid);
							if (copies and copies == 200) then
								for i = 1, #npcList do
									npcList[i]:DestroyNPC();
								end
							end
						end);
					end);
					npcList[#npcList + 1] = npc;
				end

				clientData[key] = os.time();
				KeepWorkItemManager.SetClientData(gsid, clientData);
			end

			christmas_timer = christmas_timer or commonlib.Timer:new({callbackFunc = function(timer)
				createNPC(interval);
			end});

			local frequencyTime = 60 * 10;
			local lastTime = clientData[key] or 0;
			local currentTime = os.time();
			if (currentTime - lastTime > frequencyTime) then
				christmas_timer:Change(1000, frequencyTime * 1000);
			else
				christmas_timer:Change(1000 * (frequencyTime - (currentTime - lastTime)), frequencyTime * 1000);
			end
			return christmas_timer;
		end
	end
end
