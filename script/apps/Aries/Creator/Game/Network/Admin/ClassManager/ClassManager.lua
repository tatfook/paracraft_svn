--[[
Title: Teacher Panel
Author(s): Chenjinxian
Date: 2020/8/6
Desc: 
use the lib:
-------------------------------------------------------
local ClassManager = NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Admin/ClassManager/ClassManager.lua");
ClassManager.StaticInit();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/keepwork.class.lua");
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/LockDesktop.lua");
local KeepWorkItemManager = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkItemManager.lua");
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
local KpChatChannel = NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/ChatSystem/KpChatChannel.lua");
local TeacherPanel = NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Admin/ClassManager/TeacherPanel.lua");
local StudentPanel = NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Admin/ClassManager/StudentPanel.lua");
local TChatRoomPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Admin/ClassManager/TChatRoomPage.lua");
local SChatRoomPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Admin/ClassManager/SChatRoomPage.lua");
local LockDesktop = commonlib.gettable("MyCompany.Aries.Game.Tasks.LockDesktop");
local ClassManager = NPL.export()

ClassManager.InClass = false;
ClassManager.CurrentClassId = nil;
ClassManager.CurrentWorldId = nil; 
ClassManager.CurrentClassroomId = nil;
ClassManager.CurrentClassName = nil;
ClassManager.CurrentWorldName = nil; 

ClassManager.ClassList = {};
ClassManager.ProjectList = {};
ClassManager.StudentList = {};
ClassManager.ShareLinkList = {};

ClassManager.ChatDataList = {};
ClassManager.ChatDataMax = 200;

local init = false;
function ClassManager.StaticInit()
	if (init) then return end

	GameLogic.GetFilters():add_filter("OnKeepWorkLogin", ClassManager.OnKeepWorkLogin_Callback);
	GameLogic.GetFilters():add_filter("OnKeepWorkLogout", ClassManager.OnKeepWorkLogout_Callback)
end

function ClassManager.OnKeepWorkLogin_Callback()
	if (KpChatChannel.client) then
		KpChatChannel.client:AddEventListener("OnMsg",ClassManager.OnMsg,ClassManager);
		commonlib.TimerManager.SetTimeout(function()
			ClassManager.LoadOnlineClassroom(function(classId, projectId, classroomId)
				if (ClassManager.IsTeacherInClass()) then
					_guihelper.MessageBox("你所在的班级正在上课！", function(res)
						if(res and res == _guihelper.DialogResult.Yes)then
							ClassManager.InClass = true;
							TeacherPanel.StartClass();
						else
							ClassManager.DismissClassroom(ClassManager.CurrentClassroomId);
						end
					end, _guihelper.MessageBoxButtons.YesNo, {yes = "立即上课", no = "立即下课", show_label = true});
				else
					_guihelper.MessageBox("你所在的班级正在上课！", function(res)
						if(res and res == _guihelper.DialogResult.Yes)then
							ClassManager.InClass = true;
							StudentPanel.StartClass();
						end
					end, _guihelper.MessageBoxButtons.YesNo, {yes = "立即上课", no = "暂时不", show_label = true});
				end
			end);
		end, 1000)
	end
end

function ClassManager.OnKeepWorkLogout_Callback()
	if (KpChatChannel.client) then
		KpChatChannel.client:RemoveEventListener("OnMsg",ClassManager.OnMsg,ClassManager);
		ClassManager.LeaveClassroom(ClassManager.CurrentClassroomId);
	end
end

function ClassManager.LoadAllClassesAndProjects(callback)
	keepwork.userOrgInfo.get(nil, function(err, msg, data)
		local orgs = data and data.data and data.data.allOrgs;
		if (orgs == nil) then return end

		for i = 1, #orgs do
			keepwork.classes.get({cache_policy = "access plus 0", organizationId = orgs[i].id}, function(err, msg, data)
				local classes = data and data.data;
				if (classes == nil) then return end

				for j = 1, #classes do
					if (classes[j].classId and classes[j].name) then
						table.insert(ClassManager.ClassList, classes[j]);
					end
				end

				if (i == #orgs) then
					local projectId = tonumber(GameLogic.options:GetProjectId());
					if (projectId) then
						table.insert(ClassManager.ProjectList, projectId);
					end
					keepwork.classroom.get({cache_policy = "access plus 0"}, function(err, msg, data)
						local rooms = data and data.data and data.data.rows;
						if (rooms) then
							local function findProject(id)
								for j = 1, #ClassManager.ProjectList do
									if (id == ClassManager.ProjectList[j]) then
										return true;
									end
								end
								return false;
							end
							for j = 1, #rooms do
								if (not findProject(rooms[j].projectId)) then
									table.insert(ClassManager.ProjectList, rooms[j].projectId);
								end
							end
						end

						if (callback) then
							callback();
						end
					end);
				end
			end);
		end
	end);
end

function ClassManager.LoadOnlineClassroom(callback)
	keepwork.classroom.get({cache_policy = "access plus 0"}, function(err, msg, data)
		local rooms = data and data.data and data.data.rows;
		if (rooms) then
			for i = 1, #rooms do
				if (rooms[i].status == 1) then
					ClassManager.CurrentClassName = rooms[i].class.name;
					ClassManager.LoadClassroomInfo(rooms[i].id, callback);
					return;
				end
			end
		end
	end);
end

function ClassManager.LoadClassroomInfo(classroomId, callback)
	keepwork.info.get({cache_policy = "access plus 0", classroomId = classroomId}, function(err, msg, data)
		local room = data and data.data;
		if (room == nil) then return end

		ClassManager.CurrentWorldId = room.projectId;
		ClassManager.CurrentClassId = room.classId;
		ClassManager.CurrentClassroomId = room.id;
		ClassManager.CurrentWorldName = room.project.name;
		ClassManager.StudentList = room.classroomUser or {};
		if (callback) then
			callback(room.classId, room.projectId, classroomId);
		end
	end);
end

function ClassManager.CreateClassroom(classId, projectId, callback)
	keepwork.classroom.post({classId = classId, projectId = projectId}, function(err, msg, data)
		if (err == 200) then
			ClassManager.CurrentClassId = classId;
			ClassManager.CurrentWorldId = projectId;
			ClassManager.InClass = true;
		end
		if (callback) then
			callback(err == 200, data);
		end
	end);
end

function ClassManager.DismissClassroom(classroomId, callback)
	keepwork.dismiss.post({classroomId = classroomId}, function(err, msg, data)
		if (callback) then
			callback(err == 200, data);
		end
		if (err == 200) then
			ClassManager.Reset();
		end
	end);
end

function ClassManager.JoinClassroom(classroomId)
	if (not classroomId) then return end
	if (not KpChatChannel.IsConnected()) then return end

	local room = string.format("__classroom_%s__", tostring(classroomId));
	KpChatChannel.client:Send("app/join", { rooms = { room}, });
end

function ClassManager.LeaveClassroom(classroomId)
	if (not classroomId) then return end
	local room = string.format("__classroom_%s__", tostring(classroomId));
	KpChatChannel.client:Send("app/leave", { rooms = { room}, });
	ClassManager.Reset();
end

function ClassManager.ClassNameFromId(classId)
	for i = 1, #ClassManager.ClassList do
		local class = ClassManager.ClassList[i];
		if (class.classId == classId) then
			return class.name;
		end
	end
end

function ClassManager.IsTeacherInClass()
	local userId = tonumber(Mod.WorldShare.Store:Get("user/userId"));
	for i = 1, #ClassManager.StudentList do
		if (userId == ClassManager.StudentList[i].userId) then
			local userInfo = ClassManager.StudentList[i].user;
			return userInfo.tLevel == 1 and userInfo.student == 0;
		end
	end
	return false;
end

function ClassManager.GetClassTeacherInfo()
	for i = 1, #ClassManager.StudentList do
		local userInfo = ClassManager.StudentList[i].user;
		if (userInfo and userInfo.tLevel == 1 and userInfo.student == 0) then
			return userInfo;
		end
	end
end

function ClassManager.GetOnlineCount()
	local count = 0;
	for i = 1, #ClassManager.StudentList do
		if (ClassManager.StudentList[i].online) then
			count = count + 1;
		end
	end
	return count;
end

function ClassManager.RunCommand(command)
	if (command == "lock") then
		LockDesktop.ShowPage(true, 60 * 60, cmd_text);
	elseif (command == "unlock") then
		LockDesktop.ShowPage(false, 0, cmd_text);
	end
end

function ClassManager.AddLink(link, name, timestamp)
end

function ClassManager.ProcessMessage(payload, meta)
	local name = payload.nickname;
	if (name == nil or name == "") then
		name = payload.username;
	end
	local result = commonlib.split(payload.content, ":");
	local type, content = result[1], result[2];

	local userId = tonumber(Mod.WorldShare.Store:Get("user/userId"));
	if (type == "cmd") then
		if (userId ~= payload.id) then
			ClassManager.RunCommand(content);
		end
	elseif (type == "tip") then
		TChatRoomPage.Refresh();
		SChatRoomPage.Refresh();
	elseif (type == "link") then
		if (userId ~= payload.id) then
			ClassManager.AddLink(content, name, meta.timestamp);
		end
	else
	end

	local msgdata = {
		msgType = type,
		fromName = name,
		fromMyself = userId == payload.id,
		timestamp = meta.timestamp,
		words = content,
	};
	ChatChannel.ValidateMsg(msgdata, ClassManager.OnProcessMsg);
end

function ClassManager.OnMsg(self, msg)
	if (not msg or not msg.data) then return end

	local data = msg.data;
	local eio_pkt_name = data.eio_pkt_name;
	local sio_pkt_name = data.sio_pkt_name;
	if(eio_pkt_name == "message" and sio_pkt_name =="event")then
		local body = data.body or {};
		local key = body[1] or {};
		local info = body[2] or {};
		local payload = info.payload;
		local meta = info.meta;
		local userInfo = info.userInfo;
		local action = payload and payload.action;

		if (action == "classroom_start") then
			ClassManager.LoadClassroomInfo(payload.classroomId, function(classId, projectId, classroomId)
				ClassManager.CurrentClassroomId = classroomId;
				local teacher = ClassManager.GetClassTeacherInfo();
				if (not teacher) then return end

				local userId = tonumber(Mod.WorldShare.Store:Get("user/userId"));
				if (userId == teacher.id) then
					TeacherPanel.StartClass();
				else
					_guihelper.MessageBox("老师邀请你上课！", function(res)
						if(res and res == _guihelper.DialogResult.Yes)then
							ClassManager.InClass = true;
							StudentPanel.StartClass();
						end
					end, _guihelper.MessageBoxButtons.YesNo, {yes = "立即上课", no = "暂时不", show_label = true});
				end
			end);
			return;
		end
		if (key == "app/msg" and payload and userInfo) then
			local room = string.format("__classroom_%s__", tostring(ClassManager.CurrentClassroomId));
			if (meta and meta.target == room) then
				ClassManager.ProcessMessage(payload, meta);
			end
		end
	end
end

function ClassManager.Reset()
	ClassManager.InClass = false;
	ClassManager.CurrentClassId = nil;
	ClassManager.CurrentWorldId = nil; 
	ClassManager.CurrentClassroomId = nil;

	ClassManager.ClassList = {};
	ClassManager.ProjectList = {};
	ClassManager.StudentList = {};
end

function ClassManager.SendMessage(content)
	local msgdata = {
		ChannelIndex = ChatChannel.EnumChannels.KpNearBy,
		target = string.format("__classroom_%s__", tostring(ClassManager.CurrentClassroomId)),
		worldId = ClassManager.CurrentWorldId,
		words = content,
		type = 2,
		is_keepwork = true,
	};

	if (ChatChannel.WordsFilter) then
		for i= 1, #(ChatChannel.WordsFilter) do
			local filter_func = ChatChannel.WordsFilter[i];
			if(filter_func and type(filter_func)=="function")then
				msgdata = filter_func(msgdata);
				if(msgdata == true) then
					return true;
				elseif(msgdata==nil or msgdata.words == nil or msgdata.words == "" )then
					return false;
				end
			end
		end
	end

	ChatChannel.ValidateMsg(msgdata, KpChatChannel.SendToServer);
	return true;
end

function ClassManager.OnProcessMsg(msgdata)
	table.insert(ClassManager.ChatDataList, msgdata);
	if(#(ClassManager.ChatDataList) > ClassManager.ChatDataMax)then
		table.remove(ClassManager.ChatDataList, 1); 
	end

	SChatRoomPage.AppendChatMessage(msgdata, true);
	TChatRoomPage.AppendChatMessage(msgdata, true);
end

function ClassManager.MessageToMcml(chatdata)
	local words = commonlib.Encoding.EncodeStr(chatdata.words or "");
	words = words:gsub("\n", "<br/>")
	if(not System.options.mc) then
		words = SmileyPage.ChangeToMcml(words);
	end
	words = SChatRoomPage.FilterURL(words);

	local fromName = chatdata.fromName;
	local fromMyself = chatdata.fromMyself;
	local timestamp = chatdata.timestamp;

	local mcmlStr;
	local type = chatdata.msgType;
	if (type == "msg") then
		if (chatdata.fromMyself) then
			mcmlStr = string.format(
				[[
				<div style="height:20px;">
					<div style="width:66px;position:relative;margin-right:0px;color:#000000;" align="right">
						%s
					</div>
					<div style="width:53px;position:relative;margin-right:60px;color:#000000;" align="right">
						%s
					</div>
				</div>
				<div style="height:30px;">
					<div style="width:236px;position:relative;margin-right:0px;color:#000000;background:url(Texture/Aries/Creator/keepwork/ClassManager/teacher_bg_32bits.png#0 0 8 8:3 3 3 3);" align="right">
						%s
					</div>
				</div>
				]],
			fromName, timestamp, words);
		else
			mcmlStr = string.format(
				[[
				<div style="height:20px;">
					<div style="width:66px;position:relative;margin-right:0px;color:#000000;"">
						%s
					</div>
					<div style="width:53px;position:relative;margin-right:60px;color:#000000;"">
						%s
					</div>
				</div>
				<div style="height:30px;">
					<div style="width:236px;position:relative;margin-right:0px;color:#000000;background:url(Texture/Aries/Creator/keepwork/ClassManager/teacher_bg_32bits.png#0 0 8 8:3 3 3 3);" align="right">
						%s
					</div>
				</div>
				]],
			fromName, timestamp, words);
		end
	elseif (type == "cmd") then
		local text = L"开启了屏幕锁屏";
		if (words == "unlock") then
			text = L"关闭了屏幕锁屏";
		end
		mcmlStr = string.format(
			[[
			<div style="height:30px;">
				<div style="width:236px;position:relative;margin-right:0px;color:#000000;background:url(Texture/Aries/Creator/keepwork/ClassManager/teacher_bg_32bits.png#0 0 8 8:3 3 3 3);" align="right">
					%s%s
				</div>
			</div>
			]],
		fromName, text);
	elseif (type == "link") then
	else
	end

	return mcmlStr;
end