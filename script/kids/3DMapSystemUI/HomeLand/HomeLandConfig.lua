--[[
Title: HomeLandConfig
Author(s): Leio
Date: 2009/4/8
Desc: 家园里面的配置信息
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
Map3DSystem.App.HomeLand.HomeLandConfig.Load();
------------------------------------------------------------
]]
local HomeLandConfig = {
	defaultPath = "config/Aries/Others/PetMsgHomeLandConfig.xml",
	loaded = false,
	
	StartPoint = {x = 0, y = 0, z = 0},--家园活动范围的开始点
	EndPoint = {x = 500, y = 0, z = 500},--家园活动范围的结束点
	DefaultWorld = "worlds/MyWorlds/0920_homeland",--默认的家园世界
	DefaultBornPlace = {x = 19959.169921875, y = 30, z = 20273.046875},--默认的家园出生点
	OutdoorOrigin = {x = 0, y = 0, z = 0},--室外的起始坐标
	IndoorOrigin = {x = 19963, y = 50000, z = 20304},-- 室内的起始坐标，同样也是室内模型的摆放位置
	MonitorBox = {x = 2, y = 2, z = 2}, --监听盒子的大小
	GridBox = {x = 2, y = 2, z = 2}, --花圃每一个格子的大小
	EntryTipStyle = "model/07effect/v5/Firecracker/Firecracker1.x", -- 入口提醒的样式
	ExitTipStyle = "model/07effect/v5/WaterBalloon/WaterBalloon1.x", --出口提醒的样式-
	EntryMonitorInterval = 3000, --房屋入口监听的周期，毫秒
	HomeNameMax = 24,-- 家园名称最大字符数
	GiftMsgMax = 150,--礼物赠言最大字数
	
	Throwball_Duration = "00:00:01",--投掷的物体飞行的时间
	Throwball_Movement_Duration = "00:00:00.5",---投掷动作播放持续的时间
	Throwball_Effect_Duration = "00:00:01",---击中后，显示效果的时间
	Throwball_Movement_AnimationFile = "character/Animation/v5/Throw.x",---扔球的动作
	Throwball_Movement_Mount_AnimationFile_1 = "character/Animation/v5/ThrowDragonMinor.x",---小龙，骑在龙上扔球的动作
	Throwball_Movement_Mount_AnimationFile_2 = "character/Animation/v5/ThrowDragonMajor.x",---大龙，骑在龙上扔球的动作
	Throwball_MaxDis = 60,---最远射程
	Throwball_OnHit_MinVolume = 0.2,--被击中的最小间距
	Throwball_G = 0.05,--重力加速度
	Throwball_OnHit_FindRadius = 0.2,--查找半径
	
	Bag_Gift = 20001,--礼物的bag号
	Bag_Fruit = 12,--果实的bag号
	
	View_ShowSelectedTip = "true",-- 在浏览状态下点击物体，是否显示选中
	Panel_ShowPos = {align = "_lt", left = 5,top = 85,width = 128,height = 512  },--物体属性面板显示的位置
	Panel_ShowPos_AwayBtn = {align = "_lb", left = 10,top = -80,width = 70,height = 80 },--离开按钮
	Panel_ShowPos_ItemLibs = {align = "_ctb", left = -10,top = 0,width = 702,height = 123 },--家园仓库列表
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
--返回值
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
--樱桃
s = {stage=5,title="model/05plants/v5/01tree/CherryTree/CherryTree"}
--菠萝
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
		
		--总共多少个阶段
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
s = {hitstyle="model/07effect/v5/Jelly/Jelly1.x",showpic="Texture/Aries/Smiley/face03_32bits.png"}--默认showpic
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