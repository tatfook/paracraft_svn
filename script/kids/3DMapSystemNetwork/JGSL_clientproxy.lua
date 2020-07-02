--[[
Title: client proxy for server communicating with client
Author(s): LiXizhi
Date: 2008/12/25
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_clientproxy.lua");
local proxy = Map3DSystem.JGSL.ClientProxy:new({DefaultFile="your_client_neuron_filename.lua"});
------------------------------------------------------------
]]

if(not Map3DSystem.JGSL) then Map3DSystem.JGSL={} end
local JGSL = Map3DSystem.JGSL;
local JGSL_msg = Map3DSystem.JGSL_msg;

-- proxy status
local proxystate = {
	-- proxy is reset
	none = nil,
	-- waiting for server response
	waiting = 1,
	-- server already responded, the client can send message at anytime
	ready = 2,
}

------------------------------------
-- a server proxy is used by client to communicate with a epoll server. 
------------------------------------
local ClientProxy = {
	-- nil means we are ready to send a packet.
	state = proxystate.none,
	-- the last time the client sends message to a server proxy, this is measured by the local clock.  
	LastSendTime,
	-- the last time the client receives message from the server, this is measured by the local clock. 
	LastReceiveTime,
	-- default neuron file
	DefaultFile = "script/kids/3DMapSystemNetwork/JGSL_client.lua",
	-- proxy role
	UserRole = "guest",
	-- JID 
	jid,
	-- the jabber client to use. if nil, JGSL.GetJC() is used. 
	jc,
	-- whether we have signed in to the server and has its session key in cookies,
	SignedIn,
	-- cookies: nil or a table containing name value pairs, such as {sk="sessionkeyhere"}
	cookies,
	-- default server timeout time
	-- usually if the server is not responding in 20 seconds, we will report to user about connecion lost or unsuccessful. 
	ServerTimeOut = 20000,
}

Map3DSystem.JGSL.ClientProxy = ClientProxy;

function ClientProxy:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- it will send CS_Logout if old connection contains cookies
function ClientProxy:Reset()
	if(self.jid and self.cookies and self.SignedIn and self.LastSendTime) then
		self:Send({type = JGSL_msg.SC_Closing});
	end
	-- reset cookis and state
	self.state = proxystate.none;
	self.LastSendTime = nil;
	self.LastReceiveTime = nil;
	self.cookies = nil;
	self.SignedIn = nil;
end


-- send a message to server using this proxy. 
-- @param msg: msg to send
-- @param neuronfile: if nil, self.DefaultFile is used. 
function ClientProxy:Send(jid, msg, neuronfile)
	if(JGSL.dump_client_msg) then
		commonlib.echo(msg);
	end
	
	local jc = self.jc or JGSL.GetJC();
	if(jc) then
		-- inject cookies packet. 
		if(self.cookies) then
			commonlib.mincopy(msg, self.cookies);
		end	
		
		if(jid) then
			jc:activate(jid..":"..(neuronfile or self.DefaultFile), msg);
			-- make the proxy waiting for reply
			self.state = proxystate.waiting;
			self.LastSendTime = ParaGlobal.GetGameTime();
		else
			log("warning: ClientProxy.jid not specified in send call\n");
		end	
		return true;
	else
		self.state = proxystate.none;
	end
end

-- call this function whenever the proxy has a response from the server. 
-- it makes the proxy ready to send another message. 
function ClientProxy:OnRespond()
	self.LastReceiveTime = ParaGlobal.GetGameTime();
	self.state = proxystate.ready;
end

-- update session key
-- @param bInsertToCookie: if true, it will insert sk to cookies, so that sk will be sent along with all subsequent Send calls. 
function ClientProxy:UpdateSessionKey(sk)
	self.sk = sk;
	if (bInsertToCookie) then
		self.cookies = self.cookies or {}
		self.cookies["sk"] = sk;
	end
end

-- whether the proxy is in ready state
-- ready state means that the proxy is connected and not waiting for response. 
function ClientProxy:IsReady()
	return self.state == proxystate.ready;
end

-- force the proxy to ready state
function ClientProxy:MakeReady()
	self.state = proxystate.ready;
end

-- whether deltaTime is passed since the last time that we send message to server.
-- if return true, we usually need to send a normal update to server to keep the client alive. 
-- @param deltaTime: in milliseconds. usually several times the normal update interval. If nil, self.KeepAliveInterval is used. 
function ClientProxy:IsKeepAlive(deltaTime)
	if(self.SignedIn and self.LastSendTime) then
		local timeElapsed = ParaGlobal.GetGameTime()-self.LastSendTime
		if(timeElapsed>(deltaTime or self.KeepAliveInterval)) then
			return true;
		end
	end
end

-- return true if we are not receiving server response for too long
function ClientProxy:IsTimeOut()
	if( self.LastSendTime ) then 
		local timeElapsed = ParaGlobal.GetGameTime()-self.LastSendTime;
		if(timeElapsed > self.ServerTimeOut) then
			-- report server time out. 
			return true;
		end
	end	
end