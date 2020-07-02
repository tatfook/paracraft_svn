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
	<Healthy>0</Healthy><!--��������-->
	<Sick>1</Sick><!--��������-->
	<Dead>2</Dead><!--��������-->
	<Hunger>150</Hunger><!--�ﵽ�������ֵ-->
	<Dirty>150</Dirty><!--�ﵽ�����ֵ-->
	<Depressed>150</Depressed><!--�ﵽ�������ֵ-->
	<SingleLevelGrownMaxValue>500</SingleLevelGrownMaxValue><!--�����ɳ����ֵ-->
	<SpeakInterval>30000</SpeakInterval><!--���룬˵������-->
	<SpeakOdds>100</SpeakOdds><!--����������£�˵������-->
	<SpeakLifeTime>5000</SpeakLifeTime><!--���룬˵����ʾ��ʱ��-->
	<RefreshDuration>3600000</RefreshDuration><!--���룬ˢ��������������-->
	<WaitDuration>00:00:01</WaitDuration><!--�ڱ��ͻؼҵ�ʱ����Ҫ˵�������ǵȴ�˵�껰��ʱ��-->
	<MinAIRadius>5</MinAIRadius><!--��С��Ӧ��-->
	<EggLevel>4</EggLevel><!--��1�׶����ֵ 4-->
	<ChildLevel>7</ChildLevel><!--��2�׶����ֵ 7-->
	<AdultLevel>8</AdultLevel><!--��3�׶����ֵ 8-->
	<MsgOverLevel>30</MsgOverLevel><!--������������ֵ-->
</Const>
<PetMsgLib>
	<Item type = "master_egg" path = "config/Aries/Others/PetMsg/msg/master_egg.csv" />
	<Item type = "master_child" path = "config/Aries/Others/PetMsg/msg/master_child.csv" />
	<Item type = "master_adult" path = "config/Aries/Others/PetMsg/msg/master_adult.csv" />
	<Item type = "guest_egg" path = "config/Aries/Others/PetMsg/msg/guest_egg.csv" />
	<Item type = "guest_child" path = "config/Aries/Others/PetMsg/msg/guest_child.csv" />
	<Item type = "guest_adult" path = "config/Aries/Others/PetMsg/msg/guest_adult.csv" />
</PetMsgLib>
<PetLevelUpMsg path = "config/Aries/Others/PetMsg/msg/level_up.csv" /><!--��������-->
<PetEnum>
	<!--���-->
	<Identity>
		<Item label = "master" />
		<Item label = "guest" />
	</Identity>
	<!--�ɳ�����-->
	<Level>
		<Item label = "egg" />
		<Item label = "child" />
		<Item label = "adult" />
	</Level>
	<!--״̬-->
	<State>
		<Item label = "follow" />
		<Item label = "ride" />
		<Item label = "home" />
		<Item label = "stateChange" />
	</State>
	<!--������ģʽ-->
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
	<!--����������-->
	<TriggerCondition>
		<!--free calculate ��һ��ʱ�������ڲ�ͣ�Ĵ�����������һ���Ļ��Χ��-->
		<Item label = "normal" />
		<Item label = "hunger" />
		<Item label = "dirty" />
		<Item label = "depressed" />
		<Item label = "sick" />
		<!--feed bath toy medicine �ֹ�ִ�к󴥷� -->
		<Item label = "stillNormal" />
		<Item label = "stillHunger" />
		<Item label = "stillDirty" />
		<Item label = "stillDepressed" />
		<Item label = "stillSick" />
		<!--feed �ֹ�ִ�к󴥷�-->
		<Item label = "feedFailed" /><!--�������ֵ=100-->
		<!--bath �ֹ�ִ�к󴥷�-->
		<Item label = "bathFailed" /><!--������ֵ=100-->
		<!--toy �ֹ�ִ�к󴥷�-->
		<Item label = "toyFailed1" /><!-- �������ֵ=1������״̬��-->
		<Item label = "toyFailed2" /><!--�������ֵ<30-->
		<Item label = "toyFailed3" /><!--������ֵ<30-->
		<!--medicine �ֹ�ִ�к󴥷�-->
		<Item label = "medicineFailed" /><!--������ڽ��������-->
		<!--especial �ֹ�ִ�к󴥷�-->
		<Item label = "especialFailed" /><!---�������ֵ<15-->
		<!--stateChange �ֹ�ִ�к󴥷�-->
		<Item label = "stateSuccessful" />
	</TriggerCondition>
</PetEnum>
</PetMsg>
--]]

local PetMsg = {
	defaultPath = "config/Aries/Others/PetMsg/PetMsgConfig.xml",
	--��������
	data = nil,
	--��������
	data_level = nil,
	allConst = nil,
	loaded = false,
};
commonlib.setfield("Map3DSystem.App.HomeLand.PetMsg",PetMsg);
function PetMsg.GetMsg(identity,level,state,triggerMode,triggerCondition)
	local self = PetMsg;
	if(not self.data)then return end
	local index = string.format("%s_%s_%s_%s_%s",identity or "",level or "",state or "",triggerMode or "",triggerCondition or "");
	--ȫ��ת��ΪСд��ĸ
	index = string.lower(index);
	local data = self.data[index];
	if(data and type(data) == "table")then
		local len = #data;
		local i = math.random(len);
		return data[i];
	end
end
--��ȡ��������
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
			--��������
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
			
			--��������
			local result = {};
			for rootNode in commonlib.XPath.eachNode(xmlRoot, "//PetLevelUpMsg") do
				if(rootNode) then
					self.ParseFile_LevelUp(rootNode,result)
				end
				break;
			end
			self.data_level = result;
			
			--[[
				<Healthy>0</Healthy><!--��������-->
				<Sick>1</Sick><!--��������-->
				<Dead>2</Dead><!--��������-->
				<Hunger>30</Hunger><!--�ﵽ�������ֵ�����ֵ100-->
				<Dirty>30</Dirty><!--�ﵽ�����ֵ�����ֵ100-->
				<Depressed>30</Depressed><!--�ﵽ�������ֵ�����ֵ100-->
				<SpeakInterval>5000</SpeakInterval><!--���룬��������-->
				<SpeakOdds>30</SpeakOdds><!--����������£�˵������-->
				<RefreshDuration>600000</RefreshDuration><!--���룬ˢ��������������-->	
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
					--ȫ��ת��ΪСд��ĸ
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