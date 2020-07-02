--[[
Title: The entry file for combat tutorial
Author(s): lxz for Andy
Date: 2010/9/22
Desc: To keep this tutorial logics fully standalone, all login procedure and server side handling
are handled externally via callback. see CombatTutorialMain.Start();
In this way, the logics is totally local(ignorance of the caller logics), 
so that it can be launched anywhere in the game (not just during login procedure)

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/Tutorial/CombatTutorialMain.lua");
MyCompany.Aries.Tutorial.CombatTutorialMain.Start(function(msg)  end);
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Combat/main.lua");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");

local CombatTutorialMain = commonlib.gettable("MyCompany.Aries.Tutorial.CombatTutorialMain");

-- state machine's state
local state = nil;
local last_state = nil; -- the last state. 

-- keeps global state's memory  in this table. 
local states = {
	spell_class	=nil, -- this is nil or a number frmo 986 to 992
	is_movie_finished = nil,
	is_master_dialog_started = nil,
	-- etc,...
};

-- goto a given state
-- @param new_state: name of the new state. 
function CombatTutorialMain.Goto(new_state)
	local handler = CombatTutorialMain[new_state];
	if(type(handler) == "function") then
		if(last_state~= new_state) then
			last_state = new_state;
			LOG.std(nil, "system", "CombatTutorial", "Goto state %s", new_state);
			handler();
		end
	end
end
local Goto = CombatTutorialMain.Goto;

-- this function is called from the MainLogin.lua after the tutorial world is loaded. 
-- @param callback_finished: this is a callback function of function(msg) end
--  where msg = {spell_class=number, }
function CombatTutorialMain.Start(callback_finished)
	LOG.std(nil, "system", "CombatTutorial", "Combat tutorial started.")
	paraworld.PostLog({action = "OnStartCombatTutorial", msg=""}, "tutorial");

	CombatTutorialMain.on_finished = callback_finished;
    
	---- start a timer for framemove
	--CombatTutorialMain.timer = CombatTutorialMain.timer or commonlib.Timer:new({callbackFunc = CombatTutorialMain.OnFrameMove});
	--CombatTutorialMain.timer:Change(0, 500);
	Goto("OnStart");
end

-- on frame move timer. 
function CombatTutorialMain.OnFrameMove(timer)
	
end

---------------------------------
-- state_machine handler: in time order
---------------------------------
function CombatTutorialMain.OnStart()
	
	local level = Combat.GetMyCombatLevel();
	if (level and level>1) then
		-- this might be an old user, push a message to him for upgrading. 
		NPL.load("(gl)script/apps/Aries/Mail/MailManager.lua");
		MyCompany.Aries.Quest.Mail.MailManager.OnInit();
		MyCompany.Aries.Quest.Mail.MailManager.PushMailByID(10002);

		MyCompany.Aries.Quest.Mail.MailManager.ShowMail(function()
			Goto("OnStartCamera");
		end);
	else
		Goto("OnStartCamera");
	end
end

-- show the initial scene camera
function CombatTutorialMain.OnStartCamera()
	-- TODO: LEIO: artist may insert camera here
	Goto("OnStartCombatDialog");
end

function CombatTutorialMain.OnStartCombatDialog()
	-- Goto("OnPickSchoolOfSpell");

	--  Andy: begin 3d combat tutorial here 
	if(System.options.version == "kids") then
		NPL.load("(gl)script/apps/Aries/NPCs/Combat/39002_CombatTutorial.lua", true);
	else
		NPL.load("(gl)script/apps/Aries/Login/Tutorial/CombatTutorial.teen.lua", true);
	end
    MyCompany.Aries.Quest.NPCs.CombatTutorial.main(CombatTutorialMain.on_finished);
end

function CombatTutorialMain.OnPickSchoolOfSpell()
	local params = {
		url = "script/apps/Aries/Login/Tutorial/PickSchoolOfSpell.kids.html", 
		name = "OnPickSchoolOfSpell", 
		isShowTitleBar = false,
		DestroyOnClose = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 10,
		allowDrag = false,
		directPosition = true,
			align = "_fi",
			x = 0,
			y = 0,
			width = 0,
			height = 0,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	if(params._page) then
		params._page.OnClose = function()
			stats.spell_class = MyCompany.Aries.Tutorial.PickSchoolOfSpell.SelectedSchoolID;
			Goto("OnFinishedPickingSpell");
		end;
	end
end

function CombatTutorialMain.OnFinishedPickingSpell()
	stats.spell_class = stats.spell_class or 986
	LOG.std(nil, "system", "CombatTutorial", "User has selected a spell school id %d",  stats.spell_class) ;

	-- TODO: invoke Andy's code
	-- TODO: shall we wait until assets are downloaded here?
	Goto("OnFinished");
end

-- finished.
function CombatTutorialMain.OnFinished()
	LOG.std(nil, "system", "CombatTutorial", "Combat tutorial finished.")
	if(CombatTutorialMain.on_finished) then
		CombatTutorialMain.on_finished({
			spell_class = states.spell_class,
		});
	end
end
