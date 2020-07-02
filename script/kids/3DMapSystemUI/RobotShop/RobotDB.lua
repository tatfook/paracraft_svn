--[[
Author(s): Leio
Date: 2007/12/7
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/RobotShop/RobotDB.lua");
------------------------------------------------------------
		
]]
NPL.load("(gl)script/sqlite/sqlite3.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/RobotShop/RobotInfo.lua");


if(not Map3DSystem.Map)then Map3DSystem.Map = {};end;
if(not Map3DSystem.Map.RobotDB)then Map3DSystem.Map.RobotDB = {};end

Map3DSystem.Map.RobotDB.SystemRobotFile = "database/SystemRobot.db";
Map3DSystem.Map.RobotDB.UserRobotFile = "database/UserRobot.db";

Map3DSystem.Map.RobotDB.SystemRobotDB = nil;
Map3DSystem.Map.RobotDB.UserRobotDB = nil;



		
--connect system robot
if( ParaIO.DoesFileExist( Map3DSystem.Map.RobotDB.SystemRobotFile,true))then
	local errMsg;
	Map3DSystem.Map.RobotDB.SystemRobotDB,errMsg = sqlite3.open( Map3DSystem.Map.RobotDB.SystemRobotFile);
	if( Map3DSystem.Map.RobotDB.SystemRobotDB == nil)then
		log("err connecting to SystemRobotDB\n");
		if( errMsg ~= nil)then
			log(errMsg.."\n");
		end
	end
else
	log("err connecting to SystemRobotDB\n");
end

--connect user robot
if( ParaIO.DoesFileExist( Map3DSystem.Map.RobotDB.UserRobotFile,true))then
	local errMsg;
	Map3DSystem.Map.RobotDB.UserRobotDB,errMsg = sqlite3.open( Map3DSystem.Map.RobotDB.UserRobotFile);
	if( Map3DSystem.Map.RobotDB.UserRobotDB == nil)then
		log("err connecting to UserRobotDB\n");
		if( errMsg ~= nil)then
			log(errMsg.."\n");
		end
	end
else
	log("err connecting to UserRobotDB\n");
end

function Map3DSystem.Map.RobotDB.GetSystemRobots(type)
	local self = Map3DSystem.Map.RobotDB;
	if( self.SystemRobotDB == nil)then
		log("can not connect to SystemRobotDB\n");
		return nil;
	end
	if (type==nil) then type=0 end;
	local robotInfos={};
	local cmd = string.format("SELECT * FROM robot where Race=%s",type);
	for row in self.SystemRobotDB:rows(cmd) do
		robotInfo=Map3DSystem.Map.RobotShop.RobotInfo:new();
		robotInfo.RobotID=row.RobotID;
		robotInfo.Name=row.Name;
		robotInfo.Specialty=row.Specialty;
		robotInfo.Race=row.Race;
		robotInfo.Price=row.Price;
		robotInfo.PicURL=row.PicURL;
		robotInfo.ModelPath=row.ModelPath;
		robotInfo.Used=row.Used;
		table.insert(robotInfos,robotInfo);
	end
	return robotInfos;
end
function Map3DSystem.Map.RobotDB.GetUserRobots(type)
	local self = Map3DSystem.Map.RobotDB;
	if( self.UserRobotDB == nil)then
		log("can not connect to UserRobotDB\n");
		return nil;
	end
	if (type==nil) then type=0 end;
	local robotInfos={};
	local cmd = string.format("SELECT * FROM robot where Race=%s order by Used ",type);
	for row in self.UserRobotDB:rows(cmd) do
		robotInfo=Map3DSystem.Map.RobotShop.RobotInfo:new();
		robotInfo.ID=row.ID;
		robotInfo.RobotID=row.RobotID;
		robotInfo.Name=row.Name;
		robotInfo.Specialty=row.Specialty;
		robotInfo.Race=row.Race;
		robotInfo.Price=row.Price;
		robotInfo.PicURL=row.PicURL;
		robotInfo.ModelPath=row.ModelPath;
		robotInfo.Used=row.Used;
		table.insert(robotInfos,robotInfo);
	end
	return robotInfos;
end
function Map3DSystem.Map.RobotDB.AddUserRobot(robotInfo)
	local self = Map3DSystem.Map.RobotDB;
	if(self.UserRobotDB == nil or robotInfo == nil or robotInfo.RobotID == nil or robotInfo.RobotID < 0)then
		return;
	end
		--insert data
		local cmd = string.format([[INSERT INTO robot (RobotID,Name,Specialty,Race,Price,PicURL,ModelPath,Used) 
				VALUES (%d,"%s","%s",%d,%s,"%s","%s",%d)]],
				robotInfo.RobotID,
				robotInfo.Name,
				robotInfo.Specialty,
				robotInfo.Race,
				robotInfo.Price,
				robotInfo.PicURL,
				robotInfo.ModelPath,
				robotInfo.Used);
		self.UserRobotDB:exec(cmd);
end
function Map3DSystem.Map.RobotDB.UpdateUserRobot(robotInfo)
	local self = Map3DSystem.Map.RobotDB;
	if(self.UserRobotDB == nil or robotInfo == nil or robotInfo.ID == nil or robotInfo.ID < 0)then
		return;
	end
	
	local cmd = string.format("SELECT ID FROM robot WHERE ID = %s",robotInfo.ID);
	local isExist = false;
	for row in self.UserRobotDB:rows(cmd) do
		isExist = true;
	end
	if(isExist)then
		--update data
		cmd = string.format([[UPDATE robot SET Used=%d WHERE ID =%d]],
			robotInfo.Used,
			robotInfo.ID);
		result=self.UserRobotDB:exec(cmd);
	end
end
function Map3DSystem.Map.RobotDB.RemoveUserRobot(ID)
	local self = Map3DSystem.Map.RobotDB;
	
	if(self.UserRobotDB == nil or ID == nil)then
		return;
	end
	
	local cmd = string.format([[DELETE FROM robot WHERE ID = %d]],ID);
	self.UserRobotDB:exec(cmd);
end




