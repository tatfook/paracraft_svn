--[[ template<waitseconds = nil> SimpleTutorial character
author: LiXizhi
date: 2006.9.8
desc: Say hello to a character when it sees it for waitseconds seconds, and face tracking nearby character. 
usage:
==On_Load==(optional)
;NPL.load("(gl)script/AI/templates/SimpleTutorial.lua");_AI_templates.SimpleTutorial.On_Load();

==On_Click==
;NPL.load("(gl)script/AI/templates/SimpleTutorial.lua");_AI_templates.SimpleTutorial.On_Click("intro");
]]
--requires: 
NPL.load("(gl)script/ide/headon_speech.lua");
NPL.load("(gl)script/ide/AI.lua");

--[[ some predefined text, turn it off since we no longer need it.
NPL.load("(gl)script/AI/templates/TutorialText/BasicTutorial_part1.lua");
NPL.load("(gl)script/AI/templates/TutorialText/BasicTutorial_part2.lua");
NPL.load("(gl)script/AI/templates/TutorialText/BasicTutorial_part3.lua");
NPL.load("(gl)script/AI/templates/TutorialText/BasicTutorial_part4.lua");
NPL.load("(gl)script/AI/templates/TutorialText/BasicTutorial_part5.lua");
]]

if(not _AI_templates) then _AI_templates={}; end
if(not _AI_templates.SimpleTutorial) then _AI_templates.SimpleTutorial={}; end
if(not _AI_templates.SimpleTalker) then _AI_templates.SimpleTalker={}; end

-- put a quest mark on the head of the character. 
-- @param mark: it can be "quest", "claim", "", or nil.
function _AI_templates.SimpleTutorial.On_Load(mark)
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true) then 
		local playerChar = player:ToCharacter();
		playerChar:AssignAIController("face", "true");
		if(type(mark)=="string") then
			headon_speech.ChangeHeadMark(sensor_name, mark);
		end	
	end
end

--[[
Speek a sentence, when the character perceives another character for ReactTime. It will wait another speakInverval seconds before speeking again.
@remark: AI memory is used and demostrated here.
@param ReactTime: if nil, it will be 3 seconds.
@param speakInverval: if nil, it will default to 10 seconds
]]
function _AI_templates.SimpleTalker.On_Perception(sent, ReactTime, speakInverval)
	local mem = _AI.GetMemory(sensor_name);
	
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true) then 
		local playerChar = player:ToCharacter();
		
		if(ReactTime == nil) then
			ReactTime = 3;	
		end
		if(speakInverval == nil) then
			speakInverval = 10;	
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
			
			if(mem.LastWait > 1000*ReactTime) then
				_AI_templates.SimpleTutorial.On_Click_str(sent);
				mem.LastWait = -speakInverval*1000; -- wait 10 seconds before speaking again.
			end
		else 
			-- save to memory
			mem.LastWait = 0;
		end
		mem.LastPerception = nTime;
	end
end

--[[ say something to the player
@param nCategory: if nil, it is 1. It can be both index or string category key into _AI_tutorials table.
]]
function _AI_templates.SimpleTutorial.On_Click(sCategory)
	
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true and player:DistanceTo(ParaScene.GetPlayer())<4) then 
		if(sCategory == nil) then
			sCategory = 1;
		end
		local s = _AI_tutorials[sCategory]; -- s is an array of text
		if(s == nil) then 
			return
		end
		local nCount = table.getn(s);
		local mem = _AI.GetMemory(sensor_name);
		if(mem.LastTalkIndex == nil) then
			headon_speech.ChangeHeadMark(sensor_name, "claim");
			mem.LastTalkIndex = 1;
		elseif(mem.LastTalkIndex>= nCount) then
			headon_speech.ChangeHeadMark(sensor_name, "");
			mem.LastTalkIndex = 0;
		else
			headon_speech.ChangeHeadMark(sensor_name, "quest");
			mem.LastTalkIndex = mem.LastTalkIndex+1;
		end
		if(mem.LastTalkIndex > 0) then
			local nDuration = 5;
			if(mem.LastTalkIndex<nCount)then
				nDuration = 8;
			end
			_AI_templates.SimpleTutorialTalk(sensor_name, s[mem.LastTalkIndex], nDuration);
		else	
			headon_speech.Speek(sensor_name, "", 0);--clear 
		end
	end
end

