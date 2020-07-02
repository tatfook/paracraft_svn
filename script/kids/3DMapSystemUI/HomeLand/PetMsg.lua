--[[
Title: PetMsg
Author(s): Leio
Date: 2009/6/23
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/PetMsg.lua");
Map3DSystem.App.HomeLand.PetMsg.Load();
Map3DSystem.App.HomeLand.PetMsg.PrintMsg();
--Map3DSystem.App.HomeLand.PetMsg.GetLevelUpMsg(13)
------------------------------------------------------------
]]
--[[
<PetMsg>
<Const>
	<Healthy>0</Healthy><!--健康常量-->
	<Sick>1</Sick><!--生病常量-->
	<Dead>2</Dead><!--死亡常量-->
	<Hunger>150</Hunger><!--达到饥饿最低值-->
	<Dirty>150</Dirty><!--达到脏最低值-->
	<Depressed>150</Depressed><!--达到郁闷最低值-->
	<SingleLevelGrownMaxValue>500</SingleLevelGrownMaxValue><!--单级成长最大值-->
	<SpeakInterval>30000</SpeakInterval><!--毫秒，说话周期-->
	<SpeakOdds>100</SpeakOdds><!--在正常情况下，说话几率-->
	<SpeakLifeTime>5000</SpeakLifeTime><!--毫秒，说话显示的时间-->
	<RefreshDuration>3600000</RefreshDuration><!--毫秒，刷新坐骑数据周期-->
	<WaitDuration>00:00:01</WaitDuration><!--在被送回家的时候，需要说话，这是等待说完话的时间-->
	<MinAIRadius>5</MinAIRadius><!--最小感应区-->
	<EggLevel>4</EggLevel><!--第1阶段最大值 4-->
	<ChildLevel>7</ChildLevel><!--第2阶段最大值 7-->
	<AdultLevel>8</AdultLevel><!--第3阶段最大值 8-->
	<MsgOverLevel>30</MsgOverLevel><!--升级语言上限值-->
</Const>
<PetMsgLib>
	<Item type = "master_egg" path = "config/Aries/Others/PetMsg/msg/master_egg.csv" />
	<Item type = "master_child" path = "config/Aries/Others/PetMsg/msg/master_child.csv" />
	<Item type = "master_adult" path = "config/Aries/Others/PetMsg/msg/master_adult.csv" />
	<Item type = "guest_egg" path = "config/Aries/Others/PetMsg/msg/guest_egg.csv" />
	<Item type = "guest_child" path = "config/Aries/Others/PetMsg/msg/guest_child.csv" />
	<Item type = "guest_adult" path = "config/Aries/Others/PetMsg/msg/guest_adult.csv" />
</PetMsgLib>
<PetLevelUpMsg path = "config/Aries/Others/PetMsg/msg/level_up.csv" /><!--升级语言-->
<PetEnum>
	<!--身份-->
	<Identity>
		<Item label = "master" />
		<Item label = "guest" />
	</Identity>
	<!--成长级别-->
	<Level>
		<Item label = "egg" />
		<Item label = "child" />
		<Item label = "adult" />
	</Level>
	<!--状态-->
	<State>
		<Item label = "follow" />
		<Item label = "ride" />
		<Item label = "home" />
		<Item label = "stateChange" />
	</State>
	<!--触发的模式-->
	<TriggerMode>
		<!--follow rid home-->
		<Item label = "free" />
		<Item label = "calculate" />
		<Item label = "feed" />
		<Item label = "bath" />
		<Item label = "playtoy" />
		<Item label = "medicine" />
		<Item label = "especial" />
		<Item label = "nearby5m" />
		<!--stateChange-->
		<Item label = "followToHome" />
		<Item label = "rideToHome" />
		<Item label = "homeToFollow" />
		<Item label = "rideToFollow" />
		<Item label = "followToRide" />
		<Item label = "homeToRide" />
	</TriggerMode>
	<!--触发的条件-->
	<TriggerCondition>
		<!--free calculate 在一个时间周期内不停的触发，或者在一定的活动范围内-->
		<Item label = "normal" />
		<Item label = "hunger" />
		<Item label = "dirty" />
		<Item label = "depressed" />
		<Item label = "sick" />
		<!--feed bath toy medicine 手工执行后触发 -->
		<Item label = "stillNormal" />
		<Item label = "stillHunger" />
		<Item label = "stillDirty" />
		<Item label = "stillDepressed" />
		<Item label = "stillSick" />
		<!--feed 手工执行后触发-->
		<Item label = "feedFailed" /><!--如果饥饿值=100-->
		<!--bath 手工执行后触发-->
		<Item label = "bathFailed" /><!--如果清洁值=100-->
		<!--toy 手工执行后触发-->
		<Item label = "toyFailed1" /><!-- 如果健康值=1，生病状态下-->
		<Item label = "toyFailed2" /><!--如果饥饿值<30-->
		<Item label = "toyFailed3" /><!--如果清洁值<30-->
		<!--medicine 手工执行后触发-->
		<Item label = "medicineFailed" /><!--如果是在健康情况下-->
		<!--especial 手工执行后触发-->
		<Item label = "especialFailed" /><!---如果心情值<15-->
		<!--stateChange 手工执行后触发-->
		<Item label = "stateSuccessful" />
	</TriggerCondition>
</PetEnum>
</PetMsg>
--]]

