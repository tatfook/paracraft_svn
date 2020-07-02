--[[
Title: HomeLandConfig
Author(s): Leio
Date: 2009/4/8
Desc: ��԰�����������Ϣ
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
Map3DSystem.App.HomeLand.HomeLandConfig.Load();
------------------------------------------------------------
]]
local HomeLandConfig = {
	defaultPath = "config/Aries/Others/PetMsgHomeLandConfig.xml",
	loaded = false,
	
	StartPoint = {x = 0, y = 0, z = 0},--��԰���Χ�Ŀ�ʼ��
	EndPoint = {x = 500, y = 0, z = 500},--��԰���Χ�Ľ�����
	DefaultWorld = "worlds/MyWorlds/0920_homeland",--Ĭ�ϵļ�԰����
	DefaultBornPlace = {x = 19959.169921875, y = 30, z = 20273.046875},--Ĭ�ϵļ�԰������
	OutdoorOrigin = {x = 0, y = 0, z = 0},--�������ʼ����
	IndoorOrigin = {x = 19963, y = 50000, z = 20304},-- ���ڵ���ʼ���꣬ͬ��Ҳ������ģ�͵İڷ�λ��
	MonitorBox = {x = 2, y = 2, z = 2}, --�������ӵĴ�С
	GridBox = {x = 2, y = 2, z = 2}, --����ÿһ�����ӵĴ�С
	EntryTipStyle = "model/07effect/v5/Firecracker/Firecracker1.x", -- ������ѵ���ʽ
	ExitTipStyle = "model/07effect/v5/WaterBalloon/WaterBalloon1.x", --�������ѵ���ʽ-
	EntryMonitorInterval = 3000, --������ڼ��������ڣ�����
	HomeNameMax = 24,-- ��԰��������ַ���
	GiftMsgMax = 150,--���������������
	
	Throwball_Duration = "00:00:01",--Ͷ����������е�ʱ��
	Throwball_Movement_Duration = "00:00:00.5",---Ͷ���������ų�����ʱ��
	Throwball_Effect_Duration = "00:00:01",---���к���ʾЧ����ʱ��
	Throwball_Movement_AnimationFile = "character/Animation/v5/Throw.x",---����Ķ���
	Throwball_Movement_Mount_AnimationFile_1 = "character/Animation/v5/ThrowDragonMinor.x",---С����������������Ķ���
	Throwball_Movement_Mount_AnimationFile_2 = "character/Animation/v5/ThrowDragonMajor.x",---������������������Ķ���
	Throwball_MaxDis = 60,---��Զ���
	Throwball_OnHit_MinVolume = 0.2,--�����е���С���
	Throwball_G = 0.05,--�������ٶ�
	Throwball_OnHit_FindRadius = 0.2,--���Ұ뾶
	
	Bag_Gift = 20001,--�����bag��
	Bag_Fruit = 12,--��ʵ��bag��
	
	View_ShowSelectedTip = "true",-- �����״̬�µ�����壬�Ƿ���ʾѡ��
	Panel_ShowPos = {align = "_lt", left = 5,top = 85,width = 128,height = 512  },--�������������ʾ��λ��
	Panel_ShowPos_AwayBtn = {align = "_lb", left = 10,top = -80,width = 70,height = 80 },--�뿪��ť
	Panel_ShowPos_ItemLibs = {align = "_ctb", left = -10,top = 0,width = 702,height = 123 },--��԰�ֿ��б�
}
commonlib.setfield("Map3DSystem.App.HomeLand.HomeLandConfig",HomeLandConfig);
function HomeLandConfig.Load()
	--local self = HomeLandConfig;
	--if(not self.loaded)then
		--local xmlRoot = ParaXML.LuaXML_ParseFile(self.defaultPath);
		--if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
			--xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
			--NPL.load("(gl)script/ide/XPath.lua");	
			--for rootNode in commonlib.XPath.eachNode(xmlRoot, "//Const") do
				--if(rootNode) then
					--local child;
					--for child in rootNode:next() do
						--local name = child.name;
						--local value = child[1];
						--if(value)then
							--if(string.find(value,"{.+}"))then
								--self[name] = commonlib.LoadTableFromString(value)
							--else
								--if(tonumber(value))then
									--self[name] = tonumber(value);
								--elseif(tostring(value))then
									--self[name] = tostring(value);
								--end
							--end
						--end
					--end	
				--end
			--end
			--self.loaded = true;
		--end
	--end
