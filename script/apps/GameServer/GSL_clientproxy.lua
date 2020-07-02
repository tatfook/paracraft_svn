--[[
Title: client proxy for server communicating with client
Author(s): LiXizhi
Date: 2009/7/30
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_clientproxy.lua");
local proxy = Map3DSystem.GSL.ClientProxy:new({DefaultFile="your_client_neuron_filename.lua"});
------------------------------------------------------------
]]
local GSL = commonlib.gettable("Map3DSystem.GSL");
local GSL_msg = commonlib.gettable("Map3DSystem.GSL.GSL_msg");
local LOG = LOG;

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
	DefaultFile = "script/apps/GameServer/GSL_client.lua",
	-- proxy role
	UserRole = "guest",
	-- cookies: nil or a table containing name value pairs, such as {sk="sessionkeyhere"}
	cookies,
	-- default server timeout time
	-- usually if the server is not responding in 20 seconds, we will report to user about connecion lost or unsuccessful. 
	ServerTimeOut = 20000,
}

Map3DSystem.GSL.ClientProxy = ClientProxy;

function ClientProxy:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- it will send CS_Logout if old connection contains cookies
function ClientProxy:Reset()
	if(self.nid and self.LastSendTime) then
		self:Send({type = GSL_msg.SC_Closing});
	end
	-- reset cookis and state
	self.state = proxystate.none;
	self.LastSendTime = nil;
	self.LastReceiveTime = nil;
	self.cookies = nil;
end

-- this is called when connection is lost. 
function ClientProxy:OnConnectionLost()
	-- report and reconnect?, or just let the default handler to deal with it. 
end

-- send a message to server using this proxy. 
-- @param msg: msg to send
-- @param neuronfile: if nil, self.DefaultFile is used. 
-- @param bRealtime: if true, self.state and self.LastSendTime will not be mordified. default to nil. 
function ClientProxy:Send(nid, msg, neuronfile, bRealtime)
	if(GSL.dump_server_msg) then
		LOG.std("", "system", "GSL", "ClientProxy:Send"..LOG.tostring(msg));
	end

	-- inject cookies packet. Cookies are ignored in this version. 
	--if(self.cookies) then
		--commonlib.mincopy(msg, self.cookies);
	--end
	
	if(nid) then
		if(NPL.activate(nid..":"..(neuronfile or self.DefaultFile), msg)~=0) then
			self:OnConnectionLost();
			LOG.std("", "warning", "GSL", "unable to connect to client. Connection is lost");
		end
		if(not bRealtime) then
			-- make the proxy waiting for reply
			self.state = proxystate.waiting;
			self.LastSendTime = ParaGlobal.timeGetTime();
		end
	else
		LOG.std("", "warning", "GSL", "ClientProxy nid not specified in send call");
	end
	return true;
end

-- call this function whenever the proxy has a response from the server. 
-- it makes the proxy ready to send another message. 
function ClientProxy:OnRespond()
	self.LastReceiveTime = ParaGlobal.timeGetTime();
	self.state = proxystate.ready;
end

-- update session key
-- @param bInsertToCookie: if true, it will insert sk to cookies, so that sk will be sent along with all subsequent Send calls. 
function ClientProxy:UpdateSessionKey(sk)
	self.sk = sk;
	if (bInsertToCookie) then
		if(sk) then
			LOG.std("", "warning", "GSL", "session key is not needed in NPL network layer");
			self.cookies = self.cookies or {}
			self.cookies["sk"] = sk;
		end	
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
	if(self.LastSendTime) then
		local timeElapsed = ParaGlobal.timeGetTime()-self.LastSendTime
		if(timeElapsed>(deltaTime or self.KeepAliveInterval)) then
			return true;
		end
	end
end

-- return true if we are not receiving server response for too long
function ClientProxy:IsTimeOut()
	if( self.LastSendTime ) then 
		local timeElapsed = ParaGlobal.timeGetTime()-self.LastSendTime;
		if(timeElapsed > self.ServerTimeOut) then
			-- report server time out. 
			return true;
		end
	end	
end