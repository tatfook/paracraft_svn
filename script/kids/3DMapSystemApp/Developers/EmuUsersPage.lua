--[[
Title: code behind page for EmuUsersPage.html
Author(s): LiXizhi
Date: 2008/12/31
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Developers/EmuUsersPage.lua");
-------------------------------------------------------
]]
local EmuUsersPage = {};
commonlib.setfield("Map3DSystem.App.Developers.EmuUsersPage", EmuUsersPage)

---------------------------------
-- page event handlers
---------------------------------

-- init
function EmuUsersPage.OnInit()
	local self = document:GetPageCtrl();

	--local files = Map3DSystem.App.Developers.app:ReadConfig("RecentlyTranslatedFiles", {})
	--local index, value
	--for index, value in ipairs(files) do
		--self:SetNodeValue("filepath", value);
	--end
	--self:SetNodeValue("filepath", "");
end

-- translate the file
function EmuUsersPage.OnClickStartEmuUsers()
	local self = document:GetPageCtrl();
	local filename = self:GetUIValue("filepath");
	if(ParaIO.DoesFileExist(filename)) then
		NPL.load("(gl)script/kids/3DMapSystemNetwork/EmuUsers.lua");
		Map3DSystem.EmuUsers.LoadUsers(filename)
	end
end

-- generate emulation users near a center
function EmuUsersPage.GenEmuUsers(btnName, values)
	local self = document:GetPageCtrl();
	local radius = tonumber(values["radius"])
	local gencount = tonumber(values["gencount"])
	
	local username = values["username"]
	local password = values["password"]
	local worldpath = ParaWorld.GetWorldDirectory();
	local name = string.gsub(username, "@.+", "") 
	local domain = string.match(username, "@.+");
	local server = values["server"] or "1100";
	local filename = self:GetUIValue("filepath");
	
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(xmlRoot) then
	
		-- read all users
		local node, usersNode;
		for node in commonlib.XPath.eachNode(xmlRoot, "/EmuDB/EmuUsers") do
			usersNode = node;
			break;
		end
		
		-- search if a given user exist 
		local function GetUserNode(username)
			local user
			for user in commonlib.XPath.eachNode(usersNode, "/user") do
				if(user.attr and user.attr["username"] == username) then
					return user
				end
			end
		end
		
		if(usersNode) then
			local x,y,z = ParaScene.GetPlayer():GetPosition();
			local index;
			for index = 1, gencount do 
				local newx = ParaGlobal.random()*radius+x
				local newz = ParaGlobal.random()*radius+z
				local newy = ParaTerrain.GetElevation(newx, newz)
				local new_username
				if(gencount>1)then
					new_username = name..tostring(index)..(domain or "");
				else	
					new_username = username
				end
				local new_userNode = {name = "user", 
					attr={username=new_username, password=password, worldpath = worldpath, server=server},
					n=1,
					[1] = {
						name="playeragent",
						attr = {
							dummy="1", x=tostring(newx), y = tostring(newy), z=tostring(newz), 
							AssetFile="character/v4/Can/can01/can01.x",
						},
					}
				}
				local userNode = GetUserNode(new_username);
				if(userNode == nil) then
					usersNode[#usersNode+1] = new_userNode;
				else
					-- update existing ones. 
					commonlib.deepcopy(userNode, new_userNode);
				end
			end
			
			NPL.load("(gl)script/ide/LuaXML.lua");
			local file = ParaIO.open(filename, "w");
			if(file:IsValid()) then
				file:WriteString(commonlib.Lua2XmlString(xmlRoot, true))
				file:close();
				_guihelper.MessageBox(filename.." is saved successfully");
			else
				_guihelper.MessageBox(filename..": unable to open file for writing. Can it be read-only?");
			end
		else
			_guihelper.MessageBox(filename.." no users node is found\n");	
		end	
	else
		_guihelper.MessageBox(filename.." can not be parsed\n");
	end	
end