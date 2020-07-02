--[[
Title: Text commands supported in the game's input text box
Author(s): LiXizhi
Date: 2007/1/3
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/ui/OnAICommand.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/headon_speech.lua");
local L = CommonCtrl.Locale("IDE");

if(not _AI) then _AI={}; end


--@param player: the player object, which is of type ParaObject
--@param sText: the command text to be applied to the player
--<tutorial> tutorial_category_name </tutorial>: the character will speak according to predefined templates at script/AI/templates/Tutorial*.txt
--"\t tutorial_category_name" : the character will speak according to predefined templates at script/AI/templates/Tutorial*.txt, e.g."\t intro"
--"[\?]|[\!] {sentence \n}": optionally display a ? or ! mark on the character head when it is loaded. Speak one sentence on each mouse click. sentences are separated by "\n". e.g."hello!", "\? Hi there\nTalk to LXZ\nGood Luck!\n", "\!help me please.\nbuild me a house\n"
--<onload>script_file;script_code</onload>: script_file can be empty, script_code will be executed when the character is loaded. This can be used to achieve many interesting effect, such as displaying a tutorial box when a scene is loaded. e.g. [[<onload>;ParaAudio.PlayWaveFile("Audio/Example.wav");</onload>]]
function _AI.DoPlayerTextCommand(player, sText)
	local playerChar = player:ToCharacter();
	local att = player:GetAttributeObject();
	if(not sText) then
		headon_speech.Speek(player.name, L"I am about to bla bla bla", 2);
		--att:SetField("On_Perception", [[;NPL.load("(gl)script/AI/templates/SimpleSayHello.lua");_AI_templates.SimpleSayHello.On_Perception();]]);
	else
		-- check for known commands
		local nFrom,nTo,str = string.find(sText,"<tutorial>(.-)</tutorial>");
		if(str~=nil) then
			sText = [[\t]]..str;
		end
		nFrom,nTo,str = string.find(sText,"<onload>(.-)</onload>");
		if(str~=nil) then
			sText = string.sub(sText, 1, nFrom-1)..string.sub(sText, nTo+1, -1);
			att:SetField("OnLoadScript", str);
			headon_speech.Speek(player.name, string.format("When loaded I will execute script:\n%s", str), 4);
			return
		end
		nFrom,nTo,str = string.find(sText,"<onperception>(.-)</onperception>");
		if(str~=nil) then
			sText = string.sub(sText, 1, nFrom-1)..string.sub(sText, nTo+1, -1);
			att:SetField("On_Perception", str);
			headon_speech.Speek(player.name, string.format("When I perceive any one, I will execute script:\n%s", str), 4);
			return
		end
		nFrom,nTo,str = string.find(sText,"<onframemove>(.-)</onframemove>");
		if(str~=nil) then
			sText = string.sub(sText, 1, nFrom-1)..string.sub(sText, nTo+1, -1);
			att:SetField("On_FrameMove", str);
			headon_speech.Speek(player.name, string.format("When I am sentient, I will execute script:\n%s", str), 4);
			return
		end
		nFrom,nTo,str = string.find(sText,"<onclick>(.-)</onclick>");
		if(str~=nil) then
			sText = string.sub(sText, 1, nFrom-1)..string.sub(sText, nTo+1, -1);
			att:SetField("On_Click", str);
			headon_speech.Speek(player.name, string.format("When I am clicked, I will execute script:\n%s", str), 4);
			return
		end
		-- check for header
		local header = string.sub(sText,1,2);
		if( header == [[\t]]) then
			-- if the text begins with "\t", the text after "\t" is retreated as a tutorial category name
			_, _, sText = string.find(sText, "(%a+)", 3);
			if(not sText) then return end
			
			headon_speech.Speek(player.name, string.format("I am tutorial NPC:\n%s", sText), 2);
			att:SetField("OnLoadScript", [[;NPL.load("(gl)script/AI/templates/SimpleTutorial.lua");_AI_templates.SimpleTutorial.On_Load("quest");]]);
			att:SetField("On_Click", string.format([[;NPL.load("(gl)script/AI/templates/SimpleTutorial.lua");_AI_templates.SimpleTutorial.On_Click(%q);]], sText));
		else
			-- otherwise, encode text in onclick event.
			if( header == [[\?]]) then
				-- if the text begins with "\?", the text after "\?" is retreated as a string separated by "\n". However, when the character is loaded, it will display a ? mark on its top.
				sText = string.sub(sText, 3,-1);
				att:SetField("OnLoadScript", [[;NPL.load("(gl)script/AI/templates/SimpleTutorial.lua");_AI_templates.SimpleTutorial.On_Load("quest");]]);
			elseif( header == [[\!]]) then
				-- if the text begins with "\!", the text after "\!" is retreated as a string separated by "\n". However, when the character is loaded, it will display a ! mark on its top.
				sText = string.sub(sText, 3,-1);
				att:SetField("OnLoadScript", [[;NPL.load("(gl)script/AI/templates/SimpleTutorial.lua");_AI_templates.SimpleTutorial.On_Load("claim");]]);
			else
				-- for any other beginning strings, the text is retreated as a string separated by "\n". When the character is loaded, it will use a face tracing controller, yet no ? or ! mark is displayed on top of them.
				att:SetField("OnLoadScript", [[;NPL.load("(gl)script/AI/templates/SimpleTutorial.lua");_AI_templates.SimpleTutorial.On_Load();]]);
			end
			if(not sText) then return end
			headon_speech.Speek(player.name, string.format(L"When you click on me, I will speak:\n%s", sText), 2);
			att:SetField("On_Click", string.format([[;NPL.load("(gl)script/AI/templates/SimpleTutorial.lua");_AI_templates.SimpleTutorial.On_Click_str(%q);]], sText));
		end	
	end	
end