local PetMsg = {
	defaultPath = "config/Aries/Others/PetMsg/PetMsgConfig.xml",
	--常规语言
	data = nil,
	--升级语言
	data_level = nil,
	allConst = nil,
	loaded = false,
};
commonlib.setfield("Map3DSystem.App.HomeLand.PetMsg",PetMsg);
function PetMsg.GetMsg(identity,level,state,triggerMode,triggerCondition)
	local self = PetMsg;
	if(not self.data)then return end
	local index = string.format("%s_%s_%s_%s_%s",identity or "",level or "",state or "",triggerMode or "",triggerCondition or "");
	--全部转换为小写字母
	index = string.lower(index);
	local data = self.data[index];
	if(data and type(data) == "table")then
		local len = #data;
		local i = math.random(len);
		return data[i];
	end
end
--获取升级语言
function PetMsg.GetLevelUpMsg(level)
	local self = PetMsg;
	if(not level or not self.data_level or not self.allConst)then return end
	local over_level = self.allConst["MsgOverLevel"];
	local level_key;
	if(level < over_level)then
		level_key = "_"..level
	else
		level_key = "_"..over_level.."_over";
	end
	local data = self.data_level[level_key];
	if(data and type(data) == "table")then
		local len = #data;
		local i = math.random(len);
		return data[i];
	end
end
function PetMsg.ReLoad()
	local self = PetMsg;
	self.loaded = false;
	self.Load();
end
function PetMsg.Load()
	local self = PetMsg;
	if(not self.loaded)then
		self.loaded = true;
		if(System.options.version == "teen") then
			return;
		end
		-- commonlib.echo(commonlib.debugstack(2, 5, 1))
		LOG.std(nil, "system", "PetMsg", "Loading dragon mount pet text ai file from %s", self.defaultPath);
		local xmlRoot = ParaXML.LuaXML_ParseFile(self.defaultPath);
		if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
			xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
			NPL.load("(gl)script/ide/XPath.lua");	
			--常规语言
			local result = {};
			for rootNode in commonlib.XPath.eachNode(xmlRoot, "//PetMsgLib") do
				if(rootNode) then
					local child;
					for child in rootNode:next() do
						self.ParseFile(child,result)
					end	
				end
			end
			self.data = result;
			
			--升级语言
			local result = {};
			for rootNode in commonlib.XPath.eachNode(xmlRoot, "//PetLevelUpMsg") do
				if(rootNode) then
					self.ParseFile_LevelUp(rootNode,result)
				end
				break;
			end
			self.data_level = result;
			
			--[[
				<Healthy>0</Healthy><!--健康常量-->
				<Sick>1</Sick><!--生病常量-->
				<Dead>2</Dead><!--死亡常量-->
				<Hunger>30</Hunger><!--达到饥饿最低值，最大值100-->
				<Dirty>30</Dirty><!--达到脏最低值，最大值100-->
				<Depressed>30</Depressed><!--达到郁闷最低值，最大值100-->
				<SpeakInterval>5000</SpeakInterval><!--毫秒，提醒周期-->
				<SpeakOdds>30</SpeakOdds><!--在正常情况下，说话几率-->
				<RefreshDuration>600000</RefreshDuration><!--毫秒，刷新坐骑数据周期-->	
			--]]
			local allConst = {};
			for rootNode in commonlib.XPath.eachNode(xmlRoot, "//Const") do
				if(rootNode) then
					local child;
					for child in rootNode:next() do
						local name = child.name;
						local value = child[1];
						value = tonumber(value);
						if(name and value)then
							allConst[name] = value;
						end
					end	
				end
			end
			self.allConst = allConst;
		end
	end
