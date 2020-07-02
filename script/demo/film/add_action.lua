--[[
Title: The demo bar UI
Authors: LiXizhi
Date: 2005/9
Revised: 2006/9
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/demo/film/add_action.lua");
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("IDE");
local _char_actions = {
	[1] = {"EmoteYes", "Texture/face/01.png"},--点头
	[2] = {"EmoteLaugh", "Texture/face/02.png"},--大笑
	[3] = {"EmoteWave", "Texture/face/03.png"},--招手
	[4] = {"EmotePoint", "Texture/face/04.png"},--指路
	[5] = {"EmoteShy", "Texture/face/05.png"},--腼腆
	[6] = {"EmoteTalk", "Texture/face/06.png"},--对话
	[7] = {"SitChairLow", "Texture/face/07.png"},--低坐
	[8] = {"EmoteRude", "Texture/face/08.png"},--悲伤、挑衅SitChairMed
	[9] = {"EmoteCry", "Texture/face/09.png"},--抽泣SleepUp
	[10] = {"EmoteCheer", "Texture/face/10.png"},--欢呼SitGround坐地上
	[11] = {"EmoteNo", "Texture/face/11.png"},--拒绝EmoteWork工作
	[12] = {"EmoteSalute", "Texture/face/12.png"},--敬礼EmoteDance跳舞
	[13] = {"BattleRoar", "Texture/face/13.png"},--咆哮Whirlwind旋转
	[14] = {"Sleep", "Texture/face/24.png"}
	--[[[14] = {"Whirlwind", "Texture/face/14.png"},
	[15] = {"KneelLoop", "Texture/face/15.png"},
	[16] = {"EmoteTalkQuestion", "Texture/face/16.png"},
	[17] = {"EmoteNo", "Texture/face/17.png"},
	[18] = {"EmoteApplaud", "Texture/face/18.png"},
	[19] = {"EmoteRoar", "Texture/face/19.png"},
	[20] = {"EmotePoint", "Texture/face/20.png"},
	[21] = {"EmoteTalkExclamation", "Texture/face/21.png"},
	[22] = {"EmoteSalute", "Texture/face/22.png"},
	[23] = {"EmoteCheer", "Texture/face/23.png"},
	[24] = {"Sleep", "Texture/face/24.png"}]]
}
local function activate()
	local temp=ParaUI.GetUIObject("action_main");
	if (temp:IsValid() == true) then
		-- only toggle visibility.
		if(temp.visible == true) then
			temp.visible = false;
		else
			temp.visible = true;
		end
	else
		-- create it if not exists.
		local _this,_parent;
		_this=ParaUI.CreateUIObject("container","action_main", "_lt",420,80,360,350);
		_this:AttachToRoot();
		_this.scrollable=false;
		_this.background="Texture/add_bro.png";
		_this.candrag=true;
		_this.receivedrag = true;
		
		_this=ParaUI.CreateUIObject("text","text", "_lt",25,23,100,22);
		_parent=ParaUI.GetUIObject("action_main");_parent:AddChild(_this);
		_this.text=L"add action:";
		_this.autosize=true;
		
		local rows, cols = 3,5;
		local i,j, nIndex;
		local nTotal = table.getn(_char_actions);
		local left, top, btnSize = 30,50, 50;
		for i = 1, rows do
			left = 30;
			for j = 1, cols do
				nIndex = (i-1)*cols+j;
				if(nIndex <= nTotal) then
					local item = _char_actions[nIndex];
					_this=ParaUI.CreateUIObject("button","ActBtn", "_lt",left,top,btnSize,btnSize);
					_parent:AddChild(_this);
					_this.background=item[2];
					_this.onclick=string.format([[(gl)script/demo/film/play_action.lua;cast_action_="%s"]], item[1]);
					_this.animstyle = 12;
					_this.candrag=true;
				end
				left = left+btnSize+10;
			end
			top = top+btnSize+10;
		end
		
		_this=ParaUI.CreateUIObject("button","hide_button", "_lt",240,270,60,30);
		_parent:AddChild(_this);
		_this.text=L"hide";
		_this.background="Texture/b_up.png;";
		_this.onclick=";ParaUI.GetUIObject(\"action_main\").visible=false;";
	end
end
NPL.this(activate);
