--[[
Title: epolling style server proxy for client communicating with server. 
Author(s): LiXizhi
Date: 2008/12/23
Desc: Event polling implements a messaging pattern that the client only send another packet when server replies. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_serverproxy.lua");
local proxy = Map3DSystem.JGSL.ServerProxy:new({DefaultFile="your_server_neuron_filename.lua"});
if(proxy:CheckState()) then
	proxy:Send(...);
end
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
	-- the server is timed out at least once
	timeout = 3,
	-- the server is dead, because it has timed out too many times. 
	dead = 5,
}

------------------------------------
-- a server proxy is used by client to communicate with a epoll server. 
------------------------------------
local ServerProxy = {
	-- nil means we are ready to send a packet.
	state = proxystate.none,
	-- the last time the client sends message to a server proxy, this is measured by the local clock.  
	LastSendTime,
	-- the last time the client receives message from the server, this is measured by the local clock. 
	LastReceiveTime,
	-- default neuron file
	DefaultFile,
	-- JID 
	jid,
	-- the jabber client to use. if nil, JGSL.GetJC() is used. 
	jc,
	-- whether we have signed in to the server and has its session key in cookies,
	SignedIn,
	-- cookies: nil or a table containing name value pairs, such as {sk="sessionkeyhere"}
	cookies,
	-- id of this grid node on the server side.
	id,
	
	-- default server timeout time
	-- usually if the server is not responding in 20 seconds, we will report to user about connecion lost or unsuccessful. 
	ServerTimeOut = 20000,
	-- we will  retry this number of times if the server time outs. If this is 0, we will never retry, but put to this proxy to proxystate.dead immediately upon first time out.
	MaxTimeOutRetry = 1,
	-- how many timeout retry times we have done. 
	TimeOutCount = 0,
	-- default keep alive interval
	KeepAliveInterval = 10000,
	
	-- the following is just for grid server proxy. host user id in paraworldAPI
	uid = nil,
	-- The role that the server assigned to this client. It can be one of the "guest", "administrator", "friend". 
	UserRole = "guest",
	
	-- we will recover at most maxrecoversize number of intact agents at a time. 
	maxrecoversize = 5,
	-- a commar separated string containing the nid of to be recovered agents. 
	recoverlist = nil,
	
	-- world path: worlds/MyWorlds/ABC
	worldpath = nil,
	-- world name: my_worlds
	worldname = nil,
	-- description
	desc = nil,
	-- current online user number
	OnlineUserNum = 0,
	StartTime = 0,
	VisitsSinceStart = 0,
	ServerVersion = 0, 
	ClientVersion = 0, 
	-- server session key, it is assigned when connected with a remote server. sk is forwarded for each client to server packet. 
	sk = nil,
	-- client time as seen by server
	ct = nil,
	-- last server time as tolde by server
	st = nil,
	-- grid tile pos, it marks the simulation region within the self.worldpath. 
	-- from (x*size, y*size) to (x*size+size, y*size+size)
	x=nil,
	y=nil,
	-- grid tile size, if nil, it means infinite size. we always return the smallest sized grid server 
	size=nil,
	-- these are computed on demand
	from_x=nil, from_y=nil, to_x=nil, to_y=nil,
}
Map3DSystem.JGSL.ServerProxy = ServerProxy;

function ServerProxy:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	if(o.x and o.size and o.y) then
		o.from_x= o.x * o.size;
		o.from_y= o.y * o.size;
		o.to_x= o.from_x + o.size;
		o.to_y= o.from_y + o.size;
	end
	return o
end

-- it will send CS_Logout if old connection contains cookies
function ServerProxy:Reset()
	if(self.jid and self.cookies and self.SignedIn and self.LastSendTime) then
		self:Send({type = JGSL_msg.CS_Logout});
	end
	-- reset cookis and state
	self.state = proxystate.none;
	self.LastSendTime = nil;
	self.LastReceiveTime = nil;
	self.cookies = nil;
	self.SignedIn = nil;
	self.TimeOutCount = 0;
	self.ct = 0;
	self.st = 0;
	self.recoverlist = nil;
end

-- log out only if it has signed in before 
-- but retains session key and self.st and put the proxy to ready state. 
-- NOTE: this proxy can be reused when the client need it again, since it retains all session key and server time (self.st). 
function ServerProxy:Logout()
	if(self.jid and self.cookies and self.SignedIn and self.LastSendTime) then
		self:Send({type = JGSL_msg.CS_Logout});
		-- reset cookis and state
		self.state = proxystate.ready;
		self.TimeOutCount = 0;
		-- reset client time, so that the next time it connects to this proxy, it will send full agent info again. 
		self.ct = 0;
		-- retain server time.
		-- self.st = 0;
		self.recoverlist = nil;
	end
end

-- check whether this grid node allow users to edit the world
-- @param rule: if nil, it means  editing right. 
function ServerProxy:CanEdit()
	return (self.UserRole~="guest");
end

-- return true if the input proxy is same as self.
-- they are only same when the jid, world path and region all matches. 
function ServerProxy:IsEqual(proxy)
	return (self.worldpath == proxy.worldpath and self.jid == proxy.jid and self.x==proxy.x and self.y==proxy.y and self.size==proxy.size);
end

-- whether this node contains the 3d point x,y,z in worldpath
function ServerProxy:Contains(worldpath,x,y,z)
	if(self.worldpath == worldpath) then
		if(self.size and self.from_x) then
			return (self.from_x<=x and self.to_x>x and self.from_y<=z and self.to_y>z);
		else
			return true;
		end
	end
end

function ServerProxy:GetJC()
	if(not self.jc) then
		self.jc = JGSL.GetJC();
	end
	return self.jc
end

-- send a message to server using this proxy. 
-- @param msg: msg to send
-- @param neuronfile: if nil, self.DefaultFile is used. 
function ServerProxy:Send(msg, neuronfile)
	if(JGSL.dump_client_msg) then
		commonlib.echo(msg)
	end
	
	local jc = self:GetJC();
	if(jc) then
		-- inject cookies packet. 
		if(self.cookies) then
			commonlib.mincopy(msg, self.cookies);
		end	
		
		if(self.jid) then
			jc:activate(self.jid..":"..(neuronfile or self.DefaultFile), msg);
			
			-- increase time out message count
			if(self.TimeOutCount > 0) then
				self.TimeOutCount = self.TimeOutCount + 1
			end
			-- make the proxy waiting for reply
			self.state = proxystate.waiting;
			self.LastSendTime = ParaGlobal.GetGameTime();
		else
			log("warning: ServerProxy.jid not specified in send call\n");
		end	
		return true;
	else
		self.state = proxystate.none;
	end
end

-- call this function whenever the proxy has a response from the server. 
-- it makes the proxy ready to send another message. 
function ServerProxy:OnRespond()
	self.LastReceiveTime = ParaGlobal.GetGameTime();
	self.state = proxystate.ready;
	self.TimeOutCount = 0;
end

-- update session key
-- @param bInsertToCookie: if true, it will insert sk to cookies, so that sk will be sent along with all subsequent Send calls. 
function ServerProxy:UpdateSessionKey(sk, bInsertToCookie)
	self.sk = sk;
	self.SignedIn = true;
	if (bInsertToCookie) then
		self.cookies = self.cookies or {}
		self.cookies["sk"] = sk;
	end
end

-- whether the proxy is in ready state
-- ready state means that the proxy is connected and not waiting for response. 
function ServerProxy:IsReady()
	return self.state == proxystate.ready;
end

-- force the proxy to ready state
function ServerProxy:MakeReady()
	self.state = proxystate.ready;
end

-- whether deltaTime is passed since the last time that we send message to server.
-- if return true, we usually need to send a normal update to server to keep the client alive. 
-- @param deltaTime: in milliseconds. usually several times the normal update interval. If nil, self.KeepAliveInterval is used. 
function ServerProxy:IsKeepAlive(deltaTime)
	if(self.SignedIn and self.LastSendTime) then
		local timeElapsed = ParaGlobal.GetGameTime()-self.LastSendTime
		if(timeElapsed>(deltaTime or self.KeepAliveInterval)) then
			return true;
		end
	end
end

-- whether the server is dead
function ServerProxy:IsDead()
	return (self.state==proxystate.dead);
end

-- return true if we are not receiving server response for too long
function ServerProxy:IsTimeOut(curTime)
	if( self.LastSendTime ) then 
		local timeElapsed = (curTime or ParaGlobal.GetGameTime())-self.LastSendTime;
		if(timeElapsed > self.ServerTimeOut) then
			-- report server time out. 
			return true;
		end
	end	
end

-- append to the recover list of this proxy. 
-- the recover list has a max size. if max size is reached, we will ignore and return nil.
-- @return: return true if added to recover list or already added before.  
function ServerProxy:AddToRecoverList(agent)
	if(agent) then
		-- send all client agents updates to client
		local opcode_jid = Map3DSystem.JGSL.opcode.opcode_jid;
		local jidname = opcode_jid:write(agent.jid);
		if(jidname) then
			if(not self.recoverlist) then
				self.recoverlist = jidname;
				return true;
			else
				local bExist;
				local jid;
				local count = 0;
				for jid in string.gmatch(self.recoverlist, "[^,]+") do
					count = count+1;
					if(jid == jidname) then
						bExist = true
						break;
					end
				end
				if(bExist) then
					return true
				elseif(count < self.maxrecoversize) then
					self.recoverlist = self.recoverlist..","..jidname;
					return true
				end
			end
		end
	end
end

-- output a log message
function ServerProxy:log(...)
	commonlib.log("log: (%s): ", tostring(self.jid));
	commonlib.log(...)
	log("\n")
end

-- output to log. for debugging only.
function ServerProxy:Dump()
	commonlib.log("dump proxy %s, id:%s, signedin=%s, worldpath=%s,", tostring(self.jid), tostring(self.id), tostring(self.SignedIn), tostring(self.worldpath));
	commonlib.log("st:%s, ct:%s, sk:%s, size:%s\n", tostring(self.st), tostring(self.ct), tostring(self.sk), tostring(self.size));
end

-- update the self.state according to the current time.
-- it will change the state from wait to timeout if the server is not responding since last send
-- @return: return true if state is proxystate.ready or proxystate.timeout, meaning that u should send an update immediately. 
function ServerProxy:CheckState(curTime)
	curTime = curTime or ParaGlobal.GetGameTime()
	
	if(self.state == proxystate.waiting and self.LastSendTime) then
		if((curTime - self.LastSendTime) > self.ServerTimeOut) then
			self.state = proxystate.timeout;
			if(self.TimeOutCount == 0) then
				self.TimeOutCount = 1;
			end
			if(self.TimeOutCount > self.MaxTimeOutRetry) then
				-- max time out count reached, make the proxy dead. 
				self.state = proxystate.dead;
			end
		end
	end
	return (self.state==proxystate.ready) or (self.state==proxystate.timeout);
end