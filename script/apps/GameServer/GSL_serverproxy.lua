--[[
Title: epolling style server proxy for client communicating with server. 
Author(s): LiXizhi
Date: 2009/7/30
Desc: Event polling implements a messaging pattern that the client only send another packet when server replies. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_serverproxy.lua");
local proxy = Map3DSystem.GSL.ServerProxy:new({DefaultFile="your_server_neuron_filename.lua", nid="1001", id="1" });
if(proxy:CheckState()) then
	proxy:Send(...);
end
------------------------------------------------------------
]]

local GSL = commonlib.gettable("Map3DSystem.GSL");
local GSL_msg = commonlib.gettable("Map3DSystem.GSL.GSL_msg");

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
	-- whether signed in
	SignedIn = nil,
	-- the last time the client sends message to a server proxy, this is measured by the local clock.  
	LastSendTime,
	-- the last time the client receives message from the server, this is measured by the local clock. 
	LastReceiveTime,
	-- default neuron file
	DefaultFile,
	-- id of this grid node on the server side.
	id,
	-- npl address prefix is precaculated as string.format("(%s)%s:", self.ws_id, self.nid);
	npl_addr_prefix = nil,
	-- game server nid
	nid,
	-- world server id
	ws_id,
	-- cookies: nil or a table containing name value pairs, such as {sk="sessionkeyhere"}
	cookies,
	
	-- default server timeout time
	-- usually if the server is not responding in 20 seconds, we will report to user about connecion lost or unsuccessful. 
	ServerTimeOut = 20000,
	-- we will  retry this number of times if the server time outs. If this is 0, we will never retry, but put to this proxy to proxystate.dead immediately upon first time out.
	MaxTimeOutRetry = 1,
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
	
	-- client time as seen by server
	ct = nil,
	-- last server time as tolde by server
	st = nil,
	-- grid tile pos, it marks the simulation region within the self.worldpath. 
	-- from (x*size, y*size) to (x*size+size, y*size+size),
	-- if self.size is nil, this is just the relative position size in world unit. 
	x=nil,
	y=nil,
	-- grid tile size, if nil, it means infinite size. we always return the smallest sized grid server 
	size=nil,
	-- these are computed on demand
	from_x=nil, from_y=nil, to_x=nil, to_y=nil,
	-- proxy to use on the server side.
	proxy = nil,
}
Map3DSystem.GSL.ServerProxy = ServerProxy;

function ServerProxy:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	if(o.x and o.y) then
		if(o.size) then
			o.from_x= o.x * o.size;
			o.from_y= o.y * o.size;
			o.to_x= o.from_x + o.size;
			o.to_y= o.from_y + o.size;
		else
			o.from_x = o.x;
			o.from_y = o.y;
		end	
	end
	return o
end

-- get the unique key that identifies this proxy. 
-- it is usually the id of the proxy
function ServerProxy:GetKey()
	return self.id;
	-- -- the key is id if no proxy is used. or it is a string of (self.proxy.addr.."/"..self.id)
	--if(self.key) then
		--return self.key
	--else
		--if(self.id) then
			--if(self.proxy and self.proxy.addr) then
				--self.key = self.proxy.addr.."/"..self.id;
			--else
				--self.key= self.id;	
			--end
		--end
		--return self.key;
	--end
end

-- it will send CS_Logout if old connection contains cookies
function ServerProxy:Reset()
	if(self.npl_addr_prefix and self.LastSendTime) then
		self:Send({type = GSL_msg.CS_Logout});
	end
	-- reset cookis and state
	self.state = proxystate.none;
	self.LastSendTime = nil;
	self.LastReceiveTime = nil;
	self.cookies = nil;
	self.SignedIn = nil;
	self.ct = 0;
	self.st = 0;
	self.recoverlist = nil;
	self.nid = nil;
	self.ws_id = nil;
	self.proxy = nil;
	self.key = nil;
end

-- reinit the server proxy with a game server nid and world server id
-- if both nid and ws_id are "",  it is the current thread. 
-- @param nid: the game server nid
-- @param ws_id: world server id inside the game server. it is also the NPL runtime state name. 
-- @param worldpath: the new world path. 
function ServerProxy:Init(nid, ws_id, worldpath)
	self.npl_addr_prefix = (nid == "localuser" and ws_id=="") and "" or string.format("(%s)%s:", tostring(ws_id), tostring(nid));
	self.worldpath = worldpath;
	self.nid = nid;
	self.ws_id = ws_id;
	self:MakeReady();
end

