--[[
Title: FriendChatPage
Author(s): 
Date: 2020/7/3
Desc:  
Use Lib:
-------------------------------------------------------
local FriendChatPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Friend/FriendChatPage.lua");
FriendChatPage.Show();
--]]
local FriendManager = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Friend/FriendManager.lua");
local FriendsPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Friend/FriendsPage.lua");
local pe_gridview = commonlib.gettable("Map3DSystem.mcml_controls.pe_gridview");
local Encoding = commonlib.gettable("commonlib.Encoding");

local FriendChatPage = NPL.export();

local UserData = {}
local ChatUserData = {}
FriendChatPage.UnreadMsg = {} -- 用以辅助小红点显示 会保存未读的数量以及最后一条消息
local ChatContent = {}
local FriendList = {} -- 好友列表
local TempFriendList = {} -- 存放临时好友信息

FriendChatPage.select_item_id = 0
local page;
local DateTool = os.date
FriendChatPage.IsOpen = false

NPL.load("(gl)script/ide/TreeView.lua");

FriendChatPage.data_sources =  {
	{ name = "哈哈", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png", nid = "10086", icon="Texture/Aries/Creator/keepwork/items/item_888_32bits.png", time=1598514220},
   { name = "哈哈", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png", icon="", time=1598427820},
   { name = "哈哈", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png", icon="", time=1598427820},
   { name = "哈哈", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png", icon="", time=1598427820},
   { name = "哈哈", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png", icon="", time=1595749420},
   { name = "哈哈", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png", icon="", time=1595749420},
   { name = "哈哈", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png", icon="", time=1564127020},
   { name = "哈哈", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png", icon="", time=1564127020},
   { name = "哈哈", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png", icon="", time=1564127020},
}
FriendChatPage.Current_Item_DS = {};
FriendChatPage.index = 1;
function FriendChatPage.OnInit()
	page = document:GetPageCtrl();
	page.OnClose = FriendChatPage.CloseView
end

function FriendChatPage.Show(user_data, chat_user_data)

	UserData = user_data

	local last_chat_msg = FriendManager:GetLastChatMsg() or {}

	if FriendChatPage.IsOpen then
		if ChatUserData and ChatUserData.id == chat_user_data.id then
			return
		end

		FriendChatPage.SaveChatContent(ChatUserData.id)

		FriendChatPage.UpdataFriendList(nil, function ()
			ChatUserData = chat_user_data

			if last_chat_msg[ChatUserData.id] == nil then
				chat_user_data.last_msg_time_stamp = os.time()
				TempFriendList[chat_user_data.id] = chat_user_data
			end
			
			
	
			local list = FriendChatPage.GetRecentFromFriendsList()
			for k, v in pairs(list) do
				if v.id == ChatUserData.id then
					FriendChatPage.select_item_id = v.id
				end
				-- FriendList[v.id] = v
			end
			FriendChatPage.Current_Item_DS = list
			FriendChatPage.OnRefresh()
			FriendManager:Connect(ChatUserData.id,function()
				FriendChatPage.CreateChatContentView()
				FriendChatPage.FreshFriendGridView()
			end)
		end)

		return
	end

	ChatUserData = chat_user_data
	if last_chat_msg[ChatUserData.id] == nil then
		chat_user_data.last_msg_time_stamp = os.time()
		TempFriendList[chat_user_data.id] = chat_user_data
	end
	
	local search_text = search_text or ""
	keepwork.user.friends({
		username=search_text,
        headers = {
            ["x-per-page"] = 200,
            ["x-page"] = 1,
        }
	},function(err, msg, data)
		-- commonlib.echo(data, true)
		if err == 200 then
			local function show_callback()
				local params = {
					url = "script/apps/Aries/Creator/Game/Tasks/Friend/FriendChatPage.html",
					name = "FriendChatPage.Show", 
					isShowTitleBar = false,
					DestroyOnClose = true,
					style = CommonCtrl.WindowFrame.ContainerStyle,
					allowDrag = true,
					enable_esc_key = true,
					zorder = -1,
					app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
					directPosition = true,
						align = "_ct",
						x = -760/2,
						y = -583/2,
						width = 760,
						height = 583,
				};
				System.App.Commands.Call("File.MCMLWindowFrame", params);

				-- 
				for k, v in pairs(data.rows) do
					FriendList[v.id] = v
				end
				
				local list = FriendChatPage.GetRecentFromFriendsList()
				for k, v in pairs(list) do
					if v.id == ChatUserData.id then
						FriendChatPage.select_item_id = v.id
					end
					-- FriendList[v.id] = v
				end
				FriendChatPage.Current_Item_DS = list
				-- FriendChatPage.OnRefresh()

				FriendChatPage.CreateChatContentView()
				FriendChatPage.FreshFriendGridView()
				FriendChatPage.IsOpen = true
			end

			FriendManager:LoadAllUnReadMsgs(function ()
				-- 处理未读消息
				FriendChatPage.UnreadMsg = {}
				if FriendManager.unread_msgs and FriendManager.unread_msgs.data then
					for k, v in pairs(FriendManager.unread_msgs.data) do
						FriendChatPage.UnreadMsg[v.latestMsg.senderId] = v
					end
				end



				FriendManager:Connect(ChatUserData.id,function()
					show_callback()
				end)
			end);
		end
	end)


end
function FriendChatPage.OnChange(index)

end
function FriendChatPage.OnRefresh()
    if(page)then
        page:Refresh(0);
    end
end

-- 时间显示
-- 规则：
-- 今日：   时：分
-- 昨天：   昨天
-- 今年：  月-日
-- 往年：  年-月-日
function FriendChatPage.GetTimeDesc(time)
	-- 先获取当前时间
	time = time and tonumber(time) or 0
	local cur_time_t = FriendChatPage.FormatUnixTime2Date(os.time())
	local target_time_t = FriendChatPage.FormatUnixTime2Date(time)

	-- 往年
	if target_time_t.year < cur_time_t.year then
		return DateTool("%Y-%m-%d", time)
	-- 往月
	elseif target_time_t.month < cur_time_t.month then
		return DateTool("%m-%d", time)
	-- 今日
	elseif target_time_t.day == cur_time_t.day then
		return DateTool("%H:%M", time)
	else
		-- 获取当天0点的时间戳
		local temp_time = os.time({day = cur_time_t.day, month = cur_time_t.month, year = cur_time_t.year, hour=0, minute=0, second=0})
		-- 在当天0点的时间戳之前的24小时以内的时间都是昨天
		local limit_sceond = 24 * 60 * 60

		-- 判断是否昨天
		if temp_time - time < limit_sceond then
			return "昨天"
		else
			return DateTool("%m-%d", time)
		end
	end

end

function FriendChatPage.FormatUnixTime2Date(unixTime)
	
    if unixTime and unixTime >= 0 then
        local tb = {}
        tb.year = tonumber(DateTool("%Y",unixTime))
        tb.month =tonumber(DateTool("%m",unixTime))
        tb.day = tonumber(DateTool("%d",unixTime))
        tb.hour = tonumber(DateTool("%H",unixTime))
        tb.minute = tonumber(DateTool("%M",unixTime))
        tb.second = tonumber(DateTool("%S",unixTime))
        return tb
    end
end

function FriendChatPage.DrawConversationNodeHandler2(_parent, treeNode)
	if(_parent == nil or treeNode == nil) then
		return;
	end
	local _this;
	local height = 20; -- just big enough
	local nodeWidth = treeNode.TreeView.ClientWidth;
	local oldNodeHeight = treeNode:GetHeight();

	treeNode.portrait = treeNode.ifmyself and UserData.portrait or treeNode.portrait
	local icon = "Texture/Aries/Creator/keepwork/UserInfo/renwu_32bits.png"

	if treeNode.ifmyself then
		if UserData.portrait and UserData.portrait ~= "" then
			icon = UserData.portrait
		end
	elseif treeNode.portrait and treeNode.portrait ~= "" then
		icon = treeNode.portrait
	end
	local name = treeNode.ifmyself and "我" or treeNode.nickname
	local content_text = treeNode.Text or ""
	
	local mcmlStr = ""

	local lenth, allcount = FriendChatPage.GetStringCharCount(content_text)
	local content_font_size = 14
	local content_text_width = allcount * content_font_size
	local text_width = 390
	local is_more_line = content_text_width > text_width

	local bg_width = content_text_width + 18
	local margin_top = 4
	local height_str = "height:32px"

	if is_more_line then
		bg_width = text_width + 12
		margin_top = 0

		local line_num = math.ceil(content_text_width/text_width)
		local line_inerval = 9
		local height = line_num * content_font_size + (line_num - 1) * line_inerval + 7
		height_str = string.format("height:%s", height)
	end

	if bg_width < 32 then
		bg_width = 32
	end

	if treeNode.ifmyself then
		mcmlStr = string.format([[
			<div style="margin-left:0px;margin-top:0px;padding-left:5px;padding-top:2px;width:500px;">
				<div style="float: left;margin-left:0px;margin-top:5px;">
					<img zorder="0" src='%s'width="46" height="46"/>
				</div>
				<div style="float: left;margin-left: 8px;">
					<div style="margin-top:0px;width:40px;margin-left: 2px;color:#000000">
						%s
					</div>
					<div style="margin-top:0px;width:%s;%s;background:url(Texture/Aries/Creator/keepwork/friends/duihua1_32X32_32bits.png#0 0 32 32:12 22 12 6)">
						<div style="margin-top:%s;margin-left:12px;width:%s;font-size:%s;color:#575757">
							%s
						</div>	
					</div>

				</div>
			</div>
			]], icon , name, bg_width, height_str, margin_top, text_width, content_font_size, content_text);
	else
		local margin_left = is_more_line == false and (text_width - bg_width + 10) or 0
		local text_margin_left = is_more_line and 4 or 0
		-- height_str = "height:64px"
		local align_type = content_text_width > text_width and "left" or "right"
		mcmlStr = string.format([[
			<div style="margin-left:0px;margin-top:0px;padding-left:30px;padding-top:2px;width:500px;">
				<div style="float: left;margin-left: 0px;">
					<div style="margin-top:0px;width:400px;color:#000000;text-align:right">
						%s
					</div>
					<div style="position:relative;margin-top:0px;margin-left:%s;width:%s;%s;background:url(Texture/Aries/Creator/keepwork/friends/duihua2_32X32_32bits.png#0 0 32 32:12 22 12 6)">
					</div>
					<div style="margin-top:%s;margin-left:%s;width:%s;font-size:%s;color:#575757;text-align:%s;">
						%s
					</div>	
				</div>
				<div style="float: left;margin-left:8px;margin-top:6px;">
					<img zorder="0" src='%s'width="46" height="46"/>
				</div>
			</div>
			]] , name, margin_left, bg_width, height_str, margin_top, text_margin_left, text_width, content_font_size, align_type, content_text, icon);
	end
	if(mcmlStr ~= nil) then
		local xmlRoot = ParaXML.LuaXML_ParseString(mcmlStr);
		if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
			local xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
							
			local myLayout = Map3DSystem.mcml_controls.layout:new();
			myLayout:reset(0, 0, nodeWidth-5, height);
			Map3DSystem.mcml_controls.create("bbs_lobby", xmlRoot, nil, _parent, 0, 0, nodeWidth-5, height,nil, myLayout);
			local usedW, usedH = myLayout:GetUsedSize()
			if(usedH>height) then
				return usedH+10;
			end
		end
	end
end

local chatList = {
	["w"] = 0.71, ["q"] = 0.57, ["l"] = 0.14,
	["z"] = 0.43, ["r"] = 0.36, ["t"] = 0.36,
	["y"] = 0.57, ["u"] = 0.57, ["i"] = 0.14,
	["o"] = 0.57, ["p"] = 0.57, ["s"] = 0.43,
	["d"] = 0.57, ["f"] = 0.3,  ["g"] = 0.57,
	["h"] = 0.57, ["j"] = 0.3,  ["x"] = 0.57,
	["v"] = 0.57, ["b"] = 0.57, ["n"] = 0.57,
	["m"] = 0.84,
	["Q"] = 0.71,["W"] = 1,["E"] = 0.57,
	["R"] = 0.65,["T"] = 0.57,["Y"] = 0.57,
	["U"] = 0.65,["I"] = 0.28,["O"] = 0.71,
	["P"] = 0.57,["A"] = 0.57,["S"] = 0.57,
	["D"] = 0.71,["G"] = 0.65,["H"] = 0.65,
	["J"] = 0.43,["K"] = 0.57,["Z"] = 0.57,
	["X"] = 0.57,["C"] = 0.65,["V"] = 0.57,
	["B"] = 0.57,["N"] = 0.65,["M"] = 0.71,
}

function FriendChatPage.GetStringCharCount(str)
    local lenInByte = #str
    local charCount = 0   
	local i = 1
	local allcount = 0
    while (i <= lenInByte)
    do
        local curByte = string.byte(str, i)
		local byteCount = 1;
        if curByte > 0 and curByte <= 127 then
			byteCount = 1                                              --1字节字符
			if chatList[string.char(curByte)] then
				allcount = allcount + chatList[string.char(curByte)]
			elseif curByte <= 46 then
				if curByte == 37 then -- % 
					allcount = allcount + 1
				elseif curByte == 42 then
					allcount = allcount + 0.57
				elseif curByte == 45 then
					allcount = allcount + 0.36
				else
					allcount = allcount + 0.3
				end
			else
				if curByte == 64 then -- @ 
					allcount = allcount + 0.94
				elseif curByte == 94 then --^
					allcount = allcount + 0.73
				elseif curByte == 47 then -- /
					allcount = allcount + 0.36
				elseif curByte >= 48 and curByte <= 57 then -- 数字1-9
					allcount = allcount + 0.57
				elseif curByte >= 58 and curByte <= 59 then
					allcount = allcount + 0.3
				else--字母
					allcount = allcount + 0.5 
				end
			end

		elseif curByte >= 192 and curByte <= 223 then
			byteCount = 2                                              --双字节字符
			allcount = allcount + 1
        elseif curByte >= 224 and curByte <= 239 then
            byteCount = 3                                              --中文
			allcount = allcount + 1
		elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4                                              --4字节字符
			allcount = allcount + 1
		end

        local char = string.sub(str, i, i + byteCount - 1)
        i = i + byteCount                                              -- 重置下一字节的索引
        charCount = charCount + 1                                      -- 字符的个数（长度）
	end
    return charCount, allcount
end

function FriendChatPage.SendMsg()
	local send_text = page:GetValue("sendText") or ""
	page:SetValue("sendText", "")

	if send_text == "" then
		GameLogic.AddBBS("statusBar", L"请输入信息!", 5000, "0 255 0");
		return
	end
	FriendManager:SendMessage(ChatUserData.id, { words = send_text })

	-- local send_text = node:GetValue()


end

-- body={
--     "app/msg",
--     {
--       action="msg",
--       meta={
--         client="meZBlwOs7mONOlZzAABN",
--         target="__chat_1083_1103__",
--         timestamp="2020-09-07 15:07" 
--       },
--       payload={
--         ChannelIndex=25,
--         content="哈哈哈哈试试",
--         id=1083,
--         msgKey="e48cf47d-d0b4-4e6d-9f4f-9415264c2fee",
--         nickname="qq342949687",
--         orgAdmin=0,
--         student=0,
--         tLevel=0,
--         toid=1103,
--         type=4,
--         username="qq342949687",
--         vip=0,
--         worldId=1192 
--       },
--       userInfo={
--         iat=1599462458,
--         machineCode="19eb2894-9e6b-45f3-87f4-30f31ad7eb1a-4C4C4544-0056-3110-804A-C8C04F373433",
--         platform="PC",
--         userId=1083,
--         username="qq342949687" 
--       } 
--     } 
--   },

function FriendChatPage.OnMsg(payload, full_msg)
	if nil == full_msg or nil == payload then
		return
	end

	-- 如果发来消息的人不在好友列表里 说明是打开聊天界面后再成为好友的 这时候要更新好友列表
	if payload.id ~= UserData.id and FriendList[payload.id] == nil then
		FriendChatPage.UpdataFriendList()
	end

	
	if payload.id ~= UserData.id and payload.id ~= ChatUserData.id then
		local list = FriendChatPage.GetRecentFromFriendsList()
		FriendChatPage.Current_Item_DS = list

		FriendChatPage.AddUnReadMsg(payload, full_msg)
		FriendChatPage.FreshFriendGridView()
		return
	end
	local list = FriendChatPage.GetRecentFromFriendsList()
	FriendChatPage.Current_Item_DS = list
	FriendChatPage.FreshFriendGridView()

	local chat_data = {}
	chat_data.Text = payload.content
	chat_data.nickname = ChatUserData.nickname
	chat_data.ifmyself = UserData.id == payload.id

	chat_data.portrait = ChatUserData.portrait or ""
	chat_data.time = os.time()
	
	local ctl = CommonCtrl.GetControl("chat_TreeView");	
	ctl.RootNode:AddChild(CommonCtrl.TreeNode:new(chat_data));
	ctl:Update(true);

	-- 通知服务器已读
	local connection = FriendManager.connections[ChatUserData.id]
	keepwork.friends.updateLastMsgTagInRoom({
		roomId = connection.roomId,
		msgKey = payload.msgKey,
	},function(err, msg, data)
		ChatContent[#ChatContent + 1] = {id = payload.id, content = payload.content, createdAt="", iat = chat_data.time}
	end)
end

function FriendChatPage.GetIcon(data)
	if data.portrait and data.portrait ~= "" then
        return data.portrait
    end

    return "Texture/Aries/Creator/keepwork/UserInfo/renwu_32bits.png"
end

function FriendChatPage.ClearData()
	FriendChatPage.select_item_id = 0
	FriendChatPage.Current_Item_DS = {}
	UserData = {}
	ChatUserData = {}
	FriendChatPage.UnreadMsg = {}
	ChatContent = {}
	FriendList = {}
	TempFriendList = {}
end

function FriendChatPage.CloseView()
	FriendChatPage.SaveChatContent(ChatUserData.id)
	FriendChatPage.IsOpen = false
	FriendChatPage.ClearData()
	FriendManager:ClearAllConnections()

	FriendManager:SaveLastChatMsg()
end

function FriendChatPage.GetChatName()
	return "与" .. ChatUserData.nickname .. "聊天中"
end

function FriendChatPage.ClickItem(id)
	if id == FriendChatPage.select_item_id then
		return
	end

	FriendChatPage.SaveChatContent(ChatUserData.id)

	FriendChatPage.select_item_id = id
	for k, v in pairs(FriendChatPage.Current_Item_DS) do
		if v.id == id then
			ChatUserData = v
			break
		end
	end

	-- ChatUserData = FriendChatPage.Current_Item_DS[item_index] or {}

	FriendChatPage.OnRefresh()

	local connection = FriendManager.connections[ChatUserData.id]
	FriendManager:Connect(ChatUserData.id,function()
		-- 如果connection存在 则说明已经有保存在内存的未读消息 这种情况要重新请求下最新的未读消息
		if connection then
			connection:LoadUnReadMsgs(function (unread_msgs)
				connection.unread_msgs = unread_msgs
				FriendChatPage.CreateChatContentView()
				FriendChatPage.FreshFriendGridView()
			end)
		else
			FriendChatPage.CreateChatContentView()
			FriendChatPage.FreshFriendGridView()
		end


	end)
	
end

function FriendChatPage.IsItemSelect(id)
    return FriendChatPage.select_item_id == id
end

function FriendChatPage.CreateChatContentView()
	local name = "chat_content";
	local chat_content = page:FindUIControl(name);
	local ctl = CommonCtrl.TreeView:new{
		name = "chat_TreeView",
		alignment = "_fi",
		left = 0,
		top = 0,
		width = 0,
		height = 0,
		parent = chat_content,
		container_bg = "",
		DefaultIndentation = 5,
		DefaultNodeHeight = 22,
		VerticalScrollBarStep = 22,
		DrawNodeHandler = FriendChatPage.DrawConversationNodeHandler2,
	};
	local node = ctl.RootNode;
	ctl:Show();

	-- 创建未读消息
	-- local ctl = CommonCtrl.GetControl("chat_TreeView");	
	------------------------------------------------之前的聊天记录------------------------------------------------
	local filepath = string.format("chat_content/%s_%s.txt", UserData.id,ChatUserData.id)
	if( ParaIO.DoesFileExist(filepath)) then
		local file = ParaIO.open(filepath, "r");
		if(file:IsValid()) then
			local text = file:GetText();
			local history_chat_content = commonlib.Json.Decode(text)
			file:close();

			for i, v in ipairs(history_chat_content) do
				local show_data = {}
				show_data.Text = v.content
				show_data.ifmyself = UserData.id == v.id
				
				if show_data.ifmyself == false then
					show_data.nickname = ChatUserData.nickname
					show_data.portrait = ChatUserData.portrait or ""
				end
				ctl.RootNode:AddChild(CommonCtrl.TreeNode:new(show_data));
			end

			ChatContent = history_chat_content
		end
	end
	----------------------------------------------之前的聊天记录/end----------------------------------------------

	------------------------------------------------服务器保存的未读消息------------------------------------------------
	
	local connection = FriendManager.connections[ChatUserData.id]
	if nil == connection then
		return
	end

	if connection.unread_msgs ~= nil and connection.unread_msgs ~= nil then
		local msg_list = connection.unread_msgs
		if connection and msg_list and #msg_list > 0 then
			for index = #msg_list, 1, -1 do
				local chat_data = msg_list[index]
				local show_data = {}
				show_data.Text = chat_data.content
				show_data.ifmyself = UserData.id == chat_data.senderId
				
				if show_data.ifmyself == false then
					show_data.nickname = ChatUserData.nickname
					show_data.portrait = ChatUserData.portrait or ""
				end
				ctl.RootNode:AddChild(CommonCtrl.TreeNode:new(show_data));

				ChatContent[#ChatContent + 1] = {id = chat_data.senderId, content = chat_data.content, createdAt=chat_data.createdAt, iat = ""}
			end
		end
	end
	----------------------------------------------服务器保存的未读消息/end----------------------------------------------

	ctl:Update(true);

	-- 通知服务器消息已读
	connection:UpdateLastMsgTag(function ()
		-- 清除未读消息数量
		if FriendChatPage.UnreadMsg[ChatUserData.id] and FriendChatPage.UnreadMsg[ChatUserData.id].unReadCnt then
			FriendChatPage.UnreadMsg[ChatUserData.id].unReadCnt = 0
			FriendChatPage.FreshFriendGridView()
		end

		-- 清除好友列表未读消息数量
		if FriendsPage.GetIsOpen() then
			FriendsPage.ClearUnReadMsg(ChatUserData.id)
		end

		connection.unread_msgs = {}
	end)	
end

function FriendChatPage.IsShowRedPoint(userId)
	if FriendChatPage.UnreadMsg[userId] and FriendChatPage.UnreadMsg[userId].unReadCnt and FriendChatPage.UnreadMsg[userId].unReadCnt > 0 then
		return true
	end

	return false
end

function FriendChatPage.GetUnReadMsgNum(userId)
	if FriendChatPage.UnreadMsg[userId] and FriendChatPage.UnreadMsg[userId].unReadCnt then
		return FriendChatPage.UnreadMsg[userId].unReadCnt
	end

	return 0
end

function FriendChatPage.AddUnReadMsg(payload, full_msg)

	local num = 1
	local userId = payload.id
	local msg = payload.content
	msg = msg or ""
	if FriendChatPage.UnreadMsg[userId] == nil then
		FriendChatPage.UnreadMsg[userId] = {}
		FriendChatPage.UnreadMsg[userId].unReadCnt = 0
		FriendChatPage.UnreadMsg[userId].latestMsg = {}
	end

	FriendChatPage.UnreadMsg[userId].latestMsg.content = msg
	
	FriendChatPage.UnreadMsg[userId].unReadCnt = FriendChatPage.UnreadMsg[userId].unReadCnt + num

	-- {
	-- 	createdAt="2020-09-07T02:51:17.000Z",
	-- 	id=1,
	-- 	room={
	-- 	  createdAt="2020-09-07T02:51:17.000Z",
	-- 	  id=1,
	-- 	  name="__chat_760_763__",
	-- 	  updatedAt="2020-09-07T02:51:17.000Z" 
	-- 	},
	-- 	roomId=1,
	-- 	unReadCnt=0,
	-- 	updatedAt="2020-09-07T02:51:17.000Z",
	-- 	userId=760 
	--   }
	
end

function FriendChatPage.GetCurChatUesrData()
	return ChatUserData
end

function FriendChatPage.FreshFriendGridView()
	local gvw_name = "item_gridview";
	local node = page:GetNode(gvw_name);
	pe_gridview.DataBind(node, gvw_name, false);
end

-- 保存聊天内容到本地
function FriendChatPage.SaveChatContent(userId)
	local filepath = string.format("chat_content/%s_%s.txt", UserData.id, userId)
	if ChatContent == nil or #ChatContent == 0 then
		return
	end

	local conten_str = commonlib.Json.Encode(ChatContent)
    ParaIO.CreateDirectory(filepath);
	local file = ParaIO.open(filepath, "w");
	if(file:IsValid()) then
		file:WriteString(conten_str);
		file:close();
	end

	ChatContent = {}

	FriendManager:SaveLastChatMsg()
end

function FriendChatPage.GetRecentFromFriendsList()
	-- 有最后一条消息的说明才是最近联系的
	local last_chat_msg = FriendManager:GetLastChatMsg() or {}
	local list = {}
	local id_list = {}
	for key, v in pairs(FriendList) do
		local id = tostring(v.id)
		if last_chat_msg[id] then
			v.last_msg_time_stamp = last_chat_msg[id].time_stamp
			list[#list + 1] = v
		end
	end
	
	
	for key, v in pairs(TempFriendList) do
		local id = tostring(v.id)
		if last_chat_msg[id] == nil and FriendList[v.id] then -- 为空说明是一个全新的会话
			list[#list + 1] = v
		end
	end
	table.sort(list, function(a, b)
		return (a.last_msg_time_stamp > b.last_msg_time_stamp )
	end)

	return list
end

function FriendChatPage.UpdataFriendList(search_text, callback)
	search_text = search_text or ""
	keepwork.user.friends({
		username=search_text,
        headers = {
            ["x-per-page"] = 200,
            ["x-page"] = 1,
        }
	},function(err, msg, data)
		-- commonlib.echo(data, true)
		if err == 200 then
			FriendList = {}
			for k, v in pairs(data.rows) do
				FriendList[v.id] = v
			end

			if callback then
				callback()
			end
		end
	end)
end

function FriendChatPage.FlushCurDataAndView(search_text)
	FriendChatPage.UpdataFriendList(search_text, function ()
		local list = FriendChatPage.GetRecentFromFriendsList()
		FriendChatPage.Current_Item_DS = list
		FriendChatPage.FreshFriendGridView()
	end)
end