end
--[[
--����ֵ
		["CherryTree"] = {
			assets_normal = {
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage0.x",
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage1.x",
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage2.x",
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage3.x",
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage4.x",
			},
			assets_drought = {
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage0_Withered.x",
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage1_Withered.x",
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage2_Withered.x",
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage3_Withered.x",
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage4_Withered.x",
			},
			assets_bug = {
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage0_Bug.x",
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage1_Bug.x",
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage2_Bug.x",
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage3_Bug.x",
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage4_Bug.x",
			},
			assets_drought_bug = {
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage0_Withered_Bug.x",
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage1_Withered_Bug.x",
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage2_Withered_Bug.x",
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage3_Withered_Bug.x",
			"model/05plants/v5/01tree/CherryTree/CherryTreeStage4_Withered_Bug.x",
			},
			anim = {
				water = "model/05plants/v5/01tree/CherryTree/CherryTree_water.x",
				debug = "model/05plants/v5/01tree/CherryTree/CherryTree_debug.x",
				delete = "model/05plants/v5/01tree/CherryTree/CherryTree_delete.x",
			},
		},
--ӣ��
s = {stage=5,title="model/05plants/v5/01tree/CherryTree/CherryTree"}
--����
s = {stage=5,title="model/05plants/v5/01tree/PineAppleTree/PineAppleTree"}
--]]

HomeLandConfig.ParsePlantEPool = {};
function HomeLandConfig.ParsePlantE(s)
	if(HomeLandConfig.ParsePlantEPool[s])then
		return HomeLandConfig.ParsePlantEPool[s]
	end
	local t = commonlib.LoadTableFromString(s);
	if(t)then
		local Normal = "Stage";
	
		local assets_normal = {};
		local assets_drought = {};
		local assets_bug = {};
		local assets_drought_bug = {};
		
		--�ܹ����ٸ��׶�
		local level_total = t["stage"] or 0;
		local title = t["title"] or "";
		local i;
		for i = 1,level_total do
			local k = i-1;
			local s_Normal;
			local s_Drought;
			local s_Bug ;
			local s_Drought_Bug;
			s_Normal = string.format("%s%s%d.x",title,Normal,k);
			s_Drought = string.format("%s%s%d_Withered.x",title,Normal,k);
			s_Bug = string.format("%s%s%d_Bug.x",title,Normal,k);
			s_Drought_Bug = string.format("%s%s%d_Withered_Bug.x",title,Normal,k);
			
			assets_normal[i] = s_Normal;
			assets_drought[i] = s_Drought;
			assets_bug[i] = s_Bug;
			assets_drought_bug[i] = s_Drought_Bug;
		end
		local anim = {
			water = title.."_water.x",
			debug = title.."_debug.x",
			delete = title.."_delete.x",
		};
		
		local result = {
			assets_normal = assets_normal,
			assets_drought = assets_drought,
			assets_bug = assets_bug,
			assets_drought_bug = assets_drought_bug,
			--anim = anim,
		}	
		--commonlib.echo(result);
		HomeLandConfig.ParsePlantEPool[s] = result;
		return 	result;
	end
end

--[[
s = {indoor="model/01building/v5/01house/PoliceStation/Indoor.x"}
--]]
HomeLandConfig.ParseHomeEntryPool = {};
function HomeLandConfig.ParseHomeEntry(s)
	if(HomeLandConfig.ParseHomeEntryPool[s])then
		return HomeLandConfig.ParseHomeEntryPool[s];
	end
	local t = commonlib.LoadTableFromString(s);
	if(t)then
		HomeLandConfig.ParseHomeEntryPool[s] = t;
		return t;
	end
end
--[[
s = {hitstyle="model/07effect/v5/WaterBalloon/WaterBalloon1.x",showpic="Texture/Aries/Smiley/face10_32bits.png"}
s = {hitstyle="model/07effect/v5/Jelly/Jelly1.x",showpic="Texture/Aries/Smiley/face03_32bits.png"}--Ĭ��showpic
s = {hitstyle="model/07effect/v5/Firecracker/Firecracker1.x",effect_time = "00:00:05"}
--]]
HomeLandConfig.ParseThrowBallPool = {};
function HomeLandConfig.ParseThrowBall(s)
	if(HomeLandConfig.ParseThrowBallPool[s])then
		return HomeLandConfig.ParseThrowBallPool[s];
	end
	local t = commonlib.LoadTableFromString(s);
	if(t)then
		HomeLandConfig.ParseThrowBallPool[s] = t;
		return t;
	end
end
--[[

--]]
HomeLandConfig.ParseMusicBoxPool = {};
function HomeLandConfig.ParseMusicBox(s)
	if(HomeLandConfig.ParseMusicBoxPool[s])then
		return HomeLandConfig.ParseMusicBoxPool[s];
	end
	local t = commonlib.LoadTableFromString(s);
	if(t)then
		HomeLandConfig.ParseMusicBoxPool[s] = t;
		return t;
	end
end