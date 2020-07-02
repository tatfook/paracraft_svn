--[[
Title: FollowPetMsg
Author(s): Leio
Date: 2009/10/13
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/FollowPetMsg.lua");
Map3DSystem.App.HomeLand.FollowPetMsg.Load();
Map3DSystem.App.HomeLand.FollowPetMsg.PrintMsg();
------------------------------------------------------------
--]]

local FollowPetMsg = {
	defaultPath = "config/Aries/Others/PetMsg/FollowPetMsgConfig.xml",
	--常规语言
	data = nil,
	loaded = false,
};
commonlib.setfield("Map3DSystem.App.HomeLand.FollowPetMsg",FollowPetMsg);
function FollowPetMsg.GetMsg(identity,state,condition)
	local self = FollowPetMsg;
	if(not self.data)then return end
	local index = string.format("%s_%s_%s",identity or "",state or "",condition or "");
	--全部转换为小写字母
	index = string.lower(index);
	local data = self.data[index];
	if(data and type(data) == "table")then
		local len = #data;
		local i = math.random(len);
		return index,data[i];
	end
end
function FollowPetMsg.ReLoad()
	local self = FollowPetMsg;
	self.loaded = false;
	self.Load();
end
function FollowPetMsg.Load()
	local self = FollowPetMsg;
	if(not self.loaded)then
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
		end
	end
end
function FollowPetMsg.ParseFile(mcmlNode,result)
	if(not mcmlNode or not result)then return end
	local pet_type = mcmlNode:GetString("type");
	local path = mcmlNode:GetString("path");
	if(not pet_type or not path)then return end
	local line;
	local file = ParaIO.open(path, "r");
	local state,condition;
	if(file:IsValid()) then
		line=file:readline();
		while line~=nil do 
			local __,__,__,t_state,__,__,t_condition,content,__ = string.find(line,"(.-),(.-),(.-),(.-),(.-),(.-),(.-)");
			
			if(content and content ~= "" and t_state and t_state ~= "none")then
				if(t_state and t_state ~= "")then
						state = t_state;
				end

				if(t_condition and t_condition ~= "")then
						condition = t_condition;
				end
				if(pet_type and state and condition)then
					local key = string.format("%s_%s_%s",pet_type,state,condition);
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
function FollowPetMsg.PrintMsg()
	local self = FollowPetMsg;
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
	local r = _print(self.data);
	
	commonlib.echo(r);
end