end
function PetMsg.ParseFile(mcmlNode,result)
	if(not mcmlNode or not result)then return end
	local pet_type = mcmlNode:GetString("type");
	local path = mcmlNode:GetString("path");
	if(not pet_type or not path)then return end
	local line;
	LOG.std(nil, "system", "PetMsg", "Loading text ai file from %s", path);
	local file = ParaIO.open(path, "r");
	local state,triggerMode,triggerCondition
	if(file:IsValid()) then
		line=file:readline();
		while line~=nil do 
			local __,__,__,t_state,__,t_triggerMode,__,t_triggerCondition,content = string.find(line,"(.-),(.-),(.-),(.-),(.-),(.-),(.+)");
			if(content and content ~= "")then
				if(t_state and t_state ~= "")then
						state = t_state;
				end
				if(t_triggerMode and t_triggerMode ~= "")then
					triggerMode = t_triggerMode;
				end
				if(t_triggerCondition and t_triggerCondition ~= "")then
						triggerCondition = t_triggerCondition;
				end
				if(pet_type and state and triggerMode and triggerCondition)then
					local key = string.format("%s_%s_%s_%s",pet_type,state,triggerMode,triggerCondition);
					--全部转换为小写字母
					key = string.lower(key);
					if(not result[key])then
						result[key] = {};
					end
					table.insert(result[key],content);
				end
			end
			line=file:readline();
		end
		file:close();
	end
	return result;
end
function PetMsg.ParseFile_LevelUp(mcmlNode,result)
	if(not mcmlNode or not result)then return end
	local path = mcmlNode:GetString("path");
	if(not path)then return end
	local line;
	local level_key;
	LOG.std(nil, "system", "PetMsg", "Loading text ai file from %s", path);
	local file = ParaIO.open(path, "r");
	if(file:IsValid()) then
		line=file:readline();
		while line~=nil do 
			local __,__,t_level_key,content,__ = string.find(line,"(.-),(.-),(.-)");
			if(content and content ~= "")then
			
				if(t_level_key and t_level_key ~= "")then
					level_key = t_level_key;
				end
				local key = "_" ..level_key;
				key = string.lower(key);
				if(not result[key])then
					result[key] = {};
				end
				table.insert(result[key],content);
			end
			line=file:readline();
		end
		file:close();
	end
	return result;
end
--@param type: "normal" or "level_up" or nil
function PetMsg.PrintMsg(type)
	local self = PetMsg;
	function _print(data)
		local k,v;
		local s = "";
		for k,v in pairs(data) do
			for __,vv in ipairs(v) do
				s = s .. string.format("%s:%s\r\n",k,vv);
			end
		end
		return s;
	end
	local r = "";
	if(not type)then
		r = _print(self.data) .. _print(self.data_level);
	elseif(type == "normal")then
		r = _print(self.data);
	elseif(type == "level_up")then
		r = _print(self.data_level);
	end
	commonlib.echo(r);
end