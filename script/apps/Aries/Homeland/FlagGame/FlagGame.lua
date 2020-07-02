--[[
Title: Flag Game
Author(s): LXZ  for leio
Date: 2010/1/30
Desc:��԰�����ӵ���Ϸ��������Щϸ�ڣ�ʹ֮�����Ժ���Ȥ��ǿ��
[����] ������6�����ģ� ����7ɫ���� ͳ��ʱ�䡣 ���԰������ӱ��˳��ʰȡ����׼�֣���Ҳ���Բ�������С�֣���
�ֱ������ֵ÷֡� 
1. ��ʼֻ��ʾ1�棬 ʰȡ�� ��������7ɫ����UI����һ�����¼�ʱ��ť���� 3D��������ʾ������5���λ�á� 
2. �༭״̬�£���ʾ6�棬λ�ø���NID����� 
3. ��ս�ߵĽ��������ʱ�䣨��׼�֣��ҹ��� ������׼����654321��Ȼ��Shift�������ģ�
   ��С��Ҫѡ�����Ĵ���������Ծ��Shift��ϲ��С� ��ս���õ���һ��ʱ��һ������������ 
4. ������ֻҪ�����õ���һ��ʱ�Ϳ��Ը������� �����Ľ���������ս�߶�����ջ� 
5. 6�涼�õ������ʱ��<30����ˢ�¸�����óɼ����ˣ� �Զ��ڼ���ϵͳ�з���Ϣ��XXX��ս��XXX�ļ�԰��ʱXX�롣 
   ������������ߣ� ��IM��Ϣ�������ߣ� ������ֻ��ʾ��ʱ�յ��������µı�׼��/��С�ֵ�IM֪ͨ�� 
   ���������߿��Ը�����֯һЩ��ս�Ͱ佱�

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Homeland/FlagGame/FlagGame.lua");

MyCompany.Aries.Homeland.FlagGame.BeginGame()
MyCompany.Aries.Homeland.FlagGame.EndGame()
------------------------------------------------------------
]]

local FlagGame = commonlib.gettable("MyCompany.Aries.Homeland.FlagGame");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;

-- current flags for nid. 
local flags = {
	-- {x = 0,y = 0,z = 0, touch_time = 0, is_touched = false},
	-- {x = 0,y = 1,z = 0, touch_time = 0, is_touched = false},
}

-- this is called when homeland is loaded. 
-- @param nid: string of user nid. it is used as the random seed to generate all the flag positions. So that different users are different. 
--    if nil, it is the current user nid. 
function FlagGame.BeginGame(nid)
	nid = nid or System.User.nid;
	FlagGame.GenerateFlags(nid)
	FlagGame.ShowFlags(1);
end

-- this is called when homeland is unloaded. 
function FlagGame.EndGame()
	FlagGame.ShowFlags(0);
end

-- this is called when user hit a flag in the homeland. 
-- this is called in flag NPC on perception callbacks. 
-- @param nFlagIndex: flag index that the user touched
function FlagGame.OnHitFlag(nFlagIndex)
	-- TODO:
	local bIsEditMode = false;
	if(bIsEditMode) then
		return;
	end
	local flag = flags[nFlagIndex];
	if(not flag) then
		commonlib.log("warning: no flag is found for %d\n", nFlagIndex)
		return
	end
	
	flag.is_touched = true;
	
	-- TODO: hide the flag in the scene, since it is touched. 
	
	if(nFlagIndex == 1) then
		flag.rewarded = true
		-- TODO: given reward if not
		-- all other flags if not. 
		-- FlagGame.ShowFlags();
	else
		
	end
end

-- we should restart timing all over again. 
function FlagGame.OnRestartTiming()
	
end

-- show NPC flags in the scene for a given nid
-- @param count: how many flags to show. it can be 0 to hide all flags, 1 to display the first flag or nil to display all of them. 
function FlagGame.ShowFlags(count)
	count = count or #flags;
	local nFlagIndex, flag
	for nFlagIndex, flag in ipairs(flags) do
		if(nFlagIndex <= nFlagIndex) then
			-- show the flag NPC
			-- TODO: 
		else
			-- hide the flag NPC
			-- TODO: 
		end
	end
end

-- generate flags for a given nid
-- @param nid: string of user nid. it is used as the random seed to generate all the flag positions. So that different users are different. 
function FlagGame.GenerateFlags(nid)
	local nid = tonumber(nid);
	if(not nid) then
		commonlib.applog("invalid nid");
		return
	end
	
	flags = {};
	local nFlagCount = 6;
	
	-- TODO: generate 6 flags using nid as random seed. 
end