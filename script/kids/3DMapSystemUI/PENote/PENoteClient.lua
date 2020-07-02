--[[
Title: PENoteClient
Author(s): Leio
Date: 2009/5/26
Desc:
工作的前提：
	1 用户必须在打开客户端，才能接受到消息
	2 不保存消息，关闭客户端，消息清空
消息的来源：
	1 主要来源于客户端的动态逻辑，比如按一定的时间发送，根据宠物的状态（生病，死亡）等
	2 服务器端向已经运行客户端的用户push一些消息，比如节日快乐等。
消息接收者：
	1 只接收发送给自己的消息
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/PENoteClient.lua");
local nodeClient = Map3DSystem.App.PENote.PENoteClient:new();
nodeClient:SendMessage({"leio"},"126@test.pala5.cn");
------------------------------------------------------------
]]
local PENoteClient = {
	name = "PENoteClient_instance",
	DefaultFile = "script/kids/3DMapSystemUI/PENote/PENoteClient.lua",
	msgPool = {},
	-- event
	OnPush = nil,
	OnPush_Loudspeaker  = nil,--在小喇叭图标中显示
}
commonlib.setfield("Map3DSystem.App.PENote.PENoteClient",PENoteClient);
function PENoteClient:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self;
	o:Init();
	return o
end
function PENoteClient:Init()
	self.name = ParaGlobal.GenerateUniqueID();
	CommonCtrl.AddControl(self.name, self);
	self.msgPool = {};
	self.msgPool_loudspeaker = {};--记录小喇叭里面需要显示的消息
	if(not self.jc)then
		self.jc = JabberClientManager.CreateJabberClient(Map3DSystem.User.jid);
	end
end
function PENoteClient:GetJC()
	return self.jc;
end
function PENoteClient:GetJID()
	return Map3DSystem.User.jid;
end
function PENoteClient:SendMessage(msg,jid)
	commonlib.echo("==============PENoteClient:SendMessage");
	commonlib.echo({msg,jid});
	if(msg and self.jc and jid)then
		self.jc:activate(jid..":"..self.DefaultFile, msg);
	end
end
function PENoteClient:HandleMessage(msg)
	commonlib.echo("==============PENoteClient:HandleMessage");
	commonlib.echo(msg);
	if(not msg)then return end
	if(msg.msg_type == "loudspeaker")then
		table.insert(self.msgPool_loudspeaker,msg);
		if(self.OnPush_Loudspeaker)then
			self.OnPush_Loudspeaker(self);
		end
	else
		table.insert(self.msgPool,msg);
		if(self.OnPush)then
			self.OnPush(self);
		end
	end
end
local function activate()
	if(Map3DSystem.App.PENote.PENote_Client and msg.jckey == Map3DSystem.App.PENote.PENote_Client:GetJID()) then
		Map3DSystem.App.PENote.PENote_Client:HandleMessage(msg)
	end	
end
NPL.this(activate);