--[[ say something to the player
@param sText: it is retreated as plain text separated by "\n". The last one must also be ended with "\n"
]]
function _AI_templates.SimpleTutorial.On_Click_str(sText)
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true and player:DistanceTo(ParaScene.GetPlayer())<4) then 
		if(sText == nil) then
			-- TODO	
		else
			-- plain text	
			local s = {};
			local w;
			for w in string.gfind(sText, "(.-[^\\])\\n") do
				-- this will allow \n to appear in text
				w = string.gsub(w, "(.-)\\\\(.-)", "%1\\%2");
				table.insert(s, w)
			end
			local nCount = table.getn(s);
			if(nCount==0) then
				_AI_templates.SimpleTutorialTalk(sensor_name, sText, 7);
				headon_speech.ChangeHeadMark(sensor_name, "");
				return
			end
			local mem = _AI.GetMemory(sensor_name);
			if(mem.LastTalkIndex == nil) then
				headon_speech.ChangeHeadMark(sensor_name, "claim");
				mem.LastTalkIndex = 1;
			elseif(mem.LastTalkIndex>= nCount) then
				headon_speech.ChangeHeadMark(sensor_name, "");
				mem.LastTalkIndex = 0;
			else
				headon_speech.ChangeHeadMark(sensor_name, "quest");
				mem.LastTalkIndex = mem.LastTalkIndex+1;
			end
			if(mem.LastTalkIndex > 0) then
				local nDuration = 5;
				if(mem.LastTalkIndex<nCount)then
					nDuration = 8;
				end
				_AI_templates.SimpleTutorialTalk(sensor_name, s[mem.LastTalkIndex], nDuration);
			else	
				headon_speech.Speek(sensor_name, "", 0);--clear 
			end
		end	
	end
end
-- same as SimpleTutorial.On_Click_str
_AI_templates.SimpleTalker.On_Click = _AI_templates.SimpleTutorial.On_Click_str;

--[[
@param sensor_name:
@param nDuration: in seconds
@param sent: a plain text to be spoken.
the plain text can also XML style makeups, the following are supported makeups
<video>file name</video> it will play a given video in the tutorial video player box. e.g "See video<video>video/tutorial1.wmv</video> for how to act."
<sound>file name</sound> it will play a given sound. e.g "Hi<sound>Audio/Example.wav</sound>"
<anim>anim_name</anim> it will play an animation of a given name or ID.e.g. "Yes<anim>EmoteYes</anim>"
<code>script_code</code>: execute the script_code. This can be used to achieve many interesting effect, such as moving and constructing while talking. e.g. Yes<code>ParaAudio.PlayWaveFile("Audio/Example.wav");</code>
<highlightUI>UIObjectName</highlightUI>: high light a UI object called UIObjectName. If UIObjectName is blank, highlighting will be disabled for all UI. e.g. Click the button now<highlightUI>kidui_r_btn3</highlightUI>
e.g._AI_templates.SimpleTutorialTalk("小猪", "你好");
]]
function _AI_templates.SimpleTutorialTalk(sensor_name, sent, nDuration)
	local nFrom,nTo,file = string.find(sent,"<video>(.-)</video>");
	local ImageName = nil;
	local nWindowSize = nil;
	if(file~=nil and ParaIO.DoesFileExist(file)==true) then
		sent = string.sub(sent, 1, nFrom-1)..string.sub(sent, nTo+1, -1);
		NPL.load("(gl)script/kids/ui/Help.lua");
		KidsUI.ShowInGameVideo(file);
		nDuration = -1; -- make it permanent
	end
	nFrom,nTo,file = string.find(sent,"<image>(.-)</image>");
	if(file~=nil and ParaIO.DoesFileExist(file)==true) then
		sent = string.sub(sent, 1, nFrom-1)..string.sub(sent, nTo+1, -1);
		ImageName = file;
		nDuration = -1; -- make it permanent
	end
	nFrom,nTo,file = string.find(sent,"<sound>(.-)</sound>");
	if(file~=nil and ParaIO.DoesFileExist(file)==true) then
		sent = string.sub(sent, 1, nFrom-1)..string.sub(sent, nTo+1, -1);
		ParaAudio.PlayWaveFile(file);
	end
	local str;
	nFrom,nTo,str = string.find(sent,"<anim>(.-)</anim>");
	if(str~=nil) then
		sent = string.sub(sent, 1, nFrom-1)..string.sub(sent, nTo+1, -1);
		local player = ParaScene.GetObject(sensor_name);
		player:ToCharacter():PlayAnimation(str);
	end
	nFrom,nTo,str = string.find(sent,"<code>(.-)</code>");
	if(str~=nil) then
		sent = string.sub(sent, 1, nFrom-1)..string.sub(sent, nTo+1, -1);
		NPL.DoString(str);
	end
	nFrom,nTo,str = string.find(sent,"<url>(.-)</url>");
	if(str~=nil) then
		sent = string.sub(sent, 1, nFrom-1)..string.sub(sent, nTo+1, -1);
		_guihelper.MessageBox(sent, string.format([[ParaGlobal.ShellExecute("open", "iexplore.exe", %q, "", 1);]], str));
	end
	nFrom,nTo,str = string.find(sent,"<highlightUI>(.-)</highlightUI>");
	if(str~=nil) then
		sent = string.sub(sent, 1, nFrom-1)..string.sub(sent, nTo+1, -1);
		local tmp = ParaUI.GetUIObject(str);
		if(tmp:IsValid()==true) then
			tmp.highlightstyle="4outsideArrow";
		end
	end
	
	if(nDuration ~=nil and nDuration>0 and sent~=nil) then
		local minDuration = string.len(sent)/7; -- 7 letters per second
		if(minDuration>nDuration) then
			nDuration = minDuration;
		end	
	end
	headon_speech.Speek(sensor_name, sent, nDuration, nWindowSize, ImageName);
end