--[[ template<waitseconds = nil> GreenGrocer character
author: WangTian
date: 2006.9.9
desc: GreenGrocer
usage:
==On_Load==[optional]
;NPL.load("(gl)script/AI/templates/GreenGrocer.lua");_AI_templates.GreenGrocer.On_Load();

==On_Perception==
;NPL.load("(gl)script/AI/templates/GreenGrocer.lua");_AI_templates.GreenGrocer.On_Perception();

==On_Click==[optional]
;NPL.load("(gl)script/AI/templates/GreenGrocer.lua");_AI_templates.GreenGrocer.On_Click();

]]
local L = CommonCtrl.Locale("IDE");
if(not _AI_templates) then _AI_templates={}; end
if(not _AI_templates.GreenGrocer) then _AI_templates.GreenGrocer={}; end

--[[ optional
speak some "bla bla bla ..." every 20 seconds using sequence controller
@param waitseconds: if nil, it will be 20.
]]
function _AI_templates.GreenGrocer.On_Load(waitseconds)
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true) then 
		local playerChar = player:ToCharacter();
		playerChar:AssignAIController("face", "true");
		
		playerChar:SetPerceptiveRadius(5);
		
		if(waitseconds == nil) then
			waitseconds = 20;	
		end
		
		-- speak some "bla bla bla ..." every 20 seconds
		local s = playerChar:GetSeqController();
		-- delete all previous keys
		s:DeleteKeysRange(0,-1);
		s:SetStartFacing(0);
		-- add keys
		s:BeginAddKeys();
		s:Lable("start");
		s:Wait(waitseconds);
		s:Exec(string.format([[;headon_speech.Speek("%s", "%s", 3);]], sensor_name, L"selling fresh vegetable!"));
		s:Goto("start");
		s:EndAddKeys();
	end
end

--[[
Speek "Hello" for 4 seconds, when the character perceives another character for waitseconds long. It will wait another 10 seconds before speeking again.
@remark: AI memory is used and demostrated here.
@param waitseconds: if nil, it will be 3 seconds.
]]
function _AI_templates.GreenGrocer.On_Perception(waitseconds)
	local mem = _AI.GetMemory(sensor_name);
	
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true) then 
		local playerChar = player:ToCharacter();
		
		if(waitseconds == nil) then
			waitseconds = 3;	
		end
		if(mem.LastPerception==nil) then
			mem.LastPerception = 0;
		end
		if(mem.LastWait==nil) then
			mem.LastWait = 0;
		end
		
		local nTime = ParaGlobal.GetGameTime();
		
		if((nTime-mem.LastPerception)<1000) then
			mem.LastWait = mem.LastWait +(nTime-mem.LastPerception);
			
			if(mem.LastWait > 1000*waitseconds) then
				headon_speech.Speek(sensor_name, L"Hi, wanna some vegetable?", 4);
				mem.LastWait = -10000; -- wait 10 seconds before speaking again.
			end
		else 
			-- save to memory
			mem.LastWait = 0;
		end
		mem.LastPerception = nTime;
	end
end

-- just say something
function _AI_templates.GreenGrocer.On_Click()
	headon_speech.Speek(sensor_name, L"Cheap! Cheap! Come and buy!", 4);
end