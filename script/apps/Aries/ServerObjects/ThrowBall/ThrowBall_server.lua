--[[
Title: Server agent template class
Author(s): 
Date: 2010/04/24
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/CatchFish/30388_CatchFish_server.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");

-------------------------------------
-- a special server NPC that just echos whatever received. 
-------------------------------------
local CatchFish_server = {
}
Map3DSystem.GSL.config:RegisterNPCTemplate("catchfish", CatchFish_server)
local totalPlace = 12;--����λ�õ�����
local totalLivedSec = 61;--ÿ�ֵ���ʱ�� ��
local totalWaitSec = 20;--�ȴ���ʼ��ʱ��
local fisher = {

}
local k;
for k = 1, totalPlace do
	fisher[k] = { 
			nid = nil,
			canstart = false, 
			lived_sec = 0, 
			wait_sec = 0, --����������λ�ñ�ĳ��nidռ�ݣ��ȴ�totalWaitSec��ʱ�䣬���û���յ���ʼ������������λ�ã�
						  --����յ�����canstart = true,������Ϸ��ʱ��ʼ
			lastfishtime = 0;
		};
end
function CatchFish_server.CanStart(index)
	if(not index)then return end
	local item = fisher[index];
	return item.isdead;
end
function CatchFish_server.ResetItem(v)
	if(v)then
		v.nid = nil;
		v.canstart = false;
		v.lived_sec = 0;
		v.wait_sec = 0;
	end
end
function CatchFish_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = CatchFish_server.OnNetReceive;
	self.OnFrameMove = CatchFish_server.OnFrameMove;
end
-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function CatchFish_server:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		if(string.find(msg.body, "%[Aries%]") == 1) then
			local index = string.match(msg.body, "^%[Aries%]%[ServerObject30388%]CheckStart:(%d+)$");
			index = tonumber(index);
			if(index and index <= totalPlace)then
				local k,v;
				for k,v in ipairs(fisher) do
					--ȷ��һ���û�ֻ����һ�������
					if(v.nid and v.nid == from_nid)then
						return
					end 
				end
				local item = fisher[index];
				--nid Ϊ�գ����Ե���
				if(not item.nid)then
					--���Ե���
					item.nid = from_nid;
					item.lived_sec = 0;
					item.canstart = false;
					
					local msg = "[Aries][ServerObject30388]CheckStartRecv:true";
					self:SendRealtimeMessage(from_nid, msg);
				else
					--������
					local msg = "[Aries][ServerObject30388]CheckStartRecv:false";
					self:SendRealtimeMessage(from_nid, msg);
				end
			end
			local index = string.match(msg.body, "^%[Aries%]%[ServerObject30388%]DoStart:(%d+)$");
			index = tonumber(index);
			if(index)then
				local item = fisher[index];
				if(item and item.nid and item.nid == from_nid)then
					item.canstart = true;
					local msg = "[Aries][ServerObject30388]DoStartRecv:true";
					self:SendRealtimeMessage(from_nid, msg);
				end
			end
			local index = string.match(msg.body, "^%[Aries%]%[ServerObject30388%]DoQuit:(%d+)$");
			index = tonumber(index);
			if(index)then
				local item = fisher[index];
				if(item and item.nid and item.nid == from_nid)then
					--reset a item
					CatchFish_server.ResetItem(item);
					local msg = "[Aries][ServerObject30388]DoQuitRecv:true";
					self:SendRealtimeMessage(from_nid, msg);
				end
			end
			local index = string.match(msg.body, "^%[Aries%]%[ServerObject30388%]DoQuitInternal:(%d+)$");
			index = tonumber(index);
			if(index)then
				local item = fisher[index];
				if(item and item.nid and item.nid == from_nid)then
					--reset a item
					CatchFish_server.ResetItem(item);
					local msg = "[Aries][ServerObject30388]DoQuitInternalRecv:true";
					self:SendRealtimeMessage(from_nid, msg);
				end
			end
			--���¿�ʼ��Ϸ��ʱ������
			local index = string.match(msg.body, "^%[Aries%]%[ServerObject30388%]DoReStart:(%d+)$");
			index = tonumber(index);
			if(index)then
				local item = fisher[index];
				if(item and item.nid and item.nid == from_nid)then
					item.lived_sec = 0;
					local msg = "[Aries][ServerObject30388]DoReStartRecv:true";
					self:SendRealtimeMessage(from_nid, msg);
				end
			end
			-- �����Զ�������ʱ���Ƿ���ȷ
			local index = string.match(msg.body, "^%[Aries%]%[ServerObject30388%]DoAutoFishing:(%d+)$");
			index = tonumber(index);
			if(index)then
				local item = fisher[index];
				local curtime = tonumber(commonlib.TimerManager.GetCurrentTime());
				if(item and item.nid and item.nid == from_nid and (curtime - item.lastfishtime) >= 1500)then
					item.lastfishtime = curtime;
					local msg = "[Aries][ServerObject30388]DoAutoFishingRecv:true";
					self:SendRealtimeMessage(from_nid, msg);
				end
			end
		end
	end
end
local nextupdate_time = 0;
local cur_sec = 0;
-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function CatchFish_server:OnFrameMove(curTime, revision)
	if(curTime > nextupdate_time) then
		local duration = 1;
		--ÿ�����ڸ���һ��
		nextupdate_time = curTime + duration * 1000;
		cur_sec = cur_sec + duration;
		for k,v in ipairs(fisher) do
			
			if(v and v.lived_sec)then
				local canstart = v.canstart;
				local nid = v.nid;
				if(nid)then
					if(canstart)then
						local lived_sec  = v.lived_sec + 1;--ÿ�����һ��
						v.lived_sec = lived_sec;
						if(lived_sec > totalLivedSec)then
							--reset a item
							CatchFish_server.ResetItem(v);
							local msg = "[Aries][ServerObject30388]OnTimeover:true";
							self:SendRealtimeMessage(nid, msg);
						else
							local msg = "[Aries][ServerObject30388]OnFramemove:"..lived_sec;
							self:SendRealtimeMessage(nid, msg);
						end
					else
						v.wait_sec = v.wait_sec or 0;
						v.wait_sec = v.wait_sec + 1;
						--�ȴ��û�ȷ�Ͽ�ʼ���������ʱ�䣬�Զ��߳�
						if(v.wait_sec > totalWaitSec)then
							v.wait_sec = 0;
							local msg = "[Aries][ServerObject30388]DoQuitInternalRecv:true";
							self:SendRealtimeMessage(nid, msg);
							--reset a item
							CatchFish_server.ResetItem(v);
						end
					end
				end
			end
		end
		--commonlib.echo("===========CatchFish_server:OnFrameMove");
		--commonlib.echo(cur_sec);
		--commonlib.echo(max_lived_sec);
		--
		--commonlib.echo(fisher);
		local max_lived_sec = 600;
		
		if(cur_sec >= max_lived_sec)then
			nextupdate_time = 0;
			cur_sec = 0;
		end
	end
end

