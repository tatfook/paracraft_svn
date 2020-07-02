--[[
Title: RoomHostService
Author(s): LiXizhi
Date: 2008/1/12
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/RoomHostApp/RoomHostService.lua");
------------------------------------------------------------
]]

-- requires

-- create class
if(not Map3DSystem.App.RoomHostService) then Map3DSystem.App.RoomHostService = {} end


-- Send a request to server to create a new room for a given application using the current user session and user_id. 
-- @param password: whether room is locked by password.
function Map3DSystem.App.RoomHostService.CreateRoom(app_key, roomName, password, MinTimeOut, MaxPeopleAllowed, level)
end


-- Send a request to join a given room. 
-- @param password:
function Map3DSystem.App.RoomHostService.JoinRoom(app_key, room_id, password)
end

-- Send a request to get all latest rooms of an application. 
-- @param app_key: if application key is nil, it will return latest rooms regardless of applications. 
-- @param pageNumber: 1 based index of page. 
-- @param ItemsPerPage: default to 10
function Map3DSystem.App.RoomHostService.GetRoomList(app_key, pageNumber, ItemsPerPage)

end

-- Get applications with active rooms. For example we can sort by hottest or latest, etc. 
-- @param pageNumber: 1 based index of page. 
-- @param ItemsPerPage: default to 10
function Map3DSystem.App.RoomHostService.GetAppList(sortMethod, pageNumber, ItemsPerPage)

end