-- log out only if it has signed in before 
-- but retains session key and self.st and put the proxy to ready state. 
-- NOTE: this proxy can be reused when the client need it again, since it retains all session key and server time (self.st). 
function ServerProxy:Logout()
	if(self.npl_addr_prefix and self.LastSendTime) then
		self:Send({type = GSL_msg.CS_Logout});
		-- reset cookis and state
		self.state = proxystate.ready;
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
-- they are only same when the nid, world path and region all matches. 
function ServerProxy:IsEqual(proxy)
	return (self.worldpath == proxy.worldpath and self.nid == proxy.nid and self.x==proxy.x and self.y==proxy.y and self.size==proxy.size);
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

-- this is called when connection is lost. 
function ServerProxy:OnConnectionLost()
	-- report and reconnect?, or just let the default handler to deal with it. 
end

-- send a message to server using this proxy. 
-- @param msg: msg to send
-- @param neuronfile: if nil, self.DefaultFile is used. 
-- @param bRealtime: if true, self.state and self.LastSendTime will not be mordified. default to nil. 
function ServerProxy:Send(msg, neuronfile, bRealtime)
	-- inject grid node id, if any.
	msg.id = self.id;
	-- inject proxy setting, if any.
	msg.proxy = self.proxy;
	
	if(GSL.dump_client_msg) then
		GSL.dump("Client->Server"..commonlib.serialize_compact(msg));
	end
	
	-- inject cookies if any. 
	--if(self.cookies) then
		--commonlib.mincopy(msg, self.cookies);
	--end	
	
	if(self.npl_addr_prefix) then
		if(self.npl_addr_prefix == "") then
			msg.nid = msg.nid or "localuser";
		end
		if(NPL.activate(self.npl_addr_prefix..(neuronfile or self.DefaultFile), msg)~=0) then
			self:OnConnectionLost();
			LOG.std("", "warning", "GSL", "unable to connect to server. Connection is lost");
		end
		-- commonlib.applog({is_realtime=tostring(bRealtime), msg});
		
		if(not bRealtime) then	
			-- make the proxy waiting for reply
			self.state = proxystate.waiting;
			self.LastSendTime = ParaGlobal.timeGetTime();
		end	
	else
		LOG.std("", "warning", "GSL", "server proxy address unassigned");
	end	
	return true;
end

-- call this function whenever the proxy has a response from the server. 
-- it makes the proxy ready to send another message. 
function ServerProxy:OnRespond()
	self.LastReceiveTime = ParaGlobal.timeGetTime();
	self.state = proxystate.ready;
end

-- update session key
-- @param sk: please pass nil, because session key is not needed in NPL network layer
-- @param bInsertToCookie: if true, it will insert sk to cookies, so that sk will be sent along with all subsequent Send calls. 
function ServerProxy:UpdateSessionKey(sk, bInsertToCookie)
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
	if(self.LastSendTime) then
		local timeElapsed = ParaGlobal.timeGetTime()-self.LastSendTime
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
		local timeElapsed = (curTime or ParaGlobal.timeGetTime())-self.LastSendTime;
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
		local opcode_nid = Map3DSystem.GSL.opcode.opcode_nid;
		local nidname = opcode_nid:write(agent.nid);
		if(nidname) then
			if(not self.recoverlist) then
				self.recoverlist = nidname;
				return true;
			else
				local bExist;
				local nid;
				local count = 0;
				for nid in string.gmatch(self.recoverlist, "[^,]+") do
					count = count+1;
					if(nid == nidname) then
						bExist = true
						break;
					end
				end
				if(bExist) then
					return true
				elseif(count < self.maxrecoversize) then
					self.recoverlist = self.recoverlist..","..nidname;
					return true
				end
			end
		end
	end
end

-- output a log message
function ServerProxy:log(...)
	LOG.std("", "info", "GSL", LOG.tostring("(%s): ", tostring(self.npl_addr_prefix))..LOG.tostring(...));
end

-- output to log. for debugging only.
function ServerProxy:Dump()
	LOG.std("", "info", "GSL", LOG.tostring("dump proxy %s, id:%s, key:%s, worldpath=%s,", tostring(self.npl_addr_prefix), tostring(self.id), tostring(self:GetKey()), tostring(self.worldpath))..LOG.tostring("st:%s, ct:%s, sk:%s, size:%s\n", tostring(self.st), tostring(self.ct), tostring(self.sk), tostring(self.size)));
end
-- OBSOLETED: the GSL_client no longer uses CheckState() before sending a normal update.
-- instead, the normal update is always sent on the client at fixed internal. 
-- update the self.state according to the current time.
-- it will change the state from wait to timeout if the server is not responding since last send
-- @return: return true if state is not proxystate.waiting. state is either ready or timeout reached
function ServerProxy:CheckState(curTime)
	curTime = curTime or ParaGlobal.timeGetTime()
	
	if(self.state == proxystate.waiting and self.LastSendTime) then
		if((curTime - self.LastSendTime) > self.ServerTimeOut) then
			self.state = proxystate.timeout;
		end
	end
	return (self.state~=proxystate.waiting